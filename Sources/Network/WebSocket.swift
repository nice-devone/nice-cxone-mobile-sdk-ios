//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
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

internal class WebSocket: NSObject {

    // MARK: - Properties

    let receive = PassthroughSubject<URLSessionWebSocketTask.Message, WebSocketError>()

    // MARK: - Private Properties

    private let task: URLSessionWebSocketTaskProtocol

    private var waitForStart: CheckedContinuation<(), Never>?

    // MARK: - Init

    init(task: URLSessionWebSocketTaskProtocol) {
        self.task = task
        super.init()

        task.receive(completionHandler: onReceive)
        task.delegate = self
    }

    // periphery:ignore - may be used in the future
    func resume() async {
        await withCheckedContinuation { continuation in
            waitForStart = continuation
            task.resume()
        }
    }

    // MARK: - Methods
    
    func onReceive(result: Result<URLSessionWebSocketTask.Message, any Error>) {
        switch result {
        case let .success(success):
            receive.send(success)
            task.receive(completionHandler: onReceive(result:))
        case let .failure(error):
            receive.send(completion: .failure(.protocolError(error)))
        }
    }

    func sessionDidOpen() {
        waitForStart?.resume()
        waitForStart = nil
    }

    func sessionDidClose(with code: URLSessionWebSocketTask.CloseCode) {
        switch code {
        case .normalClosure:
            receive.send(completion: .finished)
        default:
            receive.send(completion: .failure(.serverError(code)))
        }
    }
}

// MARK: - WebSocketProtocol implementation

extension WebSocket: WebSocketProtocol {
    
    func send(
        _ message: URLSessionWebSocketTask.Message,
        completionHandler: @escaping ((Error?) -> Void)
    ) {
        task.send(message) { [weak self] error in
            if let error {
                LogManager.error("Error sending message: \(error)")
                self?.receive.send(completion: .failure(.protocolError(error)))
            }
            completionHandler(error)
        }
    }
    
    func sendPing(pongReceiveHandler: @escaping ((Error?) -> Void)) {
        task.sendPing { [weak self] error in
            if let error {
                LogManager.error("Error sending ping: \(error)")
                self?.receive.send(completion: .failure(.protocolError(error)))
            }
            pongReceiveHandler(error)
        }
    }

    // periphery:ignore - may be used in the future
    func resume() {
        task.resume()
    }
    
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        task.cancel(with: closeCode, reason: reason)
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocket: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        sessionDidOpen()
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        sessionDidClose(with: closeCode)
    }
}
