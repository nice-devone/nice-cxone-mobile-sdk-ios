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

class CustomFieldsProviderTests: CXoneXCTestCase {
    
    // MARK: - Properties
    
    private let dayInterval: Double = 86_400
    private let testDictionary = ["gender": "Male"]
    private let testThread = MockData.getThread()
    
    // MARK: - Tests

    func testSetContactFieldsThrowsNoConnected() {
        XCTAssertThrowsError(try CXoneChat.threads.customFields.set(testDictionary, for: testThread.idOnExternalPlatform))
    }
    
    func testSetContactFieldsNoThrow() async throws {
        try await setUpConnection()
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(testDictionary, for: testThread.idOnExternalPlatform))
    }
    
    func testSetContactFieldsNoThrowWithContactId() async throws {
        try await setUpConnection()
        
        connectionService.connectionContext.contactId = "contact_id"
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(testDictionary, for: testThread.idOnExternalPlatform))
    }
    
    func testSetCustomerFieldsThrowsNoConnected() {
        XCTAssertThrowsError(try CXoneChat.customerCustomFields.set(testDictionary))
    }
    
    func testSetCustomerFieldsNoThrow() async throws {
        try await setUpConnection()
        
        XCTAssertNoThrow(try CXoneChat.customerCustomFields.set(testDictionary))
    }
    
    func testGetContactFieldsForSingleThread() async throws {
        try await setUpConnection()
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(testDictionary, for: testThread.idOnExternalPlatform))
        XCTAssertEqual(
            CXoneChat.threads.customFields.get(for: testThread.idOnExternalPlatform),
            Dictionary<String, String>(uniqueKeysWithValues: [MockData.genderSelectorCustomField].map { ($0.ident, $0.value ?? "") })
        )
    }
    
    func testGetContactFieldsForMultiThread() async throws {
        let threadA = ChatThread(id: LowercaseUUID().uuidString, state: .ready)
        let threadB = ChatThread(id: LowercaseUUID().uuidString, state: .ready)
        
        let dictionaryA = ["firstName": "Peter"]
        let dataA = Dictionary<String, String>(uniqueKeysWithValues: [MockData.nameTextCustomField].map { ($0.ident, $0.value ?? "") })
        let dictionaryB = ["email": "peter.parker@gmail.com"]
        let dataB = Dictionary<String, String>(uniqueKeysWithValues: [MockData.emailTextCustomField].map { ($0.ident, $0.value ?? "") })
        
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(isMultithread: true))
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(dictionaryA, for: threadA.idString))
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(dictionaryB, for: threadB.idString))
        
        XCTAssertEqual(CXoneChat.threads.customFields.get(for: threadA.idString), dataA)
        XCTAssertEqual(CXoneChat.threads.customFields.get(for: threadB.idString), dataB)
    }
    
    func testUpdateCustomerCustomFields() async throws {
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(isMultithread: true))
        
        customerFieldsService.updateFields([
            CustomFieldDTO(ident: "key1", value: "value1", updatedAt: Date.provide()),
            CustomFieldDTO(ident: "key2", value: "value2", updatedAt: Date.provide().addingTimeInterval(-dayInterval)),
            CustomFieldDTO(ident: "key3", value: "value3", updatedAt: Date.provide().addingTimeInterval(-dayInterval))
        ])
        
        let newCustomFields: [CustomFieldDTO] = [
            CustomFieldDTO(ident: "key1", value: "newValue1", updatedAt: Date.provide().addingTimeInterval(-dayInterval)),
            CustomFieldDTO(ident: "key2", value: "newValue2", updatedAt: Date.provide())
        ]
        
        customerFieldsService.updateFields(newCustomFields)
        
        XCTAssertEqual(customerFieldsService.customerFields.count, 3)
        XCTAssertEqual(customerFieldsService.customerFields.first(where: { $0.ident == "key1" })?.value, "value1")
        XCTAssertEqual(customerFieldsService.customerFields.first(where: { $0.ident == "key2" })?.value, "newValue2")
        XCTAssertEqual(customerFieldsService.customerFields.first(where: { $0.ident == "key3" })?.value, "value3")
    }
    
    func testUpdateContactCustomFields() async throws {
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(isMultithread: true))
        
        let threadId = LowercaseUUID().uuidString
        
        contactFieldsService.updateFields(
            [
                CustomFieldDTO(ident: "firstName", value: "John", updatedAt: Date.provide()),
                CustomFieldDTO(ident: "email", value: "john.doe@gmail.com", updatedAt: Date.provide().addingTimeInterval(-dayInterval))
            ],
            for: threadId
        )
        
        let newCustomFields: [CustomFieldDTO] = [
            CustomFieldDTO(ident: "firstName", value: "Johnnie", updatedAt: Date.provide().addingTimeInterval(-dayInterval)),
            CustomFieldDTO(ident: "email", value: "john.doe2@gmail.com", updatedAt: Date.provide())
        ]
        
        contactFieldsService.updateFields(newCustomFields, for: threadId)
        
        XCTAssertEqual(contactFieldsService.contactFields[threadId]?.first(where: { $0.ident == "firstName" })?.value, "John")
        XCTAssertEqual(contactFieldsService.contactFields[threadId]?.first(where: { $0.ident == "email" })?.value, "john.doe2@gmail.com")
    }
}
