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

// swiftlint:disable file_length type_body_length

@testable import CXoneChatSDK
import XCTest

class SocketDelegateManagerTests: CXoneXCTestCase {
    
    // MARK: - Properties
    
    private lazy var brand = BrandDTO(id: brandId)
    private lazy var channel = ChannelIdentifierDTO(id: channelId)
    private lazy var contact = ContactDTO(id: UUID().uuidString, threadIdOnExternalPlatform: UUID(), status: .new, createdAt: dateProvider.now, customFields: [])
    private lazy var thread = ThreadDTO(idOnExternalPlatform: UUID(), threadName: nil)
    private lazy var message = MessageDTO(
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
    
    func testDidReceiveCustomerReconnectFailedErrorThrows() async {
        currentExpectation = XCTestExpectation(description: "testDidReceiveCustomerReconnectFailedErrorThrows")
        
        let error = OperationError(errorCode: .customerReconnectFailed, transactionId: LowerCaseUUID(), errorMessage: "")
        
        CXoneChat.socketDelegateManager.didReceiveError(error)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testDidReceiveCustomerReconnectFailedErrorNoThrow() async {
        currentExpectation = XCTestExpectation(description: "testDidReceiveCustomerReconnectFailedErrorNoThrow")
        
        socketService.accessToken = accessToken
        
        let error = OperationError(errorCode: .customerReconnectFailed, transactionId: LowerCaseUUID(), errorMessage: "")
        
        CXoneChat.socketDelegateManager.didReceiveError(error)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testDidReceiveTokenRefreshFailedError() async {
        currentExpectation = XCTestExpectation(description: "testDidReceiveTokenRefreshFailedError")
        
        let error = OperationError(errorCode: .tokenRefreshFailed, transactionId: LowerCaseUUID(), errorMessage: "")
        
        CXoneChat.socketDelegateManager.didReceiveError(error)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testDidCloseConnection() async {
        currentExpectation = XCTestExpectation(description: "testDidCloseConnection")
        
        CXoneChat.socketDelegateManager.didCloseConnection()
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMessageCreatedEventThrowsServerError() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageCreatedEventServerError")
        
        let error = ServerError(message: "error", connectionId: UUID(), requestId: UUID())
        
        CXoneChat.socketDelegateManager.handle(message: try encoder.encode(error).utf8string)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMessageCreatedEventMessageCreated() async throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageCreatedEventServerError")
        
        threadsService.threads.append(ChatThreadMapper.map(MockData.getThread(threadId: thread.idOnExternalPlatform)))
        let event = MessageCreatedEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .messageCreated,
            createdAt: dateProvider.now,
            data: MessageCreatedEventDataDTO(brand: brand, channel: channel, case: contact, thread: thread, message: message)
        )
        
        try threadsService.processMessageCreatedEvent(event)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMessageReadChangeEventThrowsInvalidThread() {
        let event = MessageReadByAgentEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .messageReadChanged,
            createdAt: dateProvider.now,
            data: MessageReadByAgentEventDataDTO(brand: brand, message: message)
        )
        
        XCTAssertThrowsError(try threadsService.processMessageReadChangeEvent(event)) { error in
            XCTAssertEqual(error as? CXoneChatError, CXoneChatError.invalidThread)
        }
    }
    
    func testProcessProactiveActionThrowsMissingAction() {
        let invalidData = Data()
        
        XCTAssertThrowsError(try connectionService.processProactiveAction(invalidData))
    }
    
    func testProcessProactiveActionWelcomeMessageNoThrow() {
        let thread = ChatThread(id: UUID(), state: .received)
        threadsService.threads.append(thread)
        eventsService.connectionContext.activeThread = thread
        
        XCTAssertNoThrow(
            try connectionService.processProactiveAction(try loadStubFromBundle(withName: "FireProactiveAction+WelcomeMessage", extension: "json"))
        )
    }
    
    func testProcessProactiveActionCustomPopupNoThrow() {
        XCTAssertNoThrow(try connectionService.processProactiveAction(try loadStubFromBundle(withName: "CustomPopup", extension: "json")))
    }
    
    func testThreadRecoverWithEmptyMessages() async throws {
        currentExpectation = XCTestExpectation(description: "testThreadRecoverWithEmptyMessages")
        
        let thread = ChatThread(id: UUID(), state: .received)
        threadsService.threads.append(thread)
        
        try threadsService.processThreadRecoveredEvent(
            ThreadRecoveredEventDTO(
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
                            canAddMoreMessages: thread.state != .closed
                        ),
                        messagesScrollToken: "scroll_token",
                        customerContactFields: []
                    )
                )
            )
        )
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testThreadRecoverWithNewMessages() async throws {
        currentExpectation = XCTestExpectation(description: "testThreadRecoverWithDifferentMessages")
        
        let thread = ChatThread(id: UUID(), state: .ready)
        threadsService.threads.append(thread)
        
        try threadsService.processThreadRecoveredEvent(
            ThreadRecoveredEventDTO(
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
                            canAddMoreMessages: thread.state != .closed
                        ),
                        messagesScrollToken: "scroll_token",
                        customerContactFields: []
                    )
                )
            )
        )
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testThreadRecoverWitOldMessages() async throws {
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
        
        let thread = ChatThread(id: UUID(), messages: [MessageMapper.map(message)], state: .ready)
        threadsService.threads.append(thread)
        
        try threadsService.processThreadRecoveredEvent(
            ThreadRecoveredEventDTO(
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
                            canAddMoreMessages: thread.state != .closed
                        ),
                        messagesScrollToken: "scroll_token",
                        customerContactFields: []
                    )
                )
            )
        )
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
}
