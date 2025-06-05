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

import XCTest
@testable import CXoneChatSDK

class MessageSenderInfoTest: XCTestCase {

    func testMessageSenderInfoAgent() throws {
        let message = Message(
            id: UUID(),
            threadId: UUID(),
            contentType: .text(MessagePayload(text: "", postback: nil)),
            createdAt: try Date.ISO8601(from: "2022-07-31T21:22:47+00:00"),
            attachments: [],
            direction: .toClient,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: Agent(
                id: 12345,
                firstName: "kjoe",
                surname: "jim",
                nickname: nil,
                isBotUser: false,
                isSurveyUser: false,
                imageUrl: ""
            ),
            authorEndUserIdentity: nil,
            status: .seen
        )
        
        XCTAssertEqual(message.senderInfo?.fullName, message.authorUser?.fullName)
    }
    
    func testMessageSenderInfoAuthor() throws {
        let message = Message(
            id: UUID(),
            threadId: UUID(),
            contentType: .text(MessagePayload(text: "", postback: nil)),
            createdAt: try Date.ISO8601(from: "2022-07-31T21:22:47+00:00"),
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: CustomerIdentity(id: UUID().uuidString, firstName: "kjoe", lastName: "jim"),
            status: .seen
        )
        
        XCTAssertEqual(message.senderInfo?.fullName, message.authorEndUserIdentity?.fullName)
    }
    
    func testMessageSenderInfoAgentIsNil() throws {
        let message = Message(
            id: UUID(),
            threadId: UUID(),
            contentType: .text(MessagePayload(text: "", postback: nil)),
            createdAt: try Date.ISO8601(from: "2022-07-31T21:22:47+00:00"),
            attachments: [],
            direction: .toClient,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: CustomerIdentity(id: UUID().uuidString, firstName: "kjoe", lastName: "jim"),
            status: .seen
        )
        
        XCTAssertEqual(message.authorUser?.fullName, nil)
    }
    
    func testMessageSenderInfoAuthorIsNil() throws {
        let message = Message(
            id: UUID(),
            threadId: UUID(),
            contentType: .text(MessagePayload(text: "", postback: nil)),
            createdAt: try Date.ISO8601(from: "2022-07-31T21:22:47+00:00"),
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: Agent(
                id: 12345,
                firstName: "kjoe",
                surname: "jim",
                nickname: nil,
                isBotUser: false,
                isSurveyUser: false,
                imageUrl: ""
            ),
            authorEndUserIdentity: nil,
            status: .seen
        )
        
        XCTAssertNil(message.senderInfo?.fullName)
    }

}
