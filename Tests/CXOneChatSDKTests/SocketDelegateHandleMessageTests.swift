// swiftlint:disable type_body_length

@testable import CXoneChatSDK
import XCTest


class SocketDelegateHandleMessageTests: CXoneXCTestCase {
    
    // MARK: - Properties
    
    private lazy var brand = BrandDTO(id: brandId)
    private lazy var channel = ChannelIdentifierDTO(id: channelId)
    private lazy var contact = ContactDTO(id: "", threadIdOnExternalPlatform: UUID(), status: .new, createdAt: Date(), customFields: [])
    private lazy var thread = ThreadDTO(id: nil, idOnExternalPlatform: UUID(), threadName: nil)
    private let message = MessageDTO(
        idOnExternalPlatform: UUID(),
        threadIdOnExternalPlatform: UUID(),
        contentType: .text(""),
        createdAt: Date(),
        attachments: [],
        direction: .inbound,
        userStatistics: .init(seenAt: nil, readAt: nil),
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
    
    func testHandleMessageNoThrowMissingEventDTO() throws {
        currentExpectation = XCTestExpectation(description: "Handle message decode error.")
        currentExpectation.isInverted = true
        
        let data = try loadStubFromBundle(withName: "MessageAddedIntoCaseEvent", extension: "json")
        
        CXoneChat.socketDelegateManager.handleMessage(message: data.utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testHandleMessageThrowsMissingEventDTO() {
        currentExpectation = XCTestExpectation(description: "Handle message decode error.")
        
        CXoneChat.socketDelegateManager.handleMessage(message: "message")
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testHandleMessageThrowsGenericError() throws {
        currentExpectation = XCTestExpectation(description: "Handle message decode error.")
        
        let error = GenericEventDTO(
            eventType: .archiveThread, postback: nil,
            error: .init(errorCode: .inconsistentData, transactionId: LowerCaseUUID(), errorMessage: ""),
            internalServerError: nil
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(error).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testNotifyAgentTypingStartedEventWithPostbackEventType() throws {
        currentExpectation = XCTestExpectation(description: "testNotifyAgentTypingStartedEventWithPostbackEventType")
        
        let event = GenericEventDTO(
            eventType: nil,
            postback: .init(eventType: .senderTypingStarted, threads: nil),
            error: nil,
            internalServerError: nil
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
    }
    
    func testNotifyAgentTypingStartedEventDTO() throws {
        currentExpectation = XCTestExpectation(description: "testNotifyAgentTypingStartedEvent")
        
        let event = AgentTypingEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .senderTypingStarted,
            createdAt: Date(),
            data: .init(brand: brand, channel: channel, thread: thread, user: agent)
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testNotifyAgentTypingEndEventDTO() throws {
        currentExpectation = XCTestExpectation(description: "testNotifyAgentTypingEndEvent")
        
        let event = AgentTypingEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .senderTypingEnded,
            createdAt: Date(),
            data: .init(brand: brand, channel: channel, thread: thread, user: agent)
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMessageCreatedEventThrows() throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageCreatedEventThrows")
        
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(.init(id: message.threadIdOnExternalPlatform))
        
        let event = MessageCreatedEventDTO(
            eventId: UUID(),
            eventObject: .message,
            eventType: .messageCreated,
            createdAt: Date(),
            data: MessageCreatedEventDataDTO(brand: brand, channel: channel, case: contact, thread: thread, message: message)
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMessageCreatedEventNoThrow() throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageCreatedEventNoThrow")
        
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(.init(id: UUID()))
        
        let event = MessageCreatedEventDTO(
            eventId: UUID(),
            eventObject: .message,
            eventType: .messageCreated,
            createdAt: Date(),
            data: MessageCreatedEventDataDTO(brand: brand, channel: channel, case: contact, thread: thread, message: message)
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessThreadRecoverEventDTO() throws {
        currentExpectation = XCTestExpectation(description: "testProcessThreadRecoverEvent")
        
        let event = AgentTypingEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .threadRecovered,
            createdAt: Date(),
            data: .init(brand: brand, channel: channel, thread: thread, user: agent)
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMessageReadChangeEventThrows() throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageReadChangeEventThrows")
        
        let event = GenericEventDTO(eventType: .messageReadChanged, postback: nil, error: nil, internalServerError: nil)
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMessageReadChangeEventNoThrow() throws {
        currentExpectation = XCTestExpectation(description: "testProcessMessageReadChangeEventNoThrow")
        
        let event = MessageReadByAgentEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .messageReadChanged,
            createdAt: Date(),
            data: .init(brand: brand, message: message)
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessInboxAssigneeChangeEventThrows() throws {
        currentExpectation = XCTestExpectation(description: "testProcessInboxAssigneeChangeEventThrows")
        
        let event = GenericEventDTO(eventType: .contactInboxAssigneeChanged, postback: nil, error: nil, internalServerError: nil)
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessInboxAssigneeChangeEventNoThrow() throws {
        currentExpectation = XCTestExpectation(description: "testProcessInboxAssigneeChangeEventNoThrow")
        
        let event = ContactInboxAssigneeChangedEventDTO(
            eventId: UUID(),
            eventObject: .thread,
            eventType: .contactInboxAssigneeChanged,
            createdAt: Date(),
            data: .init(brand: brand, channel: channel, case: contact, inboxAssignee: agent, previousInboxAssignee: nil)
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessThreadListFetchedEventDTO() throws {
        currentExpectation = XCTestExpectation(description: "testProcessThreadListFetchedEvent")
        
        let postbackData = ReceivedThreadDataDTO(
            id: "",
            idOnExternalPlatform: UUID(),
            channelId: "",
            threadName: "",
            createdAt: Date(),
            updatedAt: Date(),
            canAddMoreMessages: true
        )
        
        let event = GenericEventDTO(
            eventType: nil,
            postback: .init(eventType: .threadListFetched, threads: [postbackData]),
            error: nil,
            internalServerError: nil
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessCustomerAuthorizedEventThrowMissingAccessToken() throws {
        currentExpectation = XCTestExpectation(description: "testProcessCustomerAuthorizedEventThrowMissingAccessToken")
        
        socketService.connectionContext.channelConfig = .init(
            settings: .init(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: false),
            isAuthorizationEnabled: true
        )
        let event = CustomerAuthorizedEventDTO(
            eventId: UUID(),
            postback: .init(eventType: .customerAuthorized, data: .init(consumerIdentity: identity, accessToken: nil))
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessCustomerAuthorizedEventNoThrow() throws {
        currentExpectation = XCTestExpectation(description: "testProcessCustomerAuthorizedEventNoThrow")
        
        socketService.connectionContext.channelConfig = .init(
            settings: .init(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true),
            isAuthorizationEnabled: true
        )
        let event = CustomerAuthorizedEventDTO(
            eventId: UUID(),
            postback: .init(eventType: .customerAuthorized, data: .init(consumerIdentity: identity, accessToken: accessToken))
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessCustomerReconnectEventDTO() throws {
        currentExpectation = XCTestExpectation(description: "testProcessCustomerReconnectEvent")

        let event = GenericEventDTO(
            eventType: .customerReconnected,
            postback: nil,
            error: nil,
            internalServerError: nil
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMoreMessagesEventThrows() throws {
        currentExpectation = XCTestExpectation(description: "testProcessMoreMessagesEventThrows")
        
        let event = MoreMessagesLoadedEventDTO(
            eventId: UUID(),
            postback: .init(
                eventType: .moreMessagesLoaded,
                data: .init(messages: [], scrollToken: "scroll_token"))
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessMoreMessagesEventNoThrow() throws {
        currentExpectation = XCTestExpectation(description: "testProcessMoreMessagesEventNoThrow")
        
        let event = MoreMessagesLoadedEventDTO(
            eventId: UUID(),
            postback: .init(
                eventType: .moreMessagesLoaded,
                data: .init(messages: [message], scrollToken: "scroll_token"))
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testNotifyThreadArchivedEventDTO() throws {
        currentExpectation = XCTestExpectation(description: "testNotifyThreadArchivedEvent")
        
        let event = GenericEventDTO(eventType: .threadArchived, postback: nil, error: nil, internalServerError: nil)
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testTokenRefreshedEventDTO() throws {
        let event = TokenRefreshedEventDTO(
            eventId: UUID(),
            postback: .init(eventType: .tokenRefreshed, accessToken: accessToken)
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        XCTAssertEqual(socketService.accessToken?.token, accessToken.token)
    }
    
    func testProcessThreadLastMessageWithoutAgent() throws {
        currentExpectation = XCTestExpectation(description: "testProcessThreadLastMessageWithoutAgent")
        
        let event = ThreadMetadataLoadedEventDTO(
            eventId: UUID(),
            postback: .init(
                eventType: .threadMetadataLoaded,
                data: .init(ownerAssignee: nil, lastMessage: message)
            )
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessThreadLastMessageWithAgent() throws {
        currentExpectation = XCTestExpectation(description: "testProcessThreadLastMessageWithAgent")
        
        let event = ThreadMetadataLoadedEventDTO(
            eventId: UUID(),
            postback: .init(
                eventType: .threadMetadataLoaded,
                data: .init(ownerAssignee: agent, lastMessage: message)
            )
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testOnThreadUpdate() throws {
        currentExpectation = XCTestExpectation(description: "testOnThreadUpdate")
        
        let event = GenericEventDTO(eventType: .threadUpdated, postback: nil, error: nil, internalServerError: nil)
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessProactiveAction() throws {
        currentExpectation = XCTestExpectation(description: "testProcessProactiveAction")
        
        let event = ProactiveActionEventDTO(
            eventId: UUID(),
            eventObject: .message,
            eventType: .fireProactiveAction,
            createdAt: Date(),
            data: .init(
                eventId: LowerCaseUUID(),
                actionId: LowerCaseUUID(),
                actionName: "actionName",
                actionType: .welcomeMessage,
                data: nil
            )
        )
        
        CXoneChat.socketDelegateManager.handleMessage(message: try encoder.encode(event).utf8string)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
}


// MARK: - CXoneChatDelegate

extension SocketDelegateHandleMessageTests: CXoneChatDelegate {

    func onConnect() {
        fulfillExpectationIfNeeded()
    }
    
    func onError(_ error: Error) {
        fulfillExpectationIfNeeded()
    }
    
    func onThreadUpdate() {
        fulfillExpectationIfNeeded()
    }
    
    func onThreadLoad(_ thread: ChatThread) {
        fulfillExpectationIfNeeded()
    }
    
    func onThreadsLoad(_ threads: [ChatThread]) {
        fulfillExpectationIfNeeded()
    }
    
    func onThreadArchive() {
        fulfillExpectationIfNeeded()
    }
    
    func onAgentTyping(_ didEnd: Bool, threadId: UUID) {
        fulfillExpectationIfNeeded()
    }
    
    func onLoadMoreMessages(_ messages: [Message]) {
        fulfillExpectationIfNeeded()
    }
    
    func onNewMessage(_ message: Message) {
        fulfillExpectationIfNeeded()
    }
    
    func fulfillExpectationIfNeeded() {
        if !didCheckDelegate {
            currentExpectation.fulfill()
            didCheckDelegate = true
        }
    }
}
