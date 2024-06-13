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

import XCTest
@testable import CXoneChatSDK

class CustomerProviderTests: CXoneXCTestCase {
    
    // MARK: - Lifecycle
    
    override func setUp() async throws {
        try await super.setUp()
        
        try await setUpConnection()
    }
    
    // MARK: - Tests
    
    func testSetUser() {
        CXoneChat.customer.set(CustomerIdentity(id: UUID().uuidString, firstName: "John", lastName: "Doe"))
        
        XCTAssertNotNil(CXoneChat.customer.get())
    }
    
    func testEmptyDeviceToken() {
        XCTAssertNil(connectionContext.deviceToken)
    }
    
    func testSetStringDeviceToken() {
        CXoneChat.customer.setDeviceToken("device_token")
        
        XCTAssertEqual(connectionContext.deviceToken, "device_token")
    }
    
    func testSetDataDeviceToken() throws {
        CXoneChat.customer.setDeviceToken("device_token".data(using: .utf8)!)
        
        XCTAssertEqual(connectionContext.deviceToken, "6465766963655f746f6b656e")
    }
    
    func testEmptyAuthCode() {
        XCTAssertEqual(connectionContext.authorizationCode, "")
    }
    
    func testSetAuthCode() {
        CXoneChat.customer.setAuthorizationCode("auth_code")
        
        XCTAssertEqual(connectionContext.authorizationCode, "auth_code")
    }
    
    func testEmptyCodeVerifier() {
        XCTAssertEqual(connectionContext.codeVerifier, "")
    }
    
    func testSetCodeVerifier() {
        CXoneChat.customer.setCodeVerifier("verifier")
        
        XCTAssertEqual(connectionContext.codeVerifier, "verifier")
    }
    
    func testSetCustomerNameForEmptyCustomer() {
        CXoneChat.customer.setName(firstName: "John", lastName: "Doe")
        
        XCTAssertNotNil(CXoneChat.customer.get())
        XCTAssertEqual(CXoneChat.customer.get()?.firstName, "John")
        XCTAssertEqual(CXoneChat.customer.get()?.lastName, "Doe")
    }
    
    func testUpdateCustomerName() {
        CXoneChat.customer.set(CustomerIdentity(id: UUID().uuidString, firstName: "John", lastName: "Doe"))
        
        CXoneChat.customer.setName(firstName: "Peter", lastName: "Parker")
        
        XCTAssertNotNil(CXoneChat.customer.get())
        XCTAssertEqual(CXoneChat.customer.get()?.firstName, "Peter")
        XCTAssertEqual(CXoneChat.customer.get()?.lastName, "Parker")
    }
    
    func testCustomerCustomFieldsDontOverride() throws {
        customerFieldsService.customerFields = [
            CustomFieldDTO(ident: "email", value: "", updatedAt: .distantFuture),
            CustomFieldDTO(ident: "age", value: "34", updatedAt: dateProvider.now)
        ]
        
        try CXoneChat.customerCustomFields.set(["email": "john.doe@gmail.com"])
        
        XCTAssertEqual(CXoneChat.customerCustomFields.get().count, 2)
    }
}
