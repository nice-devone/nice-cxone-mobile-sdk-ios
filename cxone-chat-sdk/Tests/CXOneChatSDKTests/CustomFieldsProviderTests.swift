import XCTest
@testable import CXoneChatSDK

class CustomFieldsProviderTests: CXoneXCTestCase {
    
    // MARK: - Properties
    
    private let dayInterval: Double = 86_400
    
    private let testDictionary = ["department": "Sales"]
    private lazy var testTextfieldType: CustomFieldType = .textField(
        CustomFieldTextField(ident: "department", label: "Department", value: "Sales", isEmail: false, updatedAt: dateProvider.now)
    )
    
    private let testThread = ChatThread(id: UUID())
    
    // MARK: - Tests

    func testSetContactFieldsThrowsNoConnected() {
        XCTAssertThrowsError(try CXoneChat.threads.customFields.set(testDictionary, for: testThread.id))
    }
    
    func testSetContactFieldsNoThrow() async throws {
        try await setUpConnection()
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(testDictionary, for: testThread.id))
    }
    
    func testSetContactFieldsNoThrowWithContactId() async throws {
        try await setUpConnection()
        
        (CXoneChat.connection as? ConnectionService)?.connectionContext.contactId = "contact_id"
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(testDictionary, for: testThread.id))
    }
    
    func testSetCustomerFieldsThrowsNoConnected() {
        XCTAssertThrowsError(try CXoneChat.customerCustomFields.set(testDictionary))
    }
    
    func testSetCustomerFieldsNoThrow() async throws {
        try await setUpConnection()
        
        XCTAssertNoThrow(try CXoneChat.customerCustomFields.set(testDictionary))
    }
    
    func testSetCustomerFieldsDontAdd() async throws {
        try await setUpConnection()
        
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [CustomFieldTypeMapper.map(from: testTextfieldType)],
            customerCustomFieldDefinitions: []
        )
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(["key": "value"], for: testThread.id))
        XCTAssertTrue((CXoneChat.threads.customFields.get(for: testThread.id) as [CustomFieldType]).isEmpty)
    }
    
    func testSetContactFieldsDontAdd() async throws {
        try await setUpConnection()
        
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: [CustomFieldTypeMapper.map(from: testTextfieldType)]
        )
        
        XCTAssertNoThrow(try CXoneChat.customerCustomFields.set(["key": "value"]))
        XCTAssertTrue((CXoneChat.customerCustomFields.get() as [CustomFieldType]).isEmpty)
    }
    
    func testGetContactFieldsForSingleThread() async throws {
        try await setUpConnection()
        
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [CustomFieldTypeMapper.map(from: testTextfieldType)],
            customerCustomFieldDefinitions: []
        )
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(testDictionary, for: testThread.id))
        XCTAssertEqual(CXoneChat.threads.customFields.get(for: testThread.id), [testTextfieldType])
    }
    
    func testGetContactFieldsForMultiThread() async throws {
        let threadA = ChatThread(id: UUID())
        let threadB = ChatThread(id: UUID())
        
        let dictionaryA = ["key": "threadA"]
        let dataA: [CustomFieldType] = [
            .textField(CustomFieldTextField(ident: "key", label: "Key", value: "threadA", isEmail: false, updatedAt: dateProvider.now))
        ]
        let dictionaryB = ["key": "threadB"]
        let dataB: [CustomFieldType] = [
            .textField(CustomFieldTextField(ident: "key", label: "Key", value: "threadB", isEmail: false, updatedAt: dateProvider.now))
        ]
        
        try await setUpConnection()
        
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [
                .textField(CustomFieldTextFieldDTO(ident: "key", label: "Key", value: nil, updatedAt: dateProvider.now, isEmail: false))
            ],
            customerCustomFieldDefinitions: []
        )
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(dictionaryA, for: threadA.id))
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(dictionaryB, for: threadB.id))
        
        XCTAssertEqual(CXoneChat.threads.customFields.get(for: threadA.id), dataA)
        XCTAssertEqual(CXoneChat.threads.customFields.get(for: threadB.id), dataB)
    }
    
    func testUpdateCustomerCustomFields() throws {
        guard let service = CXoneChat.customerCustomFields as? CustomerCustomFieldsService else {
            throw XCTError("Could not get customer custom fields service")
        }
        
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: [
                .textField(CustomFieldTextFieldDTO(ident: "key1", label: "Key 1", value: nil, updatedAt: .distantPast, isEmail: false)),
                .textField(CustomFieldTextFieldDTO(ident: "key2", label: "Key 2", value: nil, updatedAt: .distantPast, isEmail: false)),
                .textField(CustomFieldTextFieldDTO(ident: "key3", label: "Key 3", value: nil, updatedAt: .distantPast, isEmail: false))
            ]
        )
        
        service.updateFields([
            CustomFieldDTO(ident: "key1", value: "value1", updatedAt: dateProvider.now),
            CustomFieldDTO(ident: "key2", value: "value2", updatedAt: dateProvider.now.addingTimeInterval(-dayInterval)),
            CustomFieldDTO(ident: "key3", value: "value3", updatedAt: dateProvider.now.addingTimeInterval(-dayInterval))
        ])
        
        let newCustomFields: [CustomFieldDTO] = [
            CustomFieldDTO(ident: "key1", value: "newValue1", updatedAt: dateProvider.now.addingTimeInterval(-dayInterval)),
            CustomFieldDTO(ident: "key2", value: "newValue2", updatedAt: dateProvider.now)
        ]
        
        service.updateFields(newCustomFields)
        
        XCTAssertEqual(service.customerFields.count, 3)
        XCTAssertEqual(service.customerFields.first(where: { $0.ident == "key1" })?.value, "value1")
        XCTAssertEqual(service.customerFields.first(where: { $0.ident == "key2" })?.value, "newValue2")
        XCTAssertEqual(service.customerFields.first(where: { $0.ident == "key3" })?.value, "value3")
    }
    
    func testUpdateContactCustomFields() throws {
        guard let service = CXoneChat.threads.customFields as? ContactCustomFieldsService else {
            throw XCTError("Could not get customer custom fields service")
        }
        
        let threadId = UUID()
        
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [
                .textField(CustomFieldTextFieldDTO(ident: "key1", label: "Key 1", value: nil, updatedAt: .distantPast, isEmail: false)),
                .textField(CustomFieldTextFieldDTO(ident: "key2", label: "Key 2", value: nil, updatedAt: .distantPast, isEmail: false))
            ],
            customerCustomFieldDefinitions: []
        )
        
        service.updateFields(
            [
                CustomFieldDTO(ident: "key1", value: "value1", updatedAt: dateProvider.now),
                CustomFieldDTO(ident: "key2", value: "value2", updatedAt: dateProvider.now.addingTimeInterval(-dayInterval))
            ],
            for: threadId
        )
        
        let newCustomFields: [CustomFieldDTO] = [
            CustomFieldDTO(ident: "key1", value: "newValue1", updatedAt: dateProvider.now.addingTimeInterval(-dayInterval)),
            CustomFieldDTO(ident: "key2", value: "newValue2", updatedAt: dateProvider.now)
        ]
        
        service.updateFields(newCustomFields, for: threadId)
        
        XCTAssertEqual(service.contactFields[threadId]?.first(where: { $0.ident == "key1" })?.value, "value1")
        XCTAssertEqual(service.contactFields[threadId]?.first(where: { $0.ident == "key2" })?.value, "newValue2")
    }
}
