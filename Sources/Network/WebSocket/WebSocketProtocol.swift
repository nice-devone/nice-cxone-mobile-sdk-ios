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

import Foundation
import Mockable

@Mockable
internal protocol WebSocketProtocol: Sendable {
    /// An async stream of messages received from the server.
    ///
    /// The stream finishes normally on a clean close, or throws a `WebSocketError` if the connection
    /// is lost unexpectedly or a protocol-level error occurs.
    var receive: AsyncThrowingStream<URLSessionWebSocketTask.Message, any Error> { get }

    /// Sends a message to the web socket server.
    ///
    /// - Parameters:
    ///   - message: The message to send, which can be either text or binary data.
    ///   - completionHandler: A closure called when the send completes. `nil` error means success.
    ///
    /// - Note: **Send errors also terminate the `receive` stream.**
    ///   When the underlying send fails, the implementation calls
    ///   `continuation.finish(throwing: WebSocketError.protocolError(error))` on the stream
    ///   returned by `receive`, in addition to passing the error to `completionHandler`.
    ///   Callers that consume `receive` via a `for try await` loop will therefore observe the
    ///   error there — not only (or instead of) through `completionHandler`.
    ///   If you do not need per-send error feedback, use the `send(_:)` convenience overload,
    ///   which discards the completion-handler error and relies solely on the `receive` stream
    ///   for error propagation.
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping @Sendable (Error?) -> Void)

    /// Resumes the web socket task, starting the connection to the server.
    ///
    /// - Throws: An error if the connection could not be established.
    func resume() async throws

    /// Cancels the web socket task with a close code and an optional reason.
    ///
    /// - Parameters:
    ///   - closeCode: The close code to use for the cancellation.
    ///   - reason: An optional reason for the cancellation, provided as a `Data` object.
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}

extension WebSocketProtocol {

    func send(_ message: URLSessionWebSocketTask.Message) {
        send(message) { _ in }
    }
}
