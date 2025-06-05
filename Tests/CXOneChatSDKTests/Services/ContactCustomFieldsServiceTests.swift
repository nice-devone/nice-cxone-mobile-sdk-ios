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
class ContactCustomFieldsServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    private let socketService = MockSocketService()
    private let connectionContext = MockConnectionContext()
    private let uuidProvider = MockUUIDProvider()
    private let subject = PassthroughSubject<ReceivedEvent, Never>()
    
    private lazy var events = subject.eraseToAnyPublisher()
    private lazy var eventsService = EventsService(connectionContext: connectionContext)
    
    private static let brandId = 1386
    private static let channelId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
    private static let visitorId = UUID()
    private static let dayInterval: Double = 86_400
    private static let testDictionary = ["gender": "Male"]
    
    var service: ContactCustomFieldsService?
    
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
        
        service = ContactCustomFieldsService(socketService: socketService, eventsService: eventsService)
        
        UUID.provider = uuidProvider
    }
    
    // MARK: - Tests

    func testSetContactFieldsThrowsNotConnected() async {
        let thread = MockData.getThread()
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .checkForConnection().willThrow(CXoneChatError.notConnected)
        
        await XCTAssertAsyncThrowsError(try await service!.set(Self.testDictionary, for: thread.id)) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, .notConnected)
        }
    }
    
    func testSetContactFieldsWithoutContactIdNoThrow() async throws {
        let thread = MockData.getThread()
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
            .contactId.willReturn(nil)
        
        given(socketService)
            .checkForConnection().willReturn()
        
        try await service!.set(Self.testDictionary, for: thread.id)
        
        XCTAssertEqual(service!.contactFields.count, 1)
        XCTAssertEqual(service!.get(for: thread.id), Self.testDictionary)
        XCTAssertEqual(
            service!.get(for: thread.id),
            Dictionary<String, String>(uniqueKeysWithValues: [MockData.genderSelectorCustomField].map { ($0.ident, $0.value ?? "") })
        )
    }
    
    func testSetContactFieldsWithContactIdNoThrow() async throws {
        let contactId = UUID()
        let thread = MockData.getThread()
        
        given(uuidProvider)
            .next.willReturn(contactId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
            .contactId.willReturn(UUID.provide().uuidString)
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        try await service!.set(Self.testDictionary, for: thread.id)
        
        XCTAssertEqual(service!.contactFields.count, 1)
        XCTAssertEqual(service!.get(for: thread.id), Self.testDictionary)
        XCTAssertEqual(
            service!.get(for: thread.id),
            Dictionary<String, String>(uniqueKeysWithValues: [MockData.genderSelectorCustomField].map { ($0.ident, $0.value ?? "") })
        )
    }
    
    func testGetContactFieldsForMultipleThreadsSuccess() async throws {
        let contactId = UUID()
        let threadA = ChatThread(id: UUID(), state: .ready)
        let threadB = ChatThread(id: UUID(), state: .ready)
        
        let dictionaryA = ["firstName": "Peter"]
        let dataA = Dictionary<String, String>(uniqueKeysWithValues: [MockData.nameTextCustomField].map { ($0.ident, $0.value ?? "") })
        let dictionaryB = ["email": "peter.parker@gmail.com"]
        let dataB = Dictionary<String, String>(uniqueKeysWithValues: [MockData.emailTextCustomField].map { ($0.ident, $0.value ?? "") })
        
        given(uuidProvider)
            .next.willReturn(contactId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
            .contactId.willReturn(UUID.provide().uuidString)
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        try await service!.set(dictionaryA, for: threadA.id)
        try await service!.set(dictionaryB, for: threadB.id)
        
        XCTAssertEqual(service!.get(for: threadA.id), dataA)
        XCTAssertEqual(service!.get(for: threadB.id), dataB)
    }

    func testUpdateContactCustomFields() async throws {
        let contactId = UUID()
        let threadId = UUID()
        
        given(uuidProvider)
            .next.willReturn(contactId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
            .contactId.willReturn(UUID.provide().uuidString)
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        service!.updateFields(
            [
                CustomFieldDTO(ident: "firstName", value: "John", updatedAt: Date.provide()),
                CustomFieldDTO(ident: "email", value: "john.doe@gmail.com", updatedAt: Date.provide().addingTimeInterval(-Self.dayInterval))
            ],
            for: threadId
        )
        
        let newCustomFields: [CustomFieldDTO] = [
            CustomFieldDTO(ident: "firstName", value: "Johnnie", updatedAt: Date.provide().addingTimeInterval(-Self.dayInterval)),
            CustomFieldDTO(ident: "email", value: "john.doe2@gmail.com", updatedAt: Date.provide())
        ]
        
        service!.updateFields(newCustomFields, for: threadId)
        
        XCTAssertEqual(service!.contactFields[threadId]?.first(where: { $0.ident == "firstName" })?.value, "John")
        XCTAssertEqual(service!.contactFields[threadId]?.first(where: { $0.ident == "email" })?.value, "john.doe2@gmail.com")
    }
}
