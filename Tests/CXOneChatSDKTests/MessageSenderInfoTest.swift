//
//  MessageSenderInfoTest.swift
//  
//
//  Created by kjoe on 8/2/22.
//

import XCTest
@testable import CXOneChatSDK
class MessageSenderInfoTest: XCTestCase {

    func testMessageSenderInfoAgent() {
        let message = Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: UUID(), messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "2022-07-31T21:22:47+00:00", attachments: [], direction: .outbound, userStatistics: UserStatistics(), authorUser: Agent(id: 12345, loginUsername: "kj", firstName: "kjoe", surname: "jim", isBotUser: false, isSurveyUser: false, imageUrl: ""))
        XCTAssertEqual(message.senderInfo.fullName, message.authorUser?.fullName)
    }
    func testMessageSenderInfoAuthor() {
        let message = Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: UUID(), messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "2022-07-31T21:22:47+00:00", attachments: [], direction: .inbound, userStatistics: UserStatistics(), authorUser: nil, authorEndUserIdentity: CustomerIdentity(idOnExternalPlatform: UUID().uuidString, firstName: "kjoe", lastName: "jim"))
        XCTAssertEqual(message.senderInfo.fullName, message.authorEndUserIdentity?.fullName)
    }
    func testMessageSenderInfoAgentUn() {
        let message = Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: UUID(), messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "2022-07-31T21:22:47+00:00", attachments: [], direction: .outbound, userStatistics: UserStatistics(),authorUser: nil, authorEndUserIdentity: CustomerIdentity(idOnExternalPlatform: UUID().uuidString, firstName: "kjoe", lastName: "jim"))
        XCTAssertEqual(message.senderInfo.fullName, "Automated Agent")
    }
    func testMessageSenderInfoAuthorUnknownCustomer() {
        let message = Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: UUID(), messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "2022-07-31T21:22:47+00:00", attachments: [], direction: .inbound, userStatistics: UserStatistics(), authorUser: Agent(id: 12345, loginUsername: "kj", firstName: "kjoe", surname: "jim", isBotUser: false, isSurveyUser: false, imageUrl: ""))
        XCTAssertEqual(message.senderInfo.fullName, "Unknown Customer")
    }

}
