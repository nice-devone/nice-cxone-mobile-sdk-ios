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
import Mockable

@Mockable
protocol SocketService: AnyObject {
    var connectionContext: ConnectionContext { get }

    var events: AnyPublisher<any ReceivedEvent, Never> { get }

    var delegate: SocketDelegate? { get set }

    var accessToken: AccessTokenDTO? { get set }

    /// Opens a new WebSocket connection using the specified URL.
    /// 
    /// - Parameter socketURL: The URL for the location of the WebSocket.
    func connect(socketURL: URL)

    /// Closes the current WebSocket session.
    func disconnect(unexpectedly: Bool)

    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    func checkForConnection() throws

    /// Sends a message through the WebSocket.
    /// - Parameters:
    ///   - message: The message to be sent.
    ///   - shouldCheck: Whether to check for an expired access token.
    ///
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    func send(data: Data, shouldCheck: Bool) throws

    /// Sends a ping through the WebSocket to ensure that the server is connected.
    @available(*, deprecated, message: "Deprecated as of 2.2.0")
    func ping()
}

extension SocketService {
    
    /// Sends a message through the WebSocket.
    ///
    /// - Parameters:
    ///   - message: The message to be sent.
    ///   - shouldCheck: Whether to check for an expired access token.
    ///
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    func send(data: Data) throws {
        try send(data: data, shouldCheck: true)
    }
}
