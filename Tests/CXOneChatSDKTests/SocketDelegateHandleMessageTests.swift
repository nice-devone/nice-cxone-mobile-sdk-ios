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

// swiftlint:disable type_body_length

@testable import CXoneChatSDK
import XCTest

class SocketDelegateHandleMessageTests: CXoneXCTestCase {
    
    // MARK: - Properties
    
    private lazy var brand = BrandDTO(id: brandId)
    private lazy var channel = ChannelIdentifierDTO(id: channelId)
    private lazy var contact = ContactDTO(id: "", threadIdOnExternalPlatform: UUID(), status: .new, createdAt: Date.provide(), customFields: [])
    private lazy var thread = ThreadDTO(idOnExternalPlatform: UUID(), threadName: nil)
    private lazy var message = MessageDTO(
        idOnExternalPlatform: UUID(),
        threadIdOnExternalPlatform: UUID(),
        contentType: .text(MessagePayloadDTO(text: "", postback: nil)),
        createdAt: Date.provide(),
        attachments: [],
        direction: .inbound,
        userStatistics: UserStatisticsDTO(seenAt: nil, readAt: nil),
        authorUser: nil,
        authorEndUserIdentity: nil
    )
    private let identity = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: nil, lastName: nil)
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
        
        let thread = MockData.getThread()
        threadsService.threads.append(thread)
        
        let event = AgentTypingEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .senderTypingStarted,
            createdAt: Date.provide(),
            data: AgentTypingEventDataDTO(
                brand: brand,
                channel: channel,
                thread: ThreadDTO(idOnExternalPlatform: thread.id, threadName: thread.name),
                user: agent
            )
        )
        
        CXoneChat.handle(message: try encoder.encode(event).utf8string!)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testNotifyAgentTypingEndEventDTO() async throws {
        currentExpectation = XCTestExpectation(description: "testNotifyAgentTypingEndEvent")
        
        let thread = MockData.getThread()
        threadsService.threads.append(thread)
        
        let event = AgentTypingEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .senderTypingEnded,
            createdAt: Date.provide(),
            data: AgentTypingEventDataDTO(
                brand: brand,
                channel: channel,
                thread: ThreadDTO(idOnExternalPlatform: thread.id, threadName: thread.name),
                user: agent
            )
        )
        
        CXoneChat.handle(message: try encoder.encode(event).utf8string!)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
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
        XCTAssertEqual(event.data.message.idOnExternalPlatform, thread.messages.last?.id)
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
        XCTAssertEqual(event.data.message.idOnExternalPlatform, thread.messages.last?.id)
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
        XCTAssertEqual(event.data.message.idOnExternalPlatform, thread.messages.first?.id)
    }
    
    private func setupMessageRead(time: Date? = nil, replace: Bool) -> (ChatThread, MessageReadByAgentEventDTO) {
        let threadId = UUID()
        let message = MockData.getMessage(
            threadId: threadId,
            isSenderAgent: true,
            createdAt: time ?? Date.provide()
        )
        let thread = MockData.getThread(threadId: threadId)

        thread.messages = [MessageMapper.map(message)]

        let event = MessageReadByAgentEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .messageReadChanged,
            createdAt: Date.provide(),
            data: MessageReadByAgentEventDataDTO(
                brand: brand,
                message: MockData.getMessage(
                    threadId: threadId,
                    messageId: replace ? message.idOnExternalPlatform : UUID(),
                    isSenderAgent: true
                )
            )
        )

        threadsService.threads.append(thread)

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

    func testProcessMoreMessagesEventReplacesMessages() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMoreMessagesEventNoThrow")

        let (thread, event) = setupLoadMoreMessages(time: Date.provide() - 1, replace: true)

        let service = try threadsService.provider(for: thread) as? ChatThreadService
        service!.processMoreMessagesLoaded(event)

        guard let actualThread = threadsService.threads.first else {
            XCTFail("thread not found")
            return
        }

        await fulfillment(of: [currentExpectation], timeout: 1.0)

        XCTAssertEqual(1, actualThread.messages.count)
        XCTAssertEqual(
            event.postback.data.messages.first?.idOnExternalPlatform,
            actualThread.messages.first?.id
        )
        XCTAssertEqual(message.createdAt, threadsService.threads.first?.messages.first?.createdAt)
    }

    func testProcessMoreMessagesEventSortsEarlierMessages() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMoreMessagesEventNoThrow")

        let (thread, event) = setupLoadMoreMessages(time: Date.provide() - 1, replace: false)

        let service = try threadsService.provider(for: thread) as? ChatThreadService
        service!.processMoreMessagesLoaded(event)

        guard let actualThread = threadsService.threads.first else {
            XCTFail("thread not found")
            return
        }

        await fulfillment(of: [currentExpectation], timeout: 1.0)

        XCTAssertEqual(2, actualThread.messages.count)
        XCTAssertEqual(
            event.postback.data.messages.last?.idOnExternalPlatform,
            actualThread.messages.last?.id
        )
        XCTAssertEqual(
            event.postback.data.messages.last?.createdAt,
            actualThread.messages.last?.createdAt
        )
    }

    func testProcessMoreMessagesEventSortsLaterMessages() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMoreMessagesEventNoThrow")

        let (thread, event) = setupLoadMoreMessages(time: Date.provide() + 1, replace: false)

        let service = try threadsService.provider(for: thread) as? ChatThreadService
        service!.processMoreMessagesLoaded(event)

        guard let actualThread = threadsService.threads.first else {
            XCTFail("thread not found")
            return
        }

        await fulfillment(of: [currentExpectation], timeout: 1.0)

        XCTAssertEqual(2, actualThread.messages.count)
        XCTAssertEqual(
            event.postback.data.messages.first?.idOnExternalPlatform,
            actualThread.messages.first?.id
        )
        XCTAssertEqual(
            event.postback.data.messages.first?.createdAt,
            actualThread.messages.first?.createdAt
        )
    }
    
    func testProcessEventInS3DownloadAndDecodeCorrectly() async throws {
        let requestData = try loadBundleData(from: "EventInS3+ThreadRecovered", type: "json")
        let event = try requestData.decode() as EventInS3DTO
        let responseData = try loadBundleData(from: "ThreadRecoveredEvent", type: "json")
        
        try await URLProtocolMock.with(handlers: accept(url(equals: event.url.absoluteString), body: string(responseData.utf8string!))) {
            CXoneChat.handle(message: requestData.utf8string!)
        }
    }
    
    func testSetPositionInQueueEventDecodedCorrectly() throws {
        let event = try loadBundleData(from: "SetPositionInQueue", type: "json").decode() as SetPositionInQueueEventDTO
        
        XCTAssertEqual(event.eventType, .setPositionInQueue)
        XCTAssertEqual(event.data.positionInQueue, 10)
    }
    
    func testHandleSetPositionInQueueEvent() async throws {
        threadsService.threads.append(MockData.getThread(contactId: "12345"))

        let message = try loadBundleData(from: "SetPositionInQueue", type: "json").utf8string
        
        CXoneChat.handle(message: message!)

        XCTAssertEqual(10, threadsService.threads.last?.positionInQueue)
    }
}

// MARK: - Helpers

private extension SocketDelegateHandleMessageTests {
    
    func setupMessageCreated(time: Date? = nil, replace: Bool) -> (ChatThread, MessageCreatedEventDTO) {
        let threadId = UUID()
        let message = MockData.getMessage(
            threadId: threadId,
            isSenderAgent: true,
            createdAt: time ?? Date.provide()
        )
        let thread = MockData.getThread(threadId: threadId)
        thread.messages = [MessageMapper.map(message)]

        let event = MessageCreatedEventDTO(
            eventId: UUID(),
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
                    messageId: replace ? message.idOnExternalPlatform : UUID(),
                    isSenderAgent: true
                )
            )
        )

        threadsService.threads.append(thread)

        return (thread, event)
    }
    
    func setupLoadMoreMessages(time: Date? = nil, replace: Bool) -> (ChatThread, MoreMessagesLoadedEventDTO) {
        let threadId = UUID()
        let message = MockData.getMessage(
            threadId: threadId,
            isSenderAgent: true,
            createdAt: time ?? Date.provide()
        )
        let thread = MockData.getThread(threadId: threadId)
        thread.messages = [MessageMapper.map(message)]

        let event = MoreMessagesLoadedEventDTO(
            eventId: UUID(),
            eventType: .moreMessagesLoaded,
            postback: MoreMessagesLoadedEventPostbackDTO(
                eventType: .moreMessagesLoaded,
                data: MoreMessagesLoadedEventPostbackDataDTO(
                    messages: [
                        MockData.getMessage(
                            threadId: threadId,
                            messageId: replace ? message.idOnExternalPlatform : UUID(),
                            isSenderAgent: true
                        )
                    ],
                    scrollToken: "scroll_token"
                )
            )
        )

        threadsService.threads.append(thread)

        return (thread, event)
    }
}
