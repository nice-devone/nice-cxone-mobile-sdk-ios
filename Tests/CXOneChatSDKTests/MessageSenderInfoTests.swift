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
                inContactId: "",
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
            contentType: .text(MessagePayload(text: "", postback: nil)),
            createdAt: try Date.ISO8601(from: "2022-07-31T21:22:47+00:00"),
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: CustomerIdentity(id: UUID().uuidString, firstName: "kjoe", lastName: "jim")
        )
        
        XCTAssertEqual(message.senderInfo.fullName, message.authorEndUserIdentity?.fullName)
    }
    
    func testMessageSenderInfoAgentUn() throws {
        let message = Message(
            id: UUID(),
            threadId: UUID(),
            contentType: .text(MessagePayload(text: "", postback: nil)),
            createdAt: try Date.ISO8601(from: "2022-07-31T21:22:47+00:00"),
            attachments: [],
            direction: .toClient,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: CustomerIdentity(id: UUID().uuidString, firstName: "kjoe", lastName: "jim")
        )
        
        XCTAssertEqual(message.senderInfo.fullName, "Automated Agent")
    }
    
    func testMessageSenderInfoAuthorUnknownCustomer() throws {
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
                inContactId: "",
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
