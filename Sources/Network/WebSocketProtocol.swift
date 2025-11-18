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
import Mockable

@Mockable
internal protocol WebSocketProtocol {
    var receive: PassthroughSubject<URLSessionWebSocketTask.Message, WebSocketError> { get }

    /// Sends a message to the web socket server.
    /// 
    /// - Parameters:
    ///   - message: The message to send, which can be either text or binary data.
    ///   - completionHandler: A closure that will be called when the message is sent.
    ///         The closure will be called with an optional error if the message was sent successfully or if there was an error in sending the message.
    ///         If the message is sent successfully, the error will be `nil`.
    ///         If there is an error in sending the message, the error will contain details about the failure.
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping ((Error?) -> Void))

    /// Sends a ping frame to the web socket server.
    /// /// - Parameter pongReceiveHandler: A closure that will be called when a pong response is received.
    /// - Note: This method is used to check the health of the connection and keep it alive.
    ///         The closure will be called with an optional error if the pong response is received or if there is an error in sending the ping.
    ///         If the pong response is received successfully, the error will be `nil`.
    ///         If there is an error in sending the ping, the error will contain details about the failure.
    func sendPing(pongReceiveHandler: @escaping ((Error?) -> Void))

    /// Resumes the web socket task, starting the connection to the server.
    /// - Note: This method is typically called after the web socket task has been created but before any messages are sent or received.
    ///     It establishes the connection to the server and prepares the web socket for communication.
    /// - Throws: An error if the web socket task could not be resumed, such as if the connection could not be established or if there was a protocol error.
    func resume() async throws

    /// Cancels the web socket task with a close code and an optional reason.
    ///
    /// - Parameters:
    ///   - closeCode: The close code to use for the cancellation.
    ///   - reason: An optional reason for the cancellation, provided as a `Data` object.
    ///
    /// - Note: This method is typically used to gracefully close the connection.
    ///         If you want to close the connection without a specific reason, you can pass `nil` for the `reason`.
    ///         The `closeCode` should be one of the standard WebSocket close codes defined in the WebSocket protocol.
    ///         Common close codes include `URLSessionWebSocketTask.CloseCode.normalClosure` for a normal closure,
    ///         or `URLSessionWebSocketTask.CloseCode.goingAway` if the server is going away.
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}

extension WebSocketProtocol {
    
    func send(_ message: URLSessionWebSocketTask.Message) {
        send(message) { _ in }
    }
}
