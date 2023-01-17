import XCTest
@testable import CXoneChatSDK


class CustomFieldsProviderTests: CXoneXCTestCase {
    
    // MARK: - Properties
    
    private let dayInterval: Double = 86_400
    
    private let testData = ["key": "value"]
    private let testThread = ChatThread(id: UUID())
    
    
    // MARK: - Tests

    func testSetContactFieldsThrowsNoConnected() {
        XCTAssertThrowsError(try CXoneChat.threads.customFields.set(testData, for: testThread.id))
    }
    
    func testSetContactFieldsNoThrow() async throws {
        try await CXoneChat.connection.connect(environment: .NA1, brandId: brandId, channelId: channelId)
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(testData, for: testThread.id))
    }
    
    func testSetContactFieldsNoThrowWithContactId() async throws {
        try await CXoneChat.connection.connect(environment: .NA1, brandId: brandId, channelId: channelId)
        
        (CXoneChat.connection as? ConnectionService)?.connectionContext.contactId = "contact_id"
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(testData, for: testThread.id))
    }
    
    func testSetCustomerFieldsThrowsNoConnected() {
        XCTAssertThrowsError(try CXoneChat.customerCustomFields.set(testData))
    }
    
    func testSetCustomerFieldsNoThrow() async throws {
        try await CXoneChat.connection.connect(environment: .NA1, brandId: brandId, channelId: channelId)
        
        XCTAssertNoThrow(try CXoneChat.customerCustomFields.set(testData))
    }
    
    func testGetContactFieldsForSingleThread() async throws {
        try await CXoneChat.connection.connect(environment: .NA1, brandId: brandId, channelId: channelId)
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(testData, for: testThread.id))
        
        XCTAssertEqual(CXoneChat.threads.customFields.get(for: testThread.id), testData)
    }
    
    func testGetContactFieldsForMultiThread() async throws {
        let threadA = ChatThread(id: UUID())
        let threadB = ChatThread(id: UUID())
        
        let dataA = ["key": "threadA"]
        let dataB = ["key": "threadB"]
        
        try await CXoneChat.connection.connect(environment: .NA1, brandId: brandId, channelId: channelId)
        
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(dataA, for: threadA.id))
        XCTAssertNoThrow(try CXoneChat.threads.customFields.set(dataB, for: threadB.id))
        
        XCTAssertNotEqual(
            CXoneChat.threads.customFields.get(for: threadA.id),
            CXoneChat.threads.customFields.get(for: threadB.id)
        )
        XCTAssertEqual(CXoneChat.threads.customFields.get(for: threadA.id), dataA)
        XCTAssertEqual(CXoneChat.threads.customFields.get(for: threadB.id), dataB)
    }
    
    func testUpdateCustomerCustomFields() {
        guard let service = CXoneChat.customerCustomFields as? CustomerCustomFieldsService else {
            XCTFail("Could not get customer custom fields service")
            return
        }
        
        service.updateFields([
            .init(ident: "key1", value: "value1", updatedAt: Date()),
            .init(ident: "key2", value: "value2", updatedAt: Date().addingTimeInterval(-dayInterval))
        ])
        
        let newCustomFields: [CustomFieldDTO] = [
            .init(ident: "key1", value: "newValue1", updatedAt: Date().addingTimeInterval(-dayInterval)),
            .init(ident: "key2", value: "newValue2", updatedAt: Date())
        ]
        
        service.updateFields(newCustomFields)
        
        XCTAssertEqual(service.customerFields[0].value, "value1")
        XCTAssertEqual(service.customerFields[1].value, "newValue2")
    }
    
    func testUpdateContactCustomFields() {
        guard let service = CXoneChat.threads.customFields as? ContactCustomFieldsService else {
            XCTFail("Could not get customer custom fields service")
            return
        }
        
        let threadId = UUID()
        
        service.updateFields(
            [
                .init(ident: "key1", value: "value1", updatedAt: Date()),
                .init(ident: "key2", value: "value2", updatedAt: Date().addingTimeInterval(-dayInterval))
            ],
            for: threadId
        )
        
        let newCustomFields: [CustomFieldDTO] = [
            .init(ident: "key1", value: "newValue1", updatedAt: Date().addingTimeInterval(-dayInterval)),
            .init(ident: "key2", value: "newValue2", updatedAt: Date())
        ]
        
        service.updateFields(newCustomFields, for: threadId)
        
        XCTAssertEqual(service.contactFields[threadId]?[0].value, "value1")
        XCTAssertEqual(service.contactFields[threadId]?[1].value, "newValue2")
    }
}
