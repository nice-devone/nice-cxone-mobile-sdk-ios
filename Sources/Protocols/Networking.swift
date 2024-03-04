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

// MARK: - URLSessionProtocol

protocol URLSessionProtocol {
    
    associatedtype DTA: URLSessionWebSocketTaskProtocol
    
    func webSocketTask(with request: URLRequest) -> DTA
    
    var delegate: URLSessionDelegate? { get }
}

// MARK: - URLSession + URLSessionProtocol

extension URLSession: URLSessionProtocol { }

// MARK: - URLSessionWebSocketTaskProtocol

protocol URLSessionWebSocketTaskProtocol {
    
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping (Error?) -> Void)
    
    func receive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void)
    
    func sendPing(pongReceiveHandler: @escaping @Sendable (Error?) -> Void)
    
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    
    func resume()
    
    @available(iOS 15.0, *)
    var delegate: URLSessionTaskDelegate? { get set }
}

// MARK: - URLSessionWebSocketTask + URLSessionWebSocketTaskProtocol

extension URLSessionWebSocketTask: URLSessionWebSocketTaskProtocol { }
