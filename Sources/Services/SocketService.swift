//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

import Foundation

/// Class for interacting with the WebSocket.
class SocketService: NSObject {
    
    // MARK: - Properties
    
    let dateProvider: DateProvider
    var connectionContext: ConnectionContext
    
    var delegate: SocketDelegate?
    
    /// Whether the socket is currently connected.
    var isConnected: Bool {
        connectionContext.chatState.isChatAvailable && socket != nil
    }
    
    /// An operation queue for scheduling the delegate calls and completion handlers.
    private var operationQueue = OperationQueue()
    
    /// The WebSocket for sending and receiving messages.
    private var socket: URLSessionWebSocketTaskProtocol?
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    /// Whether a pong was received for the heartbeat message.
    private var pongReceived = false
    
    /// The timer for when pulse messages should be sent.
    private var pulseTimer: Timer?
    
    var accessToken: AccessTokenDTO? {
        get { connectionContext.accessToken }
        set {
            connectionContext.accessToken = newValue
            semaphore.signal()
        }
    }
    
    // MARK: - Init
    
    init(connectionContext: ConnectionContext, dateProvider: DateProvider) {
        self.connectionContext = connectionContext
        self.dateProvider = dateProvider
    }
    
    // MARK: - Methods
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    func checkForConnection() throws {
        if !isConnected {
            disconnect()

            throw CXoneChatError.notConnected
        }
    }
    
    /// Opens a new WebSocket connection using the specified URL.
    /// - Parameter socketURL: The URL for the location of the WebSocket.
    func connect(socketURL: URLRequest, config: URLSessionConfiguration = .default) {
        LogManager.trace("Opening new websocket connection.")
        
        let urlSession = URLSession(configuration: config, delegate: self, delegateQueue: operationQueue)
        
        socket = urlSession.webSocketTask(with: socketURL)
        socket?.sendPing { [weak self] error in
            guard let error = error else {
                return
            }
            
            error.logError()
            self?.disconnect()
        }
        
        pulseTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(checkPulse), userInfo: nil, repeats: true)
        
        socket?.resume()
        addListener()
    }
    
    /// Closes the current WebSocket session.
    func disconnect() {
        connectionContext.chatState = .prepared
        
        socket?.cancel(with: .goingAway, reason: nil)
        socket = nil

        pulseTimer?.invalidate()
    }
    
    /// Sends a message through the WebSocket.
    /// - Parameters:
    ///   - message: The message to be sent.
    ///   - shouldCheck: Whether to check for an expired access token.
    func send(message: String, shouldCheck: Bool = true) {
        LogManager.trace("Sending a message: \(message.formattedJSON ?? message).")
        
        if shouldCheck, accessToken?.isExpired(currentDate: dateProvider.now) ?? false {
            do {
                try delegate?.refreshToken()
                semaphore.wait()
            } catch {
                error.logError()
                delegate?.didReceiveError(error)
            }
        }
        
        socket?.send(.string(message)) { [weak delegate] error in
            LogManager.trace("Did send a message.")
            
            if let error {
                error.logError()
                delegate?.didReceiveError(error)
            }
        }
    }
    
    /// Sends a ping through the WebSocket to ensure that the server is connected.
    @objc
    func ping() {
        socket?.sendPing { error in
            LogManager.trace("Did send a ping to ensure that the server is connected.")
            
            if let error {
                error.logError()
            }
        }
    }
}

// MARK: - Private methods

private extension SocketService {
    
    /// Sends a heartbeat message through the WebSocket and verifies the response.
    @objc
    func checkPulse() {
        do {
            let data = try JSONSerialization.data(withJSONObject: ["action": "heartbeat"], options: .fragmentsAllowed)
            
            guard let string = String(data: data, encoding: .utf8) else {
                delegate?.didReceiveError(CXoneChatError.missingParameter("heartbeat"))
                return
            }
            
            pongReceived = false
            
            socket?.send(.string(string)) { [weak self] error in
                guard let self = self else {
                    return
                }
                if let error {
                    error.logError()
                    self.delegate?.didReceiveError(error)
                }
                
                Task {
                    await self.verifyPulse()
                }
            }
        } catch {
            error.logError()
        }
    }
    
    /// Verifies that a pong was received. If it wasn't received, the WebSocket connection is closed.
    func verifyPulse() async {
        await Task.sleep(seconds: 1)
        
        if !pongReceived {
            LogManager.trace("Pong was not received.")
            
            delegate?.didCloseConnection()
        }
    }
    
    /// Starts listening for any message that is received from the WebSocket and handles it.
    func addListener() {
        socket?.receive { [weak self] result in
            guard self?.socket != nil else {
                // Socket has been invalidated
                return
            }
            
            switch result {
            case .success(let response):
                switch response {
                case .data:
                    LogManager.trace("Did receive data?")
                case .string(let message):
                    if message == "\"pong\"" {
                        self?.pongReceived = true
                    } else {
                        self?.delegate?.handle(message: message)
                    }
                default:
                    LogManager.warning("Listener did received unknown response case - \(response)")
                    return
                }
                
                self?.addListener()
            case .failure(let error):
                error.logError()
                
                if let error = error as? POSIXError, error.code == .ENOTCONN {
                    self?.delegate?.didCloseConnection()
                } else {
                    self?.delegate?.didReceiveError(error)
                }
            }
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension SocketService: URLSessionWebSocketDelegate {
    
    /// Called when the WebSocket disconnects.
    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        LogManager.trace("Did close connection")
        
        if closeCode != .goingAway {
            delegate?.didCloseConnection()
        }
    }
    
    #if DEBUG
        /// Allows for inspecting traffic in tools like Proxyman or CharlesApp.
        public func urlSession(
            _ session: URLSession,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                delegate?.didReceiveError(CXoneChatError.missingParameter("serverTrust"))
                return
            }
        
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    #endif
}
