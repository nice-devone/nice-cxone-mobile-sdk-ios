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

import XCTest
@testable import CXoneChatSDK

class EndpointTests: XCTestCase {

    // MARK: - Properties
    
    var sut: Endpoint?
    
    // MARK: - Lifecycle
    
    override func setUpWithError() throws {
        let brandItem = URLQueryItem(name: "brand", value: "1326")
        let channelItem = URLQueryItem(name: "channelId", value: "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4")
        let customerIdItem = URLQueryItem(name: "customerId", value: UUID().uuidString)
        let vQItem = URLQueryItem(name: "v", value: "4.74")
        let eioQItem = URLQueryItem(name: "EIO", value: "3")
        let transportQItem = URLQueryItem(name: "transport", value: "polling")
        let tQItem = URLQueryItem(name: "t", value: "NlrXzTa")

        sut = SocketEndpointDTO(
            environment: Environment.NA1,
            queryItems: [brandItem, channelItem, customerIdItem, vQItem, eioQItem, transportQItem, tQItem],
            method: .get
        )
    }

    override func tearDownWithError() throws {
       sut = nil
    }
    
    // MARK: - Tests
    
    func testURLisValid() {
        XCTAssertNotNil(sut?.url)
        XCTAssertNoThrow(try sut?.urlRequest())
    }
    
    func testSchemeIsWss() {
        XCTAssertTrue(sut?.url?.scheme == "wss")
    }
    
    func testHostIsNA1() {
        XCTAssertTrue(sut?.url?.host == "chat-gateway-de-na1.niceincontact.com")
    }
    
    func testPathIsEmpty() {
        XCTAssertTrue(sut?.url?.path.isEmpty ?? true)
    }
    
    func testQuesyItemsNotNil() throws {
        guard let query = sut?.url?.query else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertFalse(query.isEmpty)
    }
    
    func testNumberOfQItemsMatch() {
        let number = sut?.url?.query?.components(separatedBy: "&").count
        let queryNumeber = sut?.queryItems.count
        
        XCTAssertTrue(sut?.queryItems.count == 7)
        XCTAssertTrue(number == 7)
        XCTAssertTrue(number == queryNumeber)
    }
    
    func testMethodIsGet() throws {
        let request = try sut?.urlRequest()
        
        XCTAssertNotNil(request)
    }
    
    func testAdditionalHeadersAreFilled() throws {
        let request = try sut?.urlRequest()
        
        XCTAssertTrue(request?.allHTTPHeaderFields?["x-sdk-platform"] == "ios")
        XCTAssertTrue(request?.allHTTPHeaderFields?["x-sdk-version"] == CXoneChatSDKModule.version)
    }
    
    func testEndpointWithChatValue() throws {
        sut = MockEndpoint(environment: Environment.EU1, queryItems: [], method: .post)
        
        guard let url = sut?.url else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertNotNil(url)
        XCTAssertNoThrow(try sut?.urlRequest())
        XCTAssertTrue(url.scheme == "https")
        XCTAssertTrue(url.host == "channels-de-eu1.niceincontact.com", "host is \(url.host?.description ?? "unknown")")
        XCTAssertFalse(url.path.isEmpty)
        XCTAssertTrue(url.path == "/chat", "\(url.path) not equal to chat")
        XCTAssertTrue(((url.query?.isEmpty) != nil))
    }
    
}

struct MockEndpoint: Endpoint {
    
    var environment: EnvironmentDetails
    
    var queryItems: [URLQueryItem]
    
    var method: HTTPMethod
}
