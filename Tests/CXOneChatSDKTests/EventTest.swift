//
//  EventDataTest.swift
//  
//
//  Created by kjoe on 3/7/22.
//

import XCTest
@testable import CXOneChatSDK
class EventTest: XCTestCase {
    
    var sut: Event?
    let customer = CustomerIdentity(idOnExternalPlatform: consumerId.uuidString,firstName: "Yoel",lastName: "Jimenezdelvalle")
    let custom = CustomerIdentity(idOnExternalPlatform: consumerId.uuidString)
    var chanel = ""
    var brand = 0
    var threadId = ""
    var threadIdOnExternalPlatform = ""
    override func setUpWithError() throws {
        chanel = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        brand = 1386
        threadId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4_43C193A3-0F80-4DEE-A19C-80FA0E5D0E35"
        threadIdOnExternalPlatform = "43C193A3-0F80-4DEE-A19C-80FA0E5D0E35"
    }

    override func tearDownWithError() throws {
       sut = nil
    }

    func testSutInitEncodeStringWithRecoverData() {
        sut = Event(brandId: brand, channelId: chanel, customerIdentity: custom, eventType: .loadThreadMetadata, data: .archiveThread(RecoverThreadData(thread: CustomFieldThreadCodable(id: threadId, idOnExternalPlatform: threadIdOnExternalPlatform))))
        eventID = sut!.id
        XCTAssertTrue(eventID.isEmpty == false)
        XCTAssertNotNil(sut)
        let original = loadThreadMetadataString
        let originalData = original.components(separatedBy: .whitespacesAndNewlines).joined().data(using: .utf8)
        let originalString = String(bytes: originalData!, encoding: .utf8)
        let data = try! JSONEncoder().encode(sut!)
        XCTAssertNotNil(data)
        let sutString = String(bytes: data, encoding: .utf8)
        XCTAssertTrue(sutString! == originalString!, "\(sutString!) != \(originalString!)")
        
    }
    
    func testSutInitWithMessageEventData() {
        
        sut = Event(brandId: brand, channelId: chanel, customerIdentity: customer, eventType: .sendMessage, data: .message(MessageEventData(thread: MessageThreadCodable(idOnExternalPlatform: UUID(uuidString: threadIdOnExternalPlatform) ?? UUID(), threadName: ""), messageContent: MessageContent(type: "TEXT", payload: MessagePayload(text: "newtext", elements: [])), idOnExternalPlatform: messageIdOnExternalPlatform, customer: CustomerFields(customFields: []), contact: CustomerFields(customFields: []), attachments: [], browserFingerPrint: BrowserFingerprint())))
        eventID = sut!.id
        let data = sut?.payload.data
        if case EventData.message(let message) =  data! {
            XCTAssertTrue(message.messageContent.type == "TEXT" )
        }
        let enconder = JSONEncoder()
        let sutData = try! enconder.encode(sut!)
        XCTAssertNotNil(sutData)
        let sutString = String(bytes: sutData, encoding: .utf8)
        let string = sendMessageString
        let result = string.components(separatedBy: .whitespacesAndNewlines).joined()
//        XCTAssertTrue(sutString! == result, "\(sutString!) not equal to \(result)")
    }
    func testInitWitharchiveThreadData() {
        sut = Event(brandId: brand, channelId: chanel, customerIdentity: custom, eventType: .archiveThread, data: .archiveThreadData(ArchiveThreadData(thread: CustomFieldThreadCodable(id: "\(chanel)_\(threadIdOnExternalPlatform)", idOnExternalPlatform: threadIdOnExternalPlatform))))
        eventID = sut!.id
        XCTAssertTrue(eventID.isEmpty == false)
        let enconder = JSONEncoder()
        let sutData = try! enconder.encode(sut!)
        XCTAssertNotNil(sutData)
        let sutString = String(bytes: sutData, encoding: .utf8)
        let string = archiveThreadString
        let result = string.components(separatedBy: .whitespacesAndNewlines).joined()
        XCTAssertTrue(sutString! == result, "\(sutString!) not equal to \(result)")
    }
    
    func testInitWithloadMoreMessageData() {
        sut = Event(brandId: brand, channelId: chanel, customerIdentity: custom, eventType: .loadMoreMessages, data: .loadMoreMessageData(LoadMoreMessageData(scrollToken: "aaaaa", thread: CustomFieldThreadCodable(id: "\(chanel)_\(threadIdOnExternalPlatform)", idOnExternalPlatform: threadIdOnExternalPlatform), oldestMessageDatetime: "", consumerContact: Contact(id: "111222"))))
        eventID = sut!.id
        XCTAssertTrue(eventID.isEmpty == false)
        let enconder = JSONEncoder()
        let sutData = try! enconder.encode(sut!)
        XCTAssertNotNil(sutData)
        let sutString = String(bytes: sutData, encoding: .utf8)
        let string = loadMoreMessageString
        let result = string.components(separatedBy: .whitespacesAndNewlines).joined()
//        XCTAssertTrue(sutString! == result, "\(sutString!) not equal to \(result)")
    }
    
    func testInitWithsetContactCustomFieldData() {
        sut = Event(brandId: brand, channelId: chanel, customerIdentity: custom, eventType: .setCustomerContactCustomFields, data: .setContactCustomFieldData(SetContactCustomFieldData(thread: CustomFieldThreadCodable(id: "\(chanel)_\(threadIdOnExternalPlatform)", idOnExternalPlatform: threadIdOnExternalPlatform), customFields: [CustomField(ident: "myFieldIdent", value: "Thisisnewvalue")], consumerContact: Contact(id: "111222"))) )
        eventID = sut!.id
        XCTAssertTrue(eventID.isEmpty == false)
        let enconder = JSONEncoder()
        let sutData = try! enconder.encode(sut!)
        XCTAssertNotNil(sutData)
        let sutString = String(bytes: sutData, encoding: .utf8)
        let string = setCustomerContactFieldString
        let result = string.components(separatedBy: .whitespacesAndNewlines).joined()
        XCTAssertTrue(sutString! == result, "\(sutString!) not equal to \(result)")
    }
    
    func testInitWithsetCustomerCustomFieldData() {
        sut = Event(brandId: brand, channelId: chanel, customerIdentity: custom, eventType: .setCustomerCustomFields, data: .setCustomerCustomFieldData(SetCustomerCustomFieldData(customFields: [CustomField(ident: "myFieldIdent", value: "Thisisnewvalue")])))
        eventID = sut!.id
        XCTAssertTrue(eventID.isEmpty == false)
        let enconder = JSONEncoder()
        let sutData = try! enconder.encode(sut!)
        XCTAssertNotNil(sutData)
        let sutString = String(bytes: sutData, encoding: .utf8)
        let string = setCustomFieldString
        let result = string.components(separatedBy: .whitespacesAndNewlines).joined()
        XCTAssertTrue(sutString! == result, "\(sutString!) not equal to \(result)")
    }
    
    func testInitWithclientTypingStartedData() {
        sut = Event(brandId: brand, channelId: chanel, customerIdentity: custom, eventType: .senderTypingStarted, data: .clientTypingStartedData(ClientTypingStartedData(thread: ThreadCodable(id: "\(chanel)_\(threadIdOnExternalPlatform)"))))
        eventID = sut!.id
        XCTAssertTrue(eventID.isEmpty == false)
        let enconder = JSONEncoder()
        let sutData = try! enconder.encode(sut!)
        XCTAssertNotNil(sutData)
        let sutString = String(bytes: sutData, encoding: .utf8)
        let string = typingStartedString
        let result = string.components(separatedBy: .whitespacesAndNewlines).joined()
        XCTAssertTrue(sutString! == result, "\(sutString!) not equal to \(result)")
    }
    
    func testInitWithclientTypingEndedData() {
        sut = Event(brandId: brand, channelId: chanel, customerIdentity: custom, eventType: .senderTypingEnded, data: .clientTypingStartedData(ClientTypingStartedData(thread: ThreadCodable(id: "\(chanel)_\(threadIdOnExternalPlatform)"))))
        eventID = sut!.id
        XCTAssertTrue(eventID.isEmpty == false)
        let enconder = JSONEncoder()
        let sutData = try! enconder.encode(sut!)
        XCTAssertNotNil(sutData)
        let sutString = String(bytes: sutData, encoding: .utf8)
        let string = typingEndedString
        let result = string.components(separatedBy: .whitespacesAndNewlines).joined()
        XCTAssertTrue(sutString! == result, "\(sutString!) not equal to \(result)")
    }
    func testInitWithconnectUserAuth(){
        sut = Event(brandId: brand, channelId: chanel, customerIdentity: custom, eventType: .authorizeCustomer, data: .connectUserAuth(ConnectUserAuth(authorization: ConnectUserAuthCode(authorizationCode: ""))))
        eventID = sut!.id
        XCTAssertTrue(eventID.isEmpty == false)
        let enconder = JSONEncoder()
        let sutData = try! enconder.encode(sut!)
        XCTAssertNotNil(sutData)
        let sutString = String(bytes: sutData, encoding: .utf8)
        let string = authorizePayloadString
        let result = string.components(separatedBy: .whitespacesAndNewlines).joined()
        XCTAssertTrue(sutString! == result, "\(sutString!) not equal to \(result)")
    }
}
