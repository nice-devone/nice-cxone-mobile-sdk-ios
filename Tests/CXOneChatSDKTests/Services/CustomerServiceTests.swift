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
@testable import CXoneChatSDK
import Mockable
import XCTest

@available(iOS 16.0, *)
class CustomerServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    private let threads = MockChatThreadListProvider()
    private let socketService = MockSocketService()
    private let connectionContext = MockConnectionContext()
    private let dateProvider = DateProviderMock()
    private let uuidProvider = MockUUIDProvider()
    private let subject = PassthroughSubject<ReceivedEvent, Never>()
    private let delegate = MockCXoneChatDelegate()
    
    private var service: CustomerService?
    
    private lazy var events = subject.eraseToAnyPublisher()
    private lazy var eventsService = EventsService(connectionContext: connectionContext)
    
    // MARK: - Lifecycle
    
    override func setUp() {
        given(socketService)
            .connectionContext.willReturn(connectionContext)
        
        self.service = CustomerService(
            socketService: socketService,
            threads: threads,
            delegate: delegate
        )
    }
    
    // MARK: - Tests
    
    func testSetCustomerThrowsIllegalChatState() throws {
        let customerId = UUID()
        
        given(connectionContext)
            .chatState.willReturn(.connected)
        
        XCTAssertThrowsError(try service!.set(customer: CustomerIdentity(id: customerId.uuidString, firstName: "John", lastName: "Doe")))
    }
    
    func testSetUserIdentityNoThrow() throws {
        let customerId = UUID()
        let customerIdentity = CustomerIdentity(id: customerId.uuidString, firstName: "John", lastName: "Doe")
        
        given(connectionContext)
            .chatState.willReturn(.initial)
            .customer.willReturn(CustomerIdentityMapper.map(customerIdentity))
        
        try service!.set(customer: customerIdentity)
        
        let customer = service!.get()
        
        XCTAssertNotNil(customer)
        XCTAssertEqual(customer?.id, customerId.uuidString)
        XCTAssertEqual(customer?.firstName, "John")
        XCTAssertEqual(customer?.lastName, "Doe")
    }
    
    func testSetStringDeviceToken() {
        var deviceToken: String?
        
        given(connectionContext)
            .deviceToken.willProduce { deviceToken }
        
        XCTAssertNil(connectionContext.deviceToken)
        
        service!.setDeviceToken("device_token")
        deviceToken = "device_token"
        
        XCTAssertEqual(connectionContext.deviceToken, "device_token")
    }
    
    func testSetAuthCode() {
        var authorizationCode = ""
        
        given(connectionContext)
            .authorizationCode.willProduce { authorizationCode }
        
        XCTAssertEqual(connectionContext.authorizationCode, "")
        
        service!.setAuthorizationCode("auth_code")
        authorizationCode = "auth_code"
        
        XCTAssertEqual(connectionContext.authorizationCode, "auth_code")
    }
    
    func testSetCodeVerifier() {
        var codeVerifier = ""
        
        given(connectionContext)
            .codeVerifier.willProduce { codeVerifier }
        
        XCTAssertEqual(connectionContext.codeVerifier, "")
        
        service!.setCodeVerifier("code_verifier")
        codeVerifier = "code_verifier"
        
        XCTAssertEqual(connectionContext.codeVerifier, "code_verifier")
    }
    
    func testSetCustomerNameForEmptyCustomer() {
        given(connectionContext)
            .customer.willReturn(nil)
        
        service!.setName(firstName: "John", lastName: "Doe")
        
        XCTAssertNil(service!.get())
    }
    
    func testUpdateCustomerName() throws {
        let customerId = UUID()
        let customerIdentity = CustomerIdentityDTO(idOnExternalPlatform: customerId.uuidString, firstName: "Peter", lastName: "Parker")
        
        given(connectionContext)
            .customer.willReturn(customerIdentity)
        
        service!.setName(firstName: "Peter", lastName: "Parker")
        
        XCTAssertNotNil(service!.get())
        XCTAssertEqual(service!.get()?.id, customerId.uuidString)
        XCTAssertEqual(service!.get()?.firstName, "Peter")
        XCTAssertEqual(service!.get()?.lastName, "Parker")
    }
}
