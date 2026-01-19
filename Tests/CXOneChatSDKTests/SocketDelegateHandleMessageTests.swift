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

// swiftlint:disable type_body_length

@testable import CXoneChatSDK
import XCTest

class SocketDelegateHandleMessageTests: CXoneXCTestCase {
    
    // MARK: - Properties
    
    private lazy var brand = BrandDTO(id: brandId)
    private lazy var channel = ChannelIdentifierDTO(id: channelId)
    private lazy var contact = ContactDTO(
        id: "",
        threadIdOnExternalPlatform: LowercaseUUID().uuidString,
        status: .new,
        createdAt: Date.provide(),
        customFields: []
    )
    private lazy var thread = ThreadDTO(idOnExternalPlatform: LowercaseUUID().uuidString, threadName: nil)
    private lazy var message = MessageDTO(
        idOnExternalPlatform: UUID(),
        idOnExternalPlatformString: LowercaseUUID().uuidString,
        threadIdOnExternalPlatform: UUID(),
        threadIdOnExternalPlatformString: LowercaseUUID().uuidString,
        contentType: .text(MessagePayloadDTO(text: "", postback: nil)),
        createdAt: Date.provide(),
        attachments: [],
        direction: .inbound,
        userStatistics: UserStatisticsDTO(seenAt: nil, readAt: nil),
        authorUser: nil,
        authorEndUserIdentity: nil
    )
    private let identity = CustomerIdentityDTO(idOnExternalPlatform: LowercaseUUID().uuidString, firstName: nil, lastName: nil)
    private lazy var accessToken = AccessTokenDTO(token: "token", expiresIn: .max, currentDate: Date.provide())
    private let agent = AgentDTO(
        id: 0,
        firstName: "John",
        surname: "Doe",
        nickname: nil,
        isBotUser: false,
        isSurveyUser: false,
        publicImageUrl: ""
    )
    
    // MARK: - Properties
    
    func testHandleMessageNoThrowMissingEventDTO() async throws {
        currentExpectation = XCTestExpectation(description: "Handle message decode error.")
        currentExpectation.isInverted = true
        
        let data = try loadBundleData(from: "MessageAddedIntoCaseEvent", type: "json")

        CXoneChat.handle(message: data.utf8string!)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testNotifyAgentTypingStartedEventDTO() async throws {
        currentExpectation = XCTestExpectation(description: "testNotifyAgentTypingStartedEvent")
        
        let event = AgentTypingEventDTO(
            eventId: LowercaseUUID().uuidString,
            eventObject: .thread,
            eventType: .senderTypingStarted,
            createdAt: Date.provide(),
            data: AgentTypingEventDataDTO(brand: brand, channel: channel, thread: thread, user: agent)
        )
        
        CXoneChat.handle(message: try encoder.encode(event).utf8string!)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testNotifyAgentTypingEndEventDTO() async throws {
        currentExpectation = XCTestExpectation(description: "testNotifyAgentTypingEndEvent")
        
        let event = AgentTypingEventDTO(
            eventId: LowercaseUUID().uuidString,
            eventObject: .thread,
            eventType: .senderTypingEnded,
            createdAt: Date.provide(),
            data: AgentTypingEventDataDTO(brand: brand, channel: channel, thread: thread, user: agent)
        )
        
        CXoneChat.handle(message: try encoder.encode(event).utf8string!)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    private func setupMessageCreated(time: Date? = nil, replace: Bool) -> (ChatThreadDTO, MessageCreatedEventDTO) {
        let threadId = LowercaseUUID().uuidString
        let message = MockData.getMessage(
            threadId: threadId,
            isSenderAgent: true,
            createdAt: time ?? Date.provide()
        )
        var thread = MockData.getThread(threadId: threadId)

        thread.messages = [message]

        let event = MessageCreatedEventDTO(
            eventId: LowercaseUUID().uuidString,
            eventObject: .message,
            eventType: .messageCreated,
            createdAt: Date.provide(),
            data: MessageCreatedEventDataDTO(
                brand: brand,
                channel: channel,
                case: contact,
                thread: ThreadDTO(idOnExternalPlatform: threadId, threadName: nil),
                message: MockData.getMessage(
                    threadId: threadId,
                    messageId: replace ? message.idOnExternalPlatformString : LowercaseUUID().uuidString,
                    isSenderAgent: true
                )
            )
        )

        connectionContext.activeThread = (ChatThreadMapper.map(thread))
        threadsService.threads.append(ChatThreadMapper.map(thread)!)

        return (thread, event)
    }

    func testProcessMessageCreatedEventReplaces() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageCreatedEventNoThrow")

        let (_, event) = setupMessageCreated(replace: true)

        CXoneChat.handle(message: try encoder.encode(event).utf8string!)

        guard let thread = threadsService.threads.first else {
            XCTFail("thread not found")
            return
        }

        await fulfillment(of: [currentExpectation], timeout: 1.0)

        XCTAssertEqual(1, thread.messages.count)
        XCTAssertEqual(event.data.message.idOnExternalPlatformString, thread.messages.last?.idString)
        XCTAssertEqual(message.createdAt, thread.messages.last?.createdAt)
    }

    func testProcessMessageCreatedEventSortsEarlier() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageCreatedEventNoThrow")
        
        let (_, event) = setupMessageCreated(time: Date.provide() - 1, replace: false)

        CXoneChat.handle(message: try encoder.encode(event).utf8string!)
        
        guard let thread = threadsService.threads.first else {
            XCTFail("thread not found")
            return
        }

        await fulfillment(of: [currentExpectation], timeout: 1.0)

        XCTAssertEqual(2, thread.messages.count)
        XCTAssertEqual(event.data.message.idOnExternalPlatformString, thread.messages.last?.idString)
    }
    
    func testProcessMessageCreatedEventSortsLater() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageCreatedEventNoThrow")

        let (_, event) = setupMessageCreated(time: Date.provide() + 1, replace: false)

        CXoneChat.handle(message: try encoder.encode(event).utf8string!)

        guard let thread = threadsService.threads.first else {
            XCTFail("thread not found")
            return
        }

        await fulfillment(of: [currentExpectation], timeout: 1.0)

        XCTAssertEqual(2, thread.messages.count)
        XCTAssertEqual(event.data.message.idOnExternalPlatformString, thread.messages.first?.idString)
    }

    private func setupMessageRead(time: Date? = nil, replace: Bool) -> (ChatThreadDTO, MessageReadByAgentEventDTO) {
        let threadId = LowercaseUUID().uuidString
        let message = MockData.getMessage(
            threadId: threadId,
            isSenderAgent: true,
            createdAt: time ?? Date.provide()
        )
        var thread = MockData.getThread(threadId: threadId)

        thread.messages = [message]

        let event = MessageReadByAgentEventDTO(
            eventId: LowercaseUUID().uuidString,
            eventObject: .thread,
            eventType: .messageReadChanged,
            createdAt: Date.provide(),
            data: MessageReadByAgentEventDataDTO(
                brand: brand,
                message: MockData.getMessage(
                    threadId: threadId,
                    messageId: replace ? message.idOnExternalPlatformString : LowercaseUUID().uuidString,
                    isSenderAgent: true
                )
            )
        )

        connectionContext.activeThread = (ChatThreadMapper.map(thread))
        threadsService.threads.append(ChatThreadMapper.map(thread)!)

        return (thread, event)
    }

    func testProcessMessageReadChangeEventReplaces() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageReadChangeEventNoThrow")

        let (_, event) = setupMessageRead(time: Date.provide() - 1, replace: true)

        CXoneChat.handle(message: try encoder.encode(event).utf8string!)
        
        guard let thread = threadsService.threads.last else {
            XCTFail("thread not found")
            return
        }

        await fulfillment(of: [currentExpectation], timeout: 1.0)

        XCTAssertEqual(1, thread.messages.count)
        XCTAssertEqual(event.data.message.createdAt, thread.messages.first?.createdAt)
    }
    
    func testProcessCustomerAuthorizedEventThrowMissingAccessToken() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessCustomerAuthorizedEventThrowMissingAccessToken")
        
        socketService.connectionContext.channelConfig = MockData.getChannelConfiguration()
        
        let event = CustomerAuthorizedEventDTO(
            eventId: LowercaseUUID().uuidString,
            postback: CustomerAuthorizedEventPostbackDTO(
                eventType: .customerAuthorized,
                data: CustomerAuthorizedEventPostbackDataDTO(consumerIdentity: identity, accessToken: nil)
            )
        )
        
        CXoneChat.handle(message: try encoder.encode(event).utf8string!)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessCustomerAuthorizedEventNoThrow() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessCustomerAuthorizedEventNoThrow")
        
        let event = CustomerAuthorizedEventDTO(
            eventId: LowercaseUUID().uuidString,
            postback: CustomerAuthorizedEventPostbackDTO(
                eventType: .customerAuthorized,
                data: CustomerAuthorizedEventPostbackDataDTO(consumerIdentity: identity, accessToken: accessToken)
            )
        )
        
        CXoneChat.handle(message: try encoder.encode(event).utf8string!)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessCustomerReconnectEventDTO() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessCustomerReconnectEvent")

        let event = GenericEventDTO(
            eventType: .customerReconnected,
            postback: nil,
            error: nil,
            internalServerError: nil
        )
        
        CXoneChat.handle(message: try encoder.encode(event).utf8string!)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    private func setupLoadMoreMessages(time: Date? = nil, replace: Bool) -> (ChatThreadDTO, MoreMessagesLoadedEventDTO) {
        let threadId = LowercaseUUID().uuidString
        let message = MockData.getMessage(
            threadId: threadId,
            isSenderAgent: true,
            createdAt: time ?? Date.provide()
        )
        var thread = MockData.getThread(threadId: threadId)

        thread.messages = [message]

        let event = MoreMessagesLoadedEventDTO(
            eventId: LowercaseUUID().uuidString,
            postback: MoreMessagesLoadedEventPostbackDTO(
                eventType: .moreMessagesLoaded,
                data: MoreMessagesLoadedEventPostbackDataDTO(
                    messages: [
                        MockData.getMessage(
                            threadId: threadId,
                            messageId: replace ? message.idOnExternalPlatformString : LowercaseUUID().uuidString,
                            isSenderAgent: true
                        )
                    ],
                    scrollToken: "scroll_token"
                )
            )
        )

        connectionContext.activeThread = (ChatThreadMapper.map(thread))
        threadsService.threads.append(ChatThreadMapper.map(thread)!)

        return (thread, event)
    }

    func testProcessMoreMessagesEventReplacesMessages() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMoreMessagesEventNoThrow")

        let (_, event) = setupLoadMoreMessages(time: Date.provide() - 1, replace: true)

        CXoneChat.handle(message: try encoder.encode(event).utf8string!)

        guard let actualThread = threadsService.threads.first else {
            XCTFail("thread not found")
            return
        }

        await fulfillment(of: [currentExpectation], timeout: 1.0)

        XCTAssertEqual(1, actualThread.messages.count)
        XCTAssertEqual(
            event.postback.data.messages.first?.idOnExternalPlatformString,
            actualThread.messages.first?.idString
        )
        XCTAssertEqual(message.createdAt, threadsService.threads.first?.messages.first?.createdAt)
    }

    func testProcessMoreMessagesEventSortsEarlierMessages() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMoreMessagesEventNoThrow")

        let (_, event) = setupLoadMoreMessages(time: Date.provide() - 1, replace: false)

        CXoneChat.handle(message: try encoder.encode(event).utf8string!)

        guard let actualThread = threadsService.threads.first else {
            XCTFail("thread not found")
            return
        }

        await fulfillment(of: [currentExpectation], timeout: 1.0)

        XCTAssertEqual(2, actualThread.messages.count)
        XCTAssertEqual(
            event.postback.data.messages.last?.idOnExternalPlatformString,
            actualThread.messages.last?.idString
        )
        XCTAssertEqual(
            event.postback.data.messages.last?.createdAt,
            actualThread.messages.last?.createdAt
        )
    }

    func testProcessMoreMessagesEventSortsLaterMessages() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMoreMessagesEventNoThrow")

        let (_, event) = setupLoadMoreMessages(time: Date.provide() + 1, replace: false)

        CXoneChat.handle(message: try encoder.encode(event).utf8string!)

        guard let actualThread = threadsService.threads.first else {
            XCTFail("thread not found")
            return
        }

        await fulfillment(of: [currentExpectation], timeout: 1.0)

        XCTAssertEqual(2, actualThread.messages.count)
        XCTAssertEqual(
            event.postback.data.messages.first?.idOnExternalPlatformString,
            actualThread.messages.first?.idString
        )
        XCTAssertEqual(
            event.postback.data.messages.first?.createdAt,
            actualThread.messages.first?.createdAt
        )
    }

    func testTokenRefreshedEventDTO() throws {
        let event = TokenRefreshedEventDTO(
            eventId: LowercaseUUID().uuidString,
            postback: TokenRefreshedEventPostbackDTO(eventType: .tokenRefreshed, accessToken: accessToken)
        )
        
        CXoneChat.handle(message: try encoder.encode(event).utf8string!)
        
        XCTAssertEqual(socketService.accessToken?.token, accessToken.token)
    }
    
    func testEndContactEventEncodedCorrectly() throws {
        let expectedData = try loadBundleData(from: "EndContact", type: "json").decode() as EndContactEventDTO
        
        let endContactEvent = EndContactEventDTO(
            eventType: .endContact,
            data: EndContactEventDataDTO(thread: "ad342920-c75e-4b06-b973-00494cc811b7", contact: "12345")
        )
        
        XCTAssertEqual(expectedData.eventType, endContactEvent.eventType)
        XCTAssertEqual(expectedData.data.thread, endContactEvent.data.thread)
        XCTAssertEqual(expectedData.data.contact, endContactEvent.data.contact)
    }
    
    func testSetPositionInQueueEventDecodedCorrectly() throws {
        let event = try loadBundleData(from: "SetPositionInQueue", type: "json").decode() as SetPositionInQueueEventDTO
        
        XCTAssertEqual(event.eventType, .setPositionInQueue)
        XCTAssertEqual(event.data.positionInQueue, 10)
    }
    
    func testHandleSetPositionInQueueEvent() async throws {
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(isOnline: true, isLiveChat: true))
        
        threadsService.threads.append(ChatThreadMapper.map(MockData.getThread(contactId: "12345"))!)

        let message = try loadBundleData(from: "SetPositionInQueue", type: "json").utf8string
        
        CXoneChat.handle(message: message!)

        XCTAssertEqual(10, threadsService.threads.last?.positionInQueue)
    }
}
