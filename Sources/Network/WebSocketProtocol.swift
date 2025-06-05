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

    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping ((Error?) -> Void))

    func sendPing(pongReceiveHandler: @escaping ((Error?) -> Void))

    // periphery:ignore - may be used in the future
    func resume()

    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}

extension WebSocketProtocol {
    
    func send(_ message: URLSessionWebSocketTask.Message) {
        send(message) { _ in }
    }
}
