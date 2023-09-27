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

import KeychainSwift
import XCTest
@testable import CXoneChatSDK

class CustomerProviderTests: CXoneXCTestCase {
    
    // MARK: - Properties
    
    // swiftlint:disable:next force_cast
    private lazy var customerProvider = CXoneChat.customer as! CustomerService
    
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
        XCTAssertEqual(customerProvider.connectionContext.deviceToken, "")
    }
    
    func testSetStringDeviceToken() {
        CXoneChat.customer.setDeviceToken("device_token")
        
        XCTAssertEqual(customerProvider.connectionContext.deviceToken, "device_token")
    }
    
    func testSetDataDeviceToken() throws {
        guard let data = "device_token".data(using: .utf8) else {
            throw CXoneChatError.missingParameter("data")
        }
        
        CXoneChat.customer.setDeviceToken(data)
        
        XCTAssertEqual(customerProvider.connectionContext.deviceToken, "6465766963655f746f6b656e")
    }
    
    func testEmptyAuthCode() {
        XCTAssertEqual(customerProvider.connectionContext.authorizationCode, "")
    }
    
    func testSetAuthCode() {
        CXoneChat.customer.setAuthorizationCode("auth_code")
        
        XCTAssertEqual(customerProvider.connectionContext.authorizationCode, "auth_code")
    }
    
    func testEmptyCodeVerifier() {
        XCTAssertEqual(customerProvider.connectionContext.codeVerifier, "")
    }
    
    func testSetCodeVerifier() {
        CXoneChat.customer.setCodeVerifier("verifier")
        
        XCTAssertEqual(customerProvider.connectionContext.codeVerifier, "verifier")
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
        guard let service = CXoneChat.customerCustomFields as? CustomerCustomFieldsService else {
            throw CXoneChatError.missingParameter("service")
        }
        
        service.customerFields = [
            .textField(CustomFieldTextFieldDTO(ident: "email", label: "E-mail", value: nil, updatedAt: .distantFuture, isEmail: true)),
            .textField(CustomFieldTextFieldDTO(ident: "age", label: "Age", value: "34", updatedAt: dateProvider.now, isEmail: false))
        ]
        
        try CXoneChat.customerCustomFields.set(["email": "john.doe@gmail.com"])
        
        XCTAssertEqual((CXoneChat.customerCustomFields.get() as [CustomFieldType]).count, 2)
    }
}
