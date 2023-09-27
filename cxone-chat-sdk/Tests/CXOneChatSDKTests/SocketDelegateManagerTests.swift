//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

// swiftlint:disable file_length type_body_length

@testable import CXoneChatSDK
import XCTest

class SocketDelegateManagerTests: CXoneXCTestCase {
    
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
    private let accessToken = AccessTokenDTO(token: "token", expiresIn: .max)
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
    
    private var currentExpectation = XCTestExpectation(description: "")
    private var didCheckDelegate = false
    
    private let encoder = JSONEncoder()
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        didCheckDelegate = false
        CXoneChat.delegate = self
    }
    
    // MARK: - Properties
    
    func testDidReceiveRecoveringThreadFailedError() async {
        currentExpectation = XCTestExpectation(description: "testDidReceiveRecoveringThreadFailedError")
        
        let error = OperationError(errorCode: .recoveringThreadFailed, transactionId: LowerCaseUUID(), errorMessage: "")
        
        CXoneChat.socketDelegateManager.didReceiveError(error)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testDidReceiveCustomerReconnectFailedErrorThrows() async {
        currentExpectation = XCTestExpectation(description: "testDidReceiveCustomerReconnectFailedErrorThrows")
        
        let error = OperationError(errorCode: .customerReconnectFailed, transactionId: LowerCaseUUID(), errorMessage: "")
        
        CXoneChat.socketDelegateManager.didReceiveError(error)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testDidReceiveCustomerReconnectFailedErrorNoThrow() async {
        currentExpectation = XCTestExpectation(description: "testDidReceiveCustomerReconnectFailedErrorNoThrow")
        
        socketService.accessToken = accessToken
        
        let error = OperationError(errorCode: .customerReconnectFailed, transactionId: LowerCaseUUID(), errorMessage: "")
        
        CXoneChat.socketDelegateManager.didReceiveError(error)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testDidReceiveTokenRefreshFailedError() async {
        currentExpectation = XCTestExpectation(description: "testDidReceiveTokenRefreshFailedError")
        
        let error = OperationError(errorCode: .tokenRefreshFailed, transactionId: LowerCaseUUID(), errorMessage: "")
        
        CXoneChat.socketDelegateManager.didReceiveError(error)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testDidCloseConnection() async {
        currentExpectation = XCTestExpectation(description: "testDidCloseConnection")
        
        CXoneChat.socketDelegateManager.didCloseConnection()
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMoreMessagesEventMissingContent() async {
        currentExpectation = XCTestExpectation(description: "testProcessMoreMessagesEventMissingContent")
        
        CXoneChat.socketDelegateManager.processMoreMessagesEvent(nil)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMessageCreatedEventServerError() throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageCreatedEventServerError")
        
        let error = ServerError(message: "error", connectionId: UUID(), requestId: UUID())
        
        try CXoneChat.socketDelegateManager.processMessageCreatedEvent(encoder.encode(error))
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMessageCreatedEventCustomData() throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageCreatedEventServerError")
        
        let data = try loadStubFromBundle(withName: "CustomMessageCreatedEvent", extension: "json")
        
        try CXoneChat.socketDelegateManager.processMessageCreatedEvent(data)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMessageCreatedEventMessageCreated() throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageCreatedEventServerError")
        
        let data = MessageCreatedEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .messageCreated,
            createdAt: dateProvider.now,
            data: MessageCreatedEventDataDTO(brand: brand, channel: channel, case: contact, thread: thread, message: message)
        )
        
        try CXoneChat.socketDelegateManager.processMessageCreatedEvent(encoder.encode(data))
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMessageReadChangeEventThrowsMissingTread() async {
        currentExpectation = XCTestExpectation(description: "testProcessMessageReadChangeEventThrowsMissingTread")
        
        let data = MessageReadByAgentEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .messageReadChanged,
            createdAt: dateProvider.now,
            data: MessageReadByAgentEventDataDTO(brand: brand, message: message)
        )
        
        CXoneChat.socketDelegateManager.processMessageReadChangeEvent(data)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMessageReadChangeEventThrowsMissingMessage() async {
        currentExpectation = XCTestExpectation(description: "testProcessMessageReadChangeEventNoThrow")
        
        var chatThread = ChatThread(id: thread.idOnExternalPlatform)
        let message = MessageDTO(
            idOnExternalPlatform: UUID(),
            threadIdOnExternalPlatform: chatThread.id,
            contentType: .text(MessagePayloadDTO(text: "", postback: nil)),
            createdAt: dateProvider.now,
            attachments: [],
            direction: .inbound,
            userStatistics: UserStatisticsDTO(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        chatThread.messages.append(MessageMapper.map(message))
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(chatThread)
        
        let data = MessageReadByAgentEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .messageReadChanged,
            createdAt: dateProvider.now,
            data: MessageReadByAgentEventDataDTO(brand: brand, message: message)
        )
        
        CXoneChat.socketDelegateManager.processMessageReadChangeEvent(data)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessProactiveActionThrowsMissingAction() async {
        currentExpectation = XCTestExpectation(description: "testProcessProactiveActionThrowsMissingAction")
        
        CXoneChat.socketDelegateManager.processProactiveAction(decode: nil, data: Data())
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessProactiveActionWelcomeMessageNoThrow() throws {
        currentExpectation = XCTestExpectation(description: "testProcessProactiveActionWelcomeMessageNoThrow")
        
        let data = try loadStubFromBundle(withName: "WelcomeMessage", extension: "json")
        let event = try JSONDecoder().decode(ProactiveActionEventDTO.self, from: data)
        
        CXoneChat.socketDelegateManager.processProactiveAction(decode: event, data: data)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessProactiveActionCustomPopupNoThrow() throws {
        currentExpectation = XCTestExpectation(description: "testProcessProactiveActionCustomPopupNoThrow")
        
        let data = try loadStubFromBundle(withName: "CustomPopup", extension: "json")
        let event = try JSONDecoder().decode(ProactiveActionEventDTO.self, from: data)
        
        CXoneChat.socketDelegateManager.processProactiveAction(decode: event, data: data)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testAssigneeDidChange() async {
        currentExpectation = XCTestExpectation(description: "testAssigneeDidChange")
        
        let thread = ChatThread(id: UUID())
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)
        
        CXoneChat.socketDelegateManager.assigneeDidChange(thread.id, agent: agent)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testAddMessageThrowsMissingFirstMessage() async {
        currentExpectation = XCTestExpectation(description: "testAddMessageThrows")
        
        CXoneChat.socketDelegateManager.addMessages(messages: [], scrollToken: "")
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testAddMessageWithMessages() async {
        currentExpectation = XCTestExpectation(description: "testAddMessageThrows")
        
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(
            ChatThread(id: message.threadIdOnExternalPlatform, messages: [MessageMapper.map(message)])
        )
        
        CXoneChat.socketDelegateManager.addMessages(messages: [message], scrollToken: "token")
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testDidUploadAttachmentsNoThrow() async {
        currentExpectation = XCTestExpectation(description: "testDidUploadAttachmentsNoThrow")
        currentExpectation.isInverted = true
        
        let event = EventDTO(brandId: brandId, channelId: channelId, customerIdentity: identity, eventType: .messageCreated, data: nil)
        
        CXoneChat.socketDelegateManager.didUploadAttachments(event)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testThreadRecoverWithEmptyMessages() async {
        currentExpectation = XCTestExpectation(description: "testThreadRecoverWithEmptyMessages")
        
        let thread = ChatThread(id: UUID())
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)
        
        let data = ThreadRecoveredEventDTO(
            eventId: UUID(),
            postback: ThreadRecoveredEventPostbackDTO(
                eventType: .threadRecovered,
                data: ThreadRecoveredEventPostbackDataDTO(
                    consumerContact: contact,
                    messages: [],
                    inboxAssignee: nil,
                    thread: ReceivedThreadDataDTO(
                        idOnExternalPlatform: thread.id,
                        channelId: channelId,
                        threadName: thread.name ?? "",
                        canAddMoreMessages: thread.canAddMoreMessages
                    ),
                    messagesScrollToken: "scroll_token",
                    customerContactFields: []
                )
            )
        )
        
        CXoneChat.socketDelegateManager.threadRecovered(data)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testThreadRecoverWithNewMessages() async {
        currentExpectation = XCTestExpectation(description: "testThreadRecoverWithDifferentMessages")
        
        let thread = ChatThread(id: UUID())
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)
        
        let data = ThreadRecoveredEventDTO(
            eventId: UUID(),
            postback: ThreadRecoveredEventPostbackDTO(
                eventType: .threadRecovered,
                data: ThreadRecoveredEventPostbackDataDTO(
                    consumerContact: contact,
                    messages: [message],
                    inboxAssignee: nil,
                    thread: ReceivedThreadDataDTO(
                        idOnExternalPlatform: thread.id,
                        channelId: channelId,
                        threadName: thread.name ?? "",
                        canAddMoreMessages: thread.canAddMoreMessages
                    ),
                    messagesScrollToken: "scroll_token",
                    customerContactFields: []
                )
            )
        )
        
        CXoneChat.socketDelegateManager.threadRecovered(data)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testThreadRecoverWitOldMessages() async {
        currentExpectation = XCTestExpectation(description: "testThreadRecoverWitOldMessages")
        
        let message = MessageDTO(
            idOnExternalPlatform: UUID(),
            threadIdOnExternalPlatform: thread.idOnExternalPlatform,
            contentType: .text(MessagePayloadDTO(text: "", postback: nil)),
            createdAt: dateProvider.now,
            attachments: [],
            direction: .inbound,
            userStatistics: UserStatisticsDTO(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        let thread = ChatThread(id: UUID(), messages: [MessageMapper.map(message)])
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)
        
        let data = ThreadRecoveredEventDTO(
            eventId: UUID(),
            postback: ThreadRecoveredEventPostbackDTO(
                eventType: .threadRecovered,
                data: ThreadRecoveredEventPostbackDataDTO(
                    consumerContact: contact,
                    messages: [message],
                    inboxAssignee: nil,
                    thread: ReceivedThreadDataDTO(
                        idOnExternalPlatform: thread.id,
                        channelId: channelId,
                        threadName: thread.name ?? "",
                        canAddMoreMessages: thread.canAddMoreMessages
                    ),
                    messagesScrollToken: "scroll_token",
                    customerContactFields: []
                )
            )
        )
        
        CXoneChat.socketDelegateManager.threadRecovered(data)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testLoadThreadDataThrows() async {
        currentExpectation = XCTestExpectation(description: "testLoadThreadDataThrows")
        
        CXoneChat.socketDelegateManager.loadThreadData()
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testLoadThreadDataNoThrow() async throws {
        currentExpectation = XCTestExpectation(description: "testLoadThreadDataNoThrow")
        currentExpectation.isInverted = true
        
        try await super.setUpConnection()
        
        CXoneChat.socketDelegateManager.loadThreadData()
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testLoadThreadsDataNoThrow() async throws {
        currentExpectation = XCTestExpectation(description: "testLoadThreadDataNoThrow")
        currentExpectation.isInverted = true
        
        try await super.setUpConnection()
        
        socketService.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )
        
        CXoneChat.socketDelegateManager.loadThreadData()
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
}

// MARK: - CXoneChatDelegate

extension SocketDelegateManagerTests: CXoneChatDelegate {

    func onThreadLoadFail(_ error: Error) {
        fulfillExpectationIfNeeded()
    }

    func onThreadLoad(_ thread: ChatThread) {
        fulfillExpectationIfNeeded()
    }
    
    func onThreadsLoad(_ threads: [ChatThread]) {
        fulfillExpectationIfNeeded()
    }
    
    func onLoadMoreMessages(_ messages: [Message]) {
        fulfillExpectationIfNeeded()
    }
    
    func onCustomPluginMessage(_ messageData: [Any]) {
        fulfillExpectationIfNeeded()
    }
    
    func onError(_ error: Error) {
        fulfillExpectationIfNeeded()
    }
    
    func onAgentChange(_ agent: Agent, for threadId: UUID) {
        fulfillExpectationIfNeeded()
    }
    
    func onTokenRefreshFailed() {
        fulfillExpectationIfNeeded()
    }
    
    func onAgentReadMessage(threadId: UUID) {
        fulfillExpectationIfNeeded()
    }
    
    func onUnexpectedDisconnect() {
        fulfillExpectationIfNeeded()
    }
    
    func onWelcomeMessageReceived() {
        fulfillExpectationIfNeeded()
    }
    
    func onProactivePopupAction(data: [String: Any], actionId: UUID) {
        fulfillExpectationIfNeeded()
    }
    
    func fulfillExpectationIfNeeded() {
        if !didCheckDelegate {
            currentExpectation.fulfill()
            didCheckDelegate = true
        }
    }
}
