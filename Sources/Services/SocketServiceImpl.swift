//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Combine
import Foundation

/// Class for interacting with the WebSocket.
class SocketServiceImpl: NSObject, SocketService, EventReceiver {
    
    // MARK: - Properties
    
    let connectionContext: ConnectionContext
    
    var delegate: SocketDelegate?

    /// Whether the socket is currently connected.
    var isConnected: Bool {
        connectionContext.chatState.isChatAvailable && socket != nil
    }
    
    /// An operation queue for scheduling the delegate calls and completion handlers.
    private var operationQueue = OperationQueue()
    
    /// The WebSocket for sending and receiving messages.
    private let subject = PassthroughSubject<ReceivedEvent, Never>()
    
    private var socket: WebSocketProtocol?

    private var eventTransfer: AnyCancellable?

    private let semaphore = DispatchSemaphore(value: 0)
    
    /// Whether a pong was received for the heartbeat message.
    private var pongReceived = false
    
    /// The timer for when pulse messages should be sent.
    private var pulseTimer: Task<(), Never>?

    private var urlSession: URLSessionProtocol {
        connectionContext.session
    }

    var accessToken: AccessTokenDTO? {
        get { connectionContext.accessToken }
        set {
            connectionContext.accessToken = newValue
            semaphore.signal()
        }
    }
    
    // MARK: - EventReceiver

    var events: AnyPublisher<any ReceivedEvent, Never> {
        subject.eraseToAnyPublisher()
    }
    var cancellables = [AnyCancellable]()

    // MARK: - Init
    
    init(connectionContext: ConnectionContext) {
        self.connectionContext = connectionContext
    }
    
    // MARK: - Methods
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    func checkForConnection() throws {
        if !isConnected {
            disconnect(unexpectedly: false)

            throw CXoneChatError.notConnected
        }
    }
    
    /// Opens a new WebSocket connection using the specified URL.
    /// - Parameter socketURL: The URL for the location of the WebSocket.
    func connect(socketURL: URL) {
        LogManager.trace("Opening new websocket connection.")
        
        socket = urlSession.webSocketProtocol(with: socketURL)

        socket?.resume()

        addListeners()

        pulseTimer = startPulseTimer()
    }
    
    /// Closes the current WebSocket session.
    func disconnect(unexpectedly: Bool) {
        delegate?.didCloseConnection(unexpectedly: unexpectedly)

        socket?.cancel(with: .goingAway, reason: nil)
        socket = nil

        eventTransfer?.cancel()
        eventTransfer = nil

        pulseTimer?.cancel()
        pulseTimer = nil
    }
    
    /// Sends a message through the WebSocket.
    /// - Parameters:
    ///   - message: The message to be sent.
    ///   - shouldCheck: Whether to check for an expired access token.
    ///
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    func send(data: Data, shouldCheck: Bool = true) throws {
        guard let message = data.utf8string else {
            throw CXoneChatError.invalidData
        }
        
        #if DEBUG
        LogManager.trace("Sending a message: \(message.formattedJSON ?? message).")
        #endif
        
        if shouldCheck, accessToken?.isExpired(currentDate: Date.provide()) ?? false {
            delegate?.refreshToken()
            semaphore.wait()
        }

        socket?.send(.string(message))
    }

    /// Sends a ping through the WebSocket to ensure that the server is connected.
    @available(*, deprecated, message: "Deprecated as of 2.2.0")
    func ping() {
        socket?.sendPing()
    }
    
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    private func downloadEventContentFromS3(_ object: EventInS3DTO) {
        LogManager.trace("Downloads the content of the `\(object.originEventType)` event stored in S3")
        
        Task {
            let request = URLRequest(url: object.url, method: .get, contentType: "application/json")
            let (data, response) = try await connectionContext.session.fetch(for: request, fun: #function)
            
            guard let response = response as? HTTPURLResponse, (200 ... 299) ~= response.statusCode else {
                LogManager.error("Error downloading s3 event")
                return
            }
            
            forward(data: data)
        }
    }

    func forward(data: Data) {
        if let event = data.toReceivedEvent() {
            subject.send(event)
        }
    }
}

// MARK: - Private methods

private extension SocketServiceImpl {
    static let pingDelay = 10.0
    static let pingResponseTimeout = 5.0

    func startPulseTimer() -> Task<(), Never> {
        Task {
            while !Task.isCancelled {
                await Task.sleep(seconds: Self.pingDelay)

                if Task.isCancelled {
                    break
                }
                
                sendPulse()

                if Task.isCancelled {
                    break
                }
                
                await verifyPulse()
            }
        }
    }

    /// Sends a heartbeat message through the WebSocket and verifies the response.
    func sendPulse() {
        do {
            guard let utf8string = try JSONSerialization.data(withJSONObject: ["action": "heartbeat"], options: .fragmentsAllowed).utf8string else {
                throw CXoneChatError.missingParameter("utf8string")
            }

            pongReceived = false

            socket?.send(.string(utf8string))
        } catch {
            error.logError()
        }
    }

    /// Verifies that a pong was received. If it wasn't received, the WebSocket connection is closed.
    func verifyPulse() async {
        await Task.sleep(seconds: Self.pingResponseTimeout)

        if !pongReceived {
            LogManager.trace("Pong was not received.")
            
            disconnect(unexpectedly: false)
        }
    }

    /// Starts listening for any message that is received from the WebSocket and handles it.
    func addListeners() {
        // add listeners to socket
        addEventTransfer()

        // add listeners to events
        addListener(downloadEventContentFromS3(_:))
    }

    func addEventTransfer() {
        eventTransfer = socket?.receive.sink { [weak self] completion in
            LogManager.trace("WebSocket closed: \(completion)")
            
            switch completion {
            case .finished:
                self?.disconnect(unexpectedly: true)
            case let .failure(error):
                error.logError()
                self?.delegate?.didReceive(error: error)
            }
        } receiveValue: { [weak self] response in
            switch response {
            case .data:
                LogManager.trace("Did receive data")
            case .string(let message):
                if message == #""pong""# {
                    self?.pongReceived = true
                } else {
                    #if DEBUG
                    LogManager.trace("Did receive string: \(message.formattedJSON ?? message)")
                    #endif

                    if let data = message.data(using: .utf8) {
                        self?.forward(data: data)
                    }
                }
            default:
                LogManager.warning("Listener did received unknown response case - \(response)")
                return
            }
        }
    }
}
