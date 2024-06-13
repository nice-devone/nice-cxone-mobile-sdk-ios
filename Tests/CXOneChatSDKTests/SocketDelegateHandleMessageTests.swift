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
    private lazy var contact = ContactDTO(id: "", threadIdOnExternalPlatform: UUID(), status: .new, createdAt: dateProvider.now, customFields: [])
    private lazy var thread = ThreadDTO(idOnExternalPlatform: UUID(), threadName: nil)
    private lazy var message = MessageDTO(
        idOnExternalPlatform: UUID(),
        threadIdOnExternalPlatform: UUID(),
        contentType: .text(MessagePayloadDTO(text: "", postback: nil)),
        createdAt: dateProvider.now,
        attachments: [],
        direction: .inbound,
        userStatistics: UserStatisticsDTO(seenAt: nil, readAt: nil),
        authorUser: nil,
        authorEndUserIdentity: nil
    )
    private let identity = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: nil, lastName: nil)
    private lazy var accessToken = AccessTokenDTO(token: "token", expiresIn: .max, currentDate: dateProvider.now)
    private let agent = AgentDTO(
        id: 0,
        inContactId: "",
        emailAddress: nil,
        loginUsername: "agent",
        firstName: "John",
        surname: "Doe",
        nickname: nil,
        isBotUser: false,
        isSurveyUser: false,
        imageUrl: ""
    )
    
    // MARK: - Properties
    
    func testHandleMessageNoThrowMissingEventDTO() async throws {
        currentExpectation = XCTestExpectation(description: "Handle message decode error.")
        currentExpectation.isInverted = true
        
        let data = try loadStubFromBundle(withName: "MessageAddedIntoCaseEvent", extension: "json")
        
        CXoneChat.socketDelegateManager.handle(message: data.utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testHandleMessageThrowsMissingEventDTO() async {
        currentExpectation = XCTestExpectation(description: "Handle message decode error.")
        
        CXoneChat.socketDelegateManager.handle(message: "message")
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testHandleMessageThrowsGenericError() async throws {
        currentExpectation = XCTestExpectation(description: "Handle message decode error.")
        
        let error = GenericEventDTO(
            eventType: .archiveThread,
            postback: nil,
            error: OperationError(errorCode: .inconsistentData, transactionId: LowerCaseUUID(), errorMessage: ""),
            internalServerError: nil
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(error).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testNotifyAgentTypingStartedEventDTO() async throws {
        currentExpectation = XCTestExpectation(description: "testNotifyAgentTypingStartedEvent")
        
        let event = AgentTypingEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .senderTypingStarted,
            createdAt: dateProvider.now,
            data: AgentTypingEventDataDTO(brand: brand, channel: channel, thread: thread, user: agent)
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testNotifyAgentTypingEndEventDTO() async throws {
        currentExpectation = XCTestExpectation(description: "testNotifyAgentTypingEndEvent")
        
        let event = AgentTypingEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .senderTypingEnded,
            createdAt: dateProvider.now,
            data: AgentTypingEventDataDTO(brand: brand, channel: channel, thread: thread, user: agent)
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMessageCreatedEventThrows() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageCreatedEventThrows")
        
        threadsService.threads.append(ChatThread(id: message.threadIdOnExternalPlatform, state: .ready))
        
        let event = MessageCreatedEventDTO(
            eventId: UUID(),
            eventObject: .message,
            eventType: .messageCreated,
            createdAt: dateProvider.now,
            data: MessageCreatedEventDataDTO(brand: brand, channel: channel, case: contact, thread: thread, message: message)
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }

    private func setupMessageCreated(time: Date? = nil, replace: Bool) -> (ChatThreadDTO, MessageCreatedEventDTO) {
        let threadId = UUID()
        let message = MockData.getMessage(
            threadId: threadId,
            isSenderAgent: true,
            createdAt: time ?? dateProvider.now
        )
        var thread = MockData.getThread(threadId: threadId)

        thread.messages = [message]

        let event = MessageCreatedEventDTO(
            eventId: UUID(),
            eventObject: .message,
            eventType: .messageCreated,
            createdAt: dateProvider.now,
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

        connectionContext.activeThread = (ChatThreadMapper.map(thread))
        threadsService.threads.append(ChatThreadMapper.map(thread))

        return (thread, event)
    }

    func testProcessMessageCreatedEventReplaces() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageCreatedEventNoThrow")

        let (_, event) = setupMessageCreated(replace: true)

        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)

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
        
        let (_, event) = setupMessageCreated(time: dateProvider.now - 1, replace: false)

        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
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

        let (_, event) = setupMessageCreated(time: dateProvider.now + 1, replace: false)

        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)

        guard let thread = threadsService.threads.first else {
            XCTFail("thread not found")
            return
        }

        await fulfillment(of: [currentExpectation], timeout: 1.0)

        XCTAssertEqual(2, thread.messages.count)
        XCTAssertEqual(event.data.message.idOnExternalPlatform, thread.messages.first?.id)
    }

    func testProcessThreadRecoverEventDTO() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessThreadRecoverEvent")
        
        let event = AgentTypingEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .threadRecovered,
            createdAt: dateProvider.now,
            data: AgentTypingEventDataDTO(brand: brand, channel: channel, thread: thread, user: agent)
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }

    func testProcessMessageReadChangeEventThrows() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageReadChangeEventThrows")
        
        let event = GenericEventDTO(eventType: .messageReadChanged, postback: nil, error: nil, internalServerError: nil)
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    private func setupMessageRead(time: Date? = nil, replace: Bool) -> (ChatThreadDTO, MessageReadByAgentEventDTO) {
        let threadId = UUID()
        let message = MockData.getMessage(
            threadId: threadId,
            isSenderAgent: true,
            createdAt: time ?? dateProvider.now
        )
        var thread = MockData.getThread(threadId: threadId)

        thread.messages = [message]

        let event = MessageReadByAgentEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .messageReadChanged,
            createdAt: dateProvider.now,
            data: MessageReadByAgentEventDataDTO(
                brand: brand,
                message: MockData.getMessage(
                    threadId: threadId,
                    messageId: replace ? message.idOnExternalPlatform : UUID(),
                    isSenderAgent: true
                )
            )
        )

        connectionContext.activeThread = (ChatThreadMapper.map(thread))
        threadsService.threads.append(ChatThreadMapper.map(thread))

        return (thread, event)
    }

    func testProcessMessageReadChangeEventReplaces() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageReadChangeEventNoThrow")

        let (_, event) = setupMessageRead(time: dateProvider.now - 1, replace: true)

        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        guard let thread = threadsService.threads.last else {
            XCTFail("thread not found")
            return
        }

        await fulfillment(of: [currentExpectation], timeout: 1.0)

        XCTAssertEqual(1, thread.messages.count)
        XCTAssertEqual(event.data.message.createdAt, thread.messages.first?.createdAt)
    }
    
    func testProcessInboxAssigneeChangeEventThrows() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessInboxAssigneeChangeEventThrows")
        
        let event = GenericEventDTO(eventType: .contactInboxAssigneeChanged, postback: nil, error: nil, internalServerError: nil)
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessInboxAssigneeChangeEventNoThrow() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessInboxAssigneeChangeEventNoThrow")
        
        let event = ContactInboxAssigneeChangedEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .contactInboxAssigneeChanged,
            createdAt: dateProvider.now,
            data: ContactInboxAssigneeChangedDataDTO(case: contact, inboxAssignee: agent, previousInboxAssignee: nil)
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessThreadListFetchedEventDTO() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessThreadListFetchedEvent")
        
        let event = GenericEventDTO(
            eventType: nil,
            postback: GenericEventPostbackDTO(
                eventType: .threadListFetched,
                threads: [
                    ReceivedThreadDataDTO(idOnExternalPlatform: UUID(), channelId: "", threadName: "", canAddMoreMessages: true)
                ]
            ),
            error: nil,
            internalServerError: nil
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessCustomerAuthorizedEventThrowMissingAccessToken() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessCustomerAuthorizedEventThrowMissingAccessToken")
        
        socketService.connectionContext.channelConfig = MockData.getChannelConfiguration()
        
        let event = CustomerAuthorizedEventDTO(
            eventId: UUID(),
            postback: CustomerAuthorizedEventPostbackDTO(
                eventType: .customerAuthorized,
                data: CustomerAuthorizedEventPostbackDataDTO(consumerIdentity: identity, accessToken: nil)
            )
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessCustomerAuthorizedEventNoThrow() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessCustomerAuthorizedEventNoThrow")
        
        let event = CustomerAuthorizedEventDTO(
            eventId: UUID(),
            postback: CustomerAuthorizedEventPostbackDTO(
                eventType: .customerAuthorized,
                data: CustomerAuthorizedEventPostbackDataDTO(consumerIdentity: identity, accessToken: accessToken)
            )
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
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
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMoreMessagesEventThrows() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMoreMessagesEventThrows")
        
        let event = MoreMessagesLoadedEventDTO(
            eventId: UUID(),
            postback: MoreMessagesLoadedEventPostbackDTO(
                eventType: .moreMessagesLoaded,
                data: MoreMessagesLoadedEventPostbackDataDTO(messages: [], scrollToken: "scroll_token")
            )
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    private func setupLoadMoreMessages(time: Date? = nil, replace: Bool) -> (ChatThreadDTO, MoreMessagesLoadedEventDTO) {
        let threadId = UUID()
        let message = MockData.getMessage(
            threadId: threadId,
            isSenderAgent: true,
            createdAt: time ?? dateProvider.now
        )
        var thread = MockData.getThread(threadId: threadId)

        thread.messages = [message]

        let event = MoreMessagesLoadedEventDTO(
            eventId: UUID(),
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

        connectionContext.activeThread = (ChatThreadMapper.map(thread))
        threadsService.threads.append(ChatThreadMapper.map(thread))

        return (thread, event)
    }

    func testProcessMoreMessagesEventReplacesMessages() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMoreMessagesEventNoThrow")

        let (_, event) = setupLoadMoreMessages(time: dateProvider.now - 1, replace: true)

        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)

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

        let (_, event) = setupLoadMoreMessages(time: dateProvider.now - 1, replace: false)

        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)

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

        let (_, event) = setupLoadMoreMessages(time: dateProvider.now + 1, replace: false)

        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)

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

    func testNotifyThreadArchivedEventDTO() async throws {
        currentExpectation = XCTestExpectation(description: "testNotifyThreadArchivedEvent")
        
        connectionContext.activeThread = ChatThreadMapper.map(MockData.getThread())
        let event = GenericEventDTO(eventType: .threadArchived, postback: nil, error: nil, internalServerError: nil)
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testTokenRefreshedEventDTO() throws {
        let event = TokenRefreshedEventDTO(
            eventId: UUID(),
            postback: TokenRefreshedEventPostbackDTO(eventType: .tokenRefreshed, accessToken: accessToken)
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        XCTAssertEqual(socketService.accessToken?.token, accessToken.token)
    }
    
    func testProcessThreadLastMessageWithoutAgent() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessThreadLastMessageWithoutAgent")
        
        let event = ThreadMetadataLoadedEventDTO(
            eventId: UUID(),
            postback: ThreadMetadataLoadedEventPostbackDTO(
                eventType: .threadMetadataLoaded,
                data: ThreadMetadataLoadedEventPostbackDataDTO(ownerAssignee: nil, lastMessage: message)
            )
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessThreadLastMessageWithAgent() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessThreadLastMessageWithAgent")
        
        let event = ThreadMetadataLoadedEventDTO(
            eventId: UUID(),
            postback: ThreadMetadataLoadedEventPostbackDTO(
                eventType: .threadMetadataLoaded,
                data: ThreadMetadataLoadedEventPostbackDataDTO(ownerAssignee: agent, lastMessage: message)
            )
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessProactiveAction() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessProactiveAction")
        
        let event = ProactiveActionEventDTO(
            eventId: UUID(),
            eventObject: .message,
            eventType: .fireProactiveAction,
            createdAt: dateProvider.now,
            data: ProactiveActionEventDataDTO(
                eventId: LowerCaseUUID(),
                actionId: LowerCaseUUID(),
                actionName: "actionName",
                actionType: .welcomeMessage,
                data: nil
            )
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessCaseStatusChangedEventNoThrow() async throws {
        throw XCTSkip("Test is not yet ready for any SDK feature - waiting for live chat implementation")
        
        currentExpectation = XCTestExpectation(description: "testProcessInboxAssigneeChangeEventNoThrow")
        
        let event = CaseStatusChangedEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .caseStatusChanged,
            createdAt: dateProvider.now,
            data: CaseStatusChangedDataDTO(brand: brand, channel: channel, case: contact)
        )
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(event).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessCaseStatusChangedDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "CaseStatusChanged", extension: "json")
        let event = try data.decode() as CaseStatusChangedEventDTO
        
        XCTAssertEqual(event.eventType, .caseStatusChanged)
        XCTAssertEqual(event.data.case.status, .closed)
    }
    
    func testProcessEventInS3DownloadAndDecodeCorrectly() async throws {
        connectionService.disconnect()
        
        try await setUpConnection()
        
        let requestData = try loadStubFromBundle(withName: "EventInS3+ThreadRecovered", extension: "json")
        let event = try requestData.decode() as EventInS3DTO
        let responseData = try self.loadStubFromBundle(withName: "ThreadRecoveredEvent", extension: "json")
        
        try await URLProtocolMock.with(handlers: accept(url(equals: event.url.absoluteString), body: string(responseData.utf8string))) {
            XCTAssertNoThrow(try socketService.downloadEventContentFromS3(event))
        }
    }

    func testEndContactEventEncodedCorrectly() throws {
        let expectedData = try loadStubFromBundle(withName: "EndContact", extension: "json").decode() as EndContactEventDTO
        
        guard let threadId = UUID(uuidString: "AD342920-C75E-4B06-B973-00494CC811B7") else {
            throw XCTError("Unable to init thread ID")
        }
        let endContactEvent = EndContactEventDTO(
            eventType: .endContact,
            data: EndContactEventDataDTO(thread: threadId, contact: "12345")
        )
        
        XCTAssertEqual(expectedData.eventType, endContactEvent.eventType)
        XCTAssertEqual(expectedData.data.thread, endContactEvent.data.thread)
        XCTAssertEqual(expectedData.data.contact, endContactEvent.data.contact)
    }
    
    func testSetPositionInQueueEventDecodedCorrectly() throws {
        let event = try loadStubFromBundle(withName: "SetPositionInQueue", extension: "json").decode() as SetPositionInQueueEventDTO
        
        XCTAssertEqual(event.eventType, .setPositionInQueue)
        XCTAssertEqual(event.data.positionInQueue, 10)
    }
    
    func testHandleSetPositionInQueueEvent() async throws {
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(isOnline: true, isLiveChat: true))
        
        threadsService.threads.append(ChatThreadMapper.map(MockData.getThread(contactId: "12345")))

        let message = try loadStubFromBundle(withName: "SetPositionInQueue", extension: "json").utf8string
        
        CXoneChat.socketDelegateManager.handle(message: message)

        XCTAssertEqual(10, threadsService.threads.last?.positionInQueue)
    }
}
