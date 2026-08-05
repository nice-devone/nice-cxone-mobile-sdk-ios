//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneGuideUtility
import Foundation

/// Concrete WebSocket connection wrapping ``URLSessionWebSocketTaskProtocol``.
///
/// Bridges the completion-handler-based `URLSessionWebSocketTask` API into an
/// `AsyncThrowingStream` exposed via ``WebSocketProtocol/receive``.
/// Outbound sends are forwarded directly to the underlying task; connection
/// lifecycle events (`didOpen`, `didClose`, `didCompleteWithError`) are handled
/// through `URLSessionWebSocketDelegate` conformance.
///
/// - Note: `@unchecked Sendable` is safe here because the only mutable state is
///   the pending start-continuation, which is held inside a `SafeAccessContainer`
///   and therefore only accessed inside `mutate(_:)`. All other stored properties
///   are immutable `let` constants.
final class WebSocket: NSObject, @unchecked Sendable {

    // MARK: - Properties

    let receive: AsyncThrowingStream<URLSessionWebSocketTask.Message, any Error>

    // MARK: - Private Properties

    private let task: URLSessionWebSocketTaskProtocol
    private let continuation: AsyncThrowingStream<URLSessionWebSocketTask.Message, any Error>.Continuation
    private let waitForStart = SafeAccessContainer<CheckedContinuation<(), any Error>?>(nil)

    // MARK: - Init

    init(task: URLSessionWebSocketTaskProtocol) {
        self.task = task
        let (stream, continuation) = AsyncThrowingStream<URLSessionWebSocketTask.Message, any Error>.makeStream()
        self.receive = stream
        self.continuation = continuation
        super.init()

        task.receive { [weak self] result in
            self?.onReceive(result: result)
        }
        
        task.delegate = self
    }
}

// MARK: - WebSocketProtocol

extension WebSocket: WebSocketProtocol {

    func resume() async throws {
        try await withCheckedThrowingContinuation { continuation in
            // Store the continuation BEFORE calling task.resume(). The lock must
            // release before resume() is called so that sessionDidOpen / sessionDidClose
            // can acquire it when they fire on the delegate callback thread — including
            // the case where the callback arrives synchronously during resume().
            // Reversing this order would open a window where the callback fires before
            // waitForStart is set, leaving the CheckedContinuation never resumed.
            waitForStart.mutate { stored in
                stored = continuation
            }

            task.resume()
        }
    }

    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping @Sendable (Error?) -> Void) {
        task.send(message) { [weak self] error in
            if let error {
                LogManager.error("Error sending message: \(error)")

                self?.continuation.finish(throwing: WebSocketError.protocolError(error))
            }

            completionHandler(error)
        }
    }

    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        task.cancel(with: closeCode, reason: reason)
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocket: URLSessionWebSocketDelegate {

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        LogManager.trace("WebSocket connection opened")

        sessionDidOpen()
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        LogManager.trace("WebSocket connection closed with code: \(closeCode), reason: \(String(describing: reason))")

        sessionDidClose(with: closeCode)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        LogManager.trace("WebSocket task completed with error: \(String(describing: error))")

        sessionDidClose(with: .goingAway)
    }
}

// MARK: - Internal methods

extension WebSocket {

    func sessionDidOpen() {
        let startContinuation = waitForStart.mutate { stored -> CheckedContinuation<(), any Error>? in
            let captured = stored
            stored = nil
            return captured
        }

        startContinuation?.resume()
    }

    func onReceive(result: Result<URLSessionWebSocketTask.Message, any Error>) {
        switch result {
        case let .success(message):
            continuation.yield(message)

            task.receive { [weak self] result in
                self?.onReceive(result: result)
            }
        case let .failure(error):
            continuation.finish(throwing: WebSocketError.protocolError(error))
        }
    }

    func sessionDidClose(with code: URLSessionWebSocketTask.CloseCode) {
        let startContinuation = waitForStart.mutate { stored -> CheckedContinuation<(), any Error>? in
            let captured = stored
            stored = nil
            return captured
        }
        
        // `startContinuation` is the one-shot CheckedContinuation awaited by resume(),
        // while `continuation` is the AsyncThrowingStream used for incoming messages.
        // Both receive the same error value, but they are intentionally separate objects.
        let closeError = WebSocketError.serverError(code)

        startContinuation?.resume(throwing: closeError)

        switch code {
        case .normalClosure:
            continuation.finish()
        default:
            continuation.finish(throwing: closeError)
        }
    }
}
