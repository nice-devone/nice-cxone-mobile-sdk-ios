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
// periphery:ignore:all

import Foundation
import Mockable

// MARK: - URLSessionWebSocketTaskProtocol

@Mockable
protocol URLSessionWebSocketTaskProtocol: AnyObject {
    var delegate: URLSessionTaskDelegate? { get set }
    
    @preconcurrency
    func send(
        _ message: URLSessionWebSocketTask.Message,
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    )

    @preconcurrency
    func receive(completionHandler: @escaping @Sendable (Result<URLSessionWebSocketTask.Message, any Error>) -> Void)

    func sendPing(pongReceiveHandler: @escaping @Sendable (Error?) -> Void)

    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)

    func resume()
}

// MARK: - URLSessionWebSocketTask + URLSessionWebSocketTaskProtocol

extension URLSessionWebSocketTask: URLSessionWebSocketTaskProtocol { }
