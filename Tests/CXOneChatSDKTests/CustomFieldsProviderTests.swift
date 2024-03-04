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
    
    func testSetCustomerFieldsDontAdd() async throws {
        try await setUpConnection(contactCustomFields: [.selector(MockData.genderSelectorCustomField)])
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(["key": "value"], for: testThread.idOnExternalPlatform))
        XCTAssertTrue((CXoneChat.threads.customFields.get(for: testThread.idOnExternalPlatform) as [CustomFieldType]).isEmpty)
    }
    
    func testSetContactFieldsDontAdd() async throws {
        try await setUpConnection(customerCustomFields: [.selector(MockData.genderSelectorCustomField)])
        
        XCTAssertNoThrow(try CXoneChat.customerCustomFields.set(["key": "value"]))
        XCTAssertTrue((CXoneChat.customerCustomFields.get() as [CustomFieldType]).isEmpty)
    }
    
    func testGetContactFieldsForSingleThread() async throws {
        try await setUpConnection(contactCustomFields: [.selector(MockData.genderSelectorCustomField)])
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(testDictionary, for: testThread.idOnExternalPlatform))
        XCTAssertEqual(
            CXoneChat.threads.customFields.get(for: testThread.idOnExternalPlatform),
            [CustomFieldTypeMapper.map(from: .selector(MockData.genderSelectorCustomField))]
        )
    }
    
    func testGetContactFieldsForMultiThread() async throws {
        let threadA = ChatThread(id: UUID(), state: .ready)
        let threadB = ChatThread(id: UUID(), state: .ready)
        
        let dictionaryA = ["firstName": "Peter"]
        let dataA: [CustomFieldType] = [CustomFieldTypeMapper.map(from: .textField(MockData.nameTextCustomField))]
        let dictionaryB = ["email": "peter.parker@gmail.com"]
        let dataB: [CustomFieldType] = [CustomFieldTypeMapper.map(from: .textField(MockData.emailTextCustomField))]
        
        try await setUpConnection(isMultithread: true, contactCustomFields: [
            .textField(MockData.nameTextCustomField),
            .textField(MockData.emailTextCustomField)
        ])
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(dictionaryA, for: threadA.id))
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(dictionaryB, for: threadB.id))
        
        XCTAssertEqual(CXoneChat.threads.customFields.get(for: threadA.id), dataA)
        XCTAssertEqual(CXoneChat.threads.customFields.get(for: threadB.id), dataB)
    }
    
    func testUpdateCustomerCustomFields() async throws {
        try await setUpConnection(isMultithread: true, customerCustomFields: [
            .textField(CustomFieldTextFieldDTO(ident: "key1", label: "Key 1", value: nil, updatedAt: .distantPast, isEmail: false)),
            .textField(CustomFieldTextFieldDTO(ident: "key2", label: "Key 2", value: nil, updatedAt: .distantPast, isEmail: false)),
            .textField(CustomFieldTextFieldDTO(ident: "key3", label: "Key 3", value: nil, updatedAt: .distantPast, isEmail: false))
        ])
        
        customerFieldsService.updateFields([
            CustomFieldDTO(ident: "key1", value: "value1", updatedAt: dateProvider.now),
            CustomFieldDTO(ident: "key2", value: "value2", updatedAt: dateProvider.now.addingTimeInterval(-dayInterval)),
            CustomFieldDTO(ident: "key3", value: "value3", updatedAt: dateProvider.now.addingTimeInterval(-dayInterval))
        ])
        
        let newCustomFields: [CustomFieldDTO] = [
            CustomFieldDTO(ident: "key1", value: "newValue1", updatedAt: dateProvider.now.addingTimeInterval(-dayInterval)),
            CustomFieldDTO(ident: "key2", value: "newValue2", updatedAt: dateProvider.now)
        ]
        
        customerFieldsService.updateFields(newCustomFields)
        
        XCTAssertEqual(customerFieldsService.customerFields.count, 3)
        XCTAssertEqual(customerFieldsService.customerFields.first(where: { $0.ident == "key1" })?.value, "value1")
        XCTAssertEqual(customerFieldsService.customerFields.first(where: { $0.ident == "key2" })?.value, "newValue2")
        XCTAssertEqual(customerFieldsService.customerFields.first(where: { $0.ident == "key3" })?.value, "value3")
    }
    
    func testUpdateContactCustomFields() async throws {
        try await setUpConnection(isMultithread: true, contactCustomFields: [
            .textField(MockData.nameTextCustomField),
            .textField(MockData.emailTextCustomField)
        ])
        let threadId = UUID()
        
        contactFieldsService.updateFields(
            [
                CustomFieldDTO(ident: "firstName", value: "John", updatedAt: dateProvider.now),
                CustomFieldDTO(ident: "email", value: "john.doe@gmail.com", updatedAt: dateProvider.now.addingTimeInterval(-dayInterval))
            ],
            for: threadId
        )
        
        let newCustomFields: [CustomFieldDTO] = [
            CustomFieldDTO(ident: "firstName", value: "Johnnie", updatedAt: dateProvider.now.addingTimeInterval(-dayInterval)),
            CustomFieldDTO(ident: "email", value: "john.doe2@gmail.com", updatedAt: dateProvider.now)
        ]
        
        contactFieldsService.updateFields(newCustomFields, for: threadId)
        
        XCTAssertEqual(contactFieldsService.contactFields[threadId]?.first(where: { $0.ident == "firstName" })?.value, "John")
        XCTAssertEqual(contactFieldsService.contactFields[threadId]?.first(where: { $0.ident == "email" })?.value, "john.doe2@gmail.com")
    }
}
