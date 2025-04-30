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
class CustomerCustomFieldsServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    private let socketService = MockSocketService()
    private let connectionContext = MockConnectionContext()
    private let uuidProvider = MockUUIDProvider()
    private let subject = PassthroughSubject<ReceivedEvent, Never>()
    
    private lazy var events = subject.eraseToAnyPublisher()
    private lazy var eventsService = EventsService(connectionContext: connectionContext)
    
    private static let brandId = 1386
    private static let channelId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
    private static let chatURL = "https://channels-de-na1.niceincontact.com/chat"
    private static let channelURL = "https://channels-de-na1.niceincontact.com/chat/1.0/brand/1386/channel"
    private static let socketURL = "wss://chat-gateway-de-na1.niceincontact.com"
    private static let visitorId = UUID()
    private static let dayInterval: Double = 86_400
    private static let testDictionary = ["gender": "Male"]
    
    var service: CustomerCustomFieldsService?
    
    // MARK: - Lifecycle
    
    override func setUp() {
        given(socketService)
            .events.willReturn(events)
            .connectionContext.willReturn(connectionContext)

        given(connectionContext)
            .brandId.willReturn(Self.brandId)
            .channelId.willReturn(Self.channelId)
            .visitorId.willReturn(Self.visitorId)
            .customer.willReturn(MockData.customerIdentity)
        
        service = CustomerCustomFieldsService(socketService: socketService, eventsService: eventsService)
        
        UUID.provider = uuidProvider
    }
    
    // MARK: - Tests
    
    func testSetCustomerFieldsThrowsNotConnected() async {
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .checkForConnection().willThrow(CXoneChatError.notConnected)
        
        await XCTAssertAsyncThrowsError(try await service!.set(Self.testDictionary)) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, .notConnected)
        }
    }
    
    func testSetCustomerFieldsNoThrow() async throws {
        given(uuidProvider)
            .next.willReturn(UUID())
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        try await service!.set(Self.testDictionary)
        
        XCTAssertEqual(service!.customerFields.count, 1)
        XCTAssertEqual(service!.get(), Self.testDictionary)
        XCTAssertEqual(
            service!.get(),
            Dictionary<String, String>(uniqueKeysWithValues: [MockData.genderSelectorCustomField].map { ($0.ident, $0.value ?? "") })
        )
    }

    func testUpdateCustomerCustomFieldsSuccess() async throws {
        given(uuidProvider)
            .next.willReturn(UUID())
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        service!.updateFields([
            CustomFieldDTO(ident: "key1", value: "value1", updatedAt: Date.provide()),
            CustomFieldDTO(ident: "key2", value: "value2", updatedAt: Date.provide().addingTimeInterval(-Self.dayInterval)),
            CustomFieldDTO(ident: "key3", value: "value3", updatedAt: Date.provide().addingTimeInterval(-Self.dayInterval))
        ])
        
        let newCustomFields: [CustomFieldDTO] = [
            CustomFieldDTO(ident: "key1", value: "newValue1", updatedAt: Date.provide().addingTimeInterval(-Self.dayInterval)),
            CustomFieldDTO(ident: "key2", value: "newValue2", updatedAt: Date.provide())
        ]
        
        service!.updateFields(newCustomFields)
        
        XCTAssertEqual(service!.customerFields.count, 3)
        XCTAssertEqual(service!.customerFields.first(where: { $0.ident == "key1" })?.value, "value1")
        XCTAssertEqual(service!.customerFields.first(where: { $0.ident == "key2" })?.value, "newValue2")
        XCTAssertEqual(service!.customerFields.first(where: { $0.ident == "key3" })?.value, "value3")
    }
}
