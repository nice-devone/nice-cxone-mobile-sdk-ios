import XCTest
@testable import CXoneChatSDK


class MessageSenderInfoTest: XCTestCase {

    func testMessageSenderInfoAgent() throws {
        let message = Message(
            id: UUID(),
            threadId: UUID(),
            messageContent: .init(type: .text, payload: .init(text: "", elements: []), fallbackText: ""),
            createdAt: try Date.ISO8601(from: "2022-07-31T21:22:47+00:00"),
            attachments: [],
            direction: .outbound,
            userStatistics: .init(seenAt: nil, readAt: nil),
            authorUser: .init(
                id: 12345,
                inContactId: UUID(),
                emailAddress: nil,
                loginUsername: "kj",
                firstName: "kjoe",
                surname: "jim",
                nickname: nil,
                isBotUser: false,
                isSurveyUser: false,
                imageUrl: ""
            ),
            authorEndUserIdentity: nil
        )
        
        XCTAssertEqual(message.senderInfo.fullName, message.authorUser?.fullName)
    }
    
    func testMessageSenderInfoAuthor() throws {
        let message = Message(
            id: UUID(),
            threadId: UUID(),
            messageContent: .init(type: .text, payload: MessagePayload(text: "", elements: []), fallbackText: ""),
            createdAt: try Date.ISO8601(from: "2022-07-31T21:22:47+00:00"),
            attachments: [],
            direction: .inbound,
            userStatistics: .init(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: .init(id: UUID().uuidString, firstName: "kjoe", lastName: "jim")
        )
        
        XCTAssertEqual(message.senderInfo.fullName, message.authorEndUserIdentity?.fullName)
    }
    
    func testMessageSenderInfoAgentUn() throws {
        let message = Message(
            id: UUID(),
            threadId: UUID(),
            messageContent: .init(type: .text, payload: MessagePayload(text: "", elements: []), fallbackText: ""),
            createdAt: try Date.ISO8601(from: "2022-07-31T21:22:47+00:00"),
            attachments: [],
            direction: .outbound,
            userStatistics: .init(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: .init(id: UUID().uuidString, firstName: "kjoe", lastName: "jim")
        )
        
        XCTAssertEqual(message.senderInfo.fullName, "Automated Agent")
    }
    
    func testMessageSenderInfoAuthorUnknownCustomer() throws {
        let message = Message(
            id: UUID(),
            threadId: UUID(),
            messageContent: .init(type: .text, payload: MessagePayload(text: "", elements: []), fallbackText: ""),
            createdAt: try Date.ISO8601(from: "2022-07-31T21:22:47+00:00"),
            attachments: [],
            direction: .inbound,
            userStatistics: .init(seenAt: nil, readAt: nil),
            authorUser: .init(
                id: 12345,
                inContactId: UUID(),
                emailAddress: nil,
                loginUsername: "kj",
                firstName: "kjoe",
                surname: "jim",
                nickname: nil,
                isBotUser: false,
                isSurveyUser: false,
                imageUrl: ""
            ),
            authorEndUserIdentity: nil
        )
        
        XCTAssertEqual(message.senderInfo.fullName, "Unknown Customer")
    }

}
