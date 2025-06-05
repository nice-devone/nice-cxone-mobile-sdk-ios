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

import Foundation
import XCTest
@testable import CXoneChatSDK

// MARK: - URLSessionWebSocketTaskMock

class URLSessionWebSocketTaskMock: URLSessionWebSocketTaskProtocol {
    
    // MARK: - Properties
    
    var delegate: URLSessionTaskDelegate?
    var closure: ((String) -> Void)?
    
    // MARK: - Methods
    
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping (Error?) -> Void) {
        var messageString = "messageString"
        
        guard case URLSessionWebSocketTask.Message.string(let string) = message else {
            return
        }
        
        if string != "{\"action\":\"heartbeat\"}" {
            guard let data = string.data(using: .utf8) else {
                completionHandler(CXoneChatError.invalidData)
                return
            }
            
            do {
                let decode = try JSONDecoder().decode(EventPayLoadCodable.self, from: data)
                
                switch decode.payload.eventType {
                case .authorizeCustomer:
                    guard let utf8string = try loadStubFromBundle(withName: "authorize", extension: "json").utf8string else {
                        completionHandler(CXoneChatError.missingParameter("utf8string"))
                        return
                    }
                    
                    messageString = utf8string
                case .customerAuthorized, .tokenRefreshed, .messageCreated, .moreMessagesLoaded,
                        .messageReadChanged, .threadRecovered, .threadListFetched, .threadMetadataLoaded, .threadArchived,
                        .contactInboxAssigneeChanged, .messageSeenByCustomer, .reconnectCustomer, .refreshToken:
                    break
                case .sendMessage:
                    guard let utf8string = try loadStubFromBundle(withName: "MessageCreated", extension: "json").utf8string else {
                        completionHandler(CXoneChatError.missingParameter("utf8string"))
                        return
                    }
                    
                    messageString = utf8string
                case .loadThreadMetadata:
                    guard let utf8string = try loadStubFromBundle(withName: "threadMetadaLoaded", extension: "json").utf8string else {
                        completionHandler(CXoneChatError.missingParameter("utf8string"))
                        return
                    }
                    
                    messageString = utf8string
                default:
                    break
                }
                
                closure?(messageString)
            } catch {
                completionHandler(error)
            }
        } else {
            closure?(string)
        }
    }
    
    func receive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void) {
        closure = { string in
            completionHandler(.success(.string(string)))
        }
    }
    
    func sendPing(pongReceiveHandler: @escaping (Error?) -> Void) {
        pongReceiveHandler(nil)
    }
    
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) { }
    
    func resume() { }
    
    func loadStubFromBundle(withName name: String, extension: String) throws -> Data {
        let url = URL(forResource: name, type: `extension`)
        
        return try Data(contentsOf: url)
    }
}

// MARK: - URLSessionMock
 
class URLSessionMock: URLProtocol, URLSessionProtocol {

    // MARK: - Properties

    var delegate: URLSessionDelegate?
    
    // MARK: - Methods
    
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        return (Data(), HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
    }

    func data(from url: URL, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        return (Data(), HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
    }

    func webSocketTask(with url: URL) -> URLSessionWebSocketTaskProtocol { URLSessionWebSocketTaskMock() }

    override class func canInit(with request: URLRequest) -> Bool { true }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override func startLoading() { }
    
    override func stopLoading() { }
}
