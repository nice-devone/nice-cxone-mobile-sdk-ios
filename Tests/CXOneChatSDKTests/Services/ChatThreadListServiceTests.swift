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

import Combine
@testable import CXoneChatSDK
import Mockable
import XCTest

@available(iOS 16.0, *)
class ChatThreadListServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    private let socketService = MockSocketService()
    private let connectionContext = MockConnectionContext()
    private let welcomeMessageManager = WelcomeMessageManager()
    private let uuidProvider = MockUUIDProvider()
    private let subject = PassthroughSubject<ReceivedEvent, Never>()
    private let delegate = MockCXoneChatDelegate()
    
    private var service: ChatThreadListService?
    private var connectionService: ConnectionService?
    
    private lazy var events = subject.eraseToAnyPublisher()
    private lazy var eventsService = EventsService(connectionContext: connectionContext)
    
    private static let brandId = 1386
    private static let channelId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
    private static let visitorId = UUID()
    private static let channelURL = "https://channels-de-na1.niceincontact.com/chat/1.0/brand/1386/channel"
    private static let socketURL = "wss://chat-gateway-de-na1.niceincontact.com"
    
    // MARK: - Lifecycle
    
    override func setUp() {
        given(socketService)
            .events.willReturn(events)
            .cancellables.willReturn([])
            .connectionContext.willReturn(connectionContext)

        given(connectionContext)
            .brandId.willReturn(Self.brandId)
            .channelId.willReturn(Self.channelId)
            .visitorId.willReturn(Self.visitorId)
            .environment.willReturn(CustomEnvironment(chatURL: Self.channelURL, socketURL: Self.socketURL))
            .authorizationCode.willReturn("")
            .codeVerifier.willReturn("")
            .customer.willReturn(MockData.customerIdentity)
        
        let contactFieldsService = ContactCustomFieldsService(socketService: socketService, eventsService: eventsService)
        let customerFieldsService = CustomerCustomFieldsService(socketService: socketService, eventsService: eventsService)
        
        let threadsService = ChatThreadListService(
            contactCustomFields: contactFieldsService,
            customerCustomFields: customerFieldsService,
            socketService: socketService,
            eventsService: eventsService,
            welcomeMessageManager: welcomeMessageManager,
            delegate: delegate
        )
        self.service = threadsService
        
        let customer = CustomerService(socketService: socketService, threads: threadsService, delegate: delegate)
        
        connectionService = ConnectionService(
            customer: customer,
            threads: threadsService,
            customerFields: customerFieldsService,
            socketService: socketService,
            eventsService: eventsService,
            delegate: delegate
        )
        connectionService?.registerListeners = { }
        
        UUID.provider = uuidProvider
    }
    
    // MARK: - Tests

    func testGetPrechatEmpty() {
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration())
        
        XCTAssertNil(nil)
    }
    
    func testGetPrechatNoEmpty() {
        given(connectionContext)
            .channelConfig.willReturn(
                MockData.getChannelConfiguration(
                    prechatSurvey: PreChatSurveyDTO(
                        name: "Prechat Survey",
                        customFields: [
                            PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.nameTextCustomField)),
                            PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.emailTextCustomField)),
                            PreChatSurveyCustomFieldDTO(isRequired: true, type: .selector(MockData.genderSelectorCustomField)),
                            PreChatSurveyCustomFieldDTO(isRequired: true, type: .hierarchical(MockData.optionsHierarchicalCustomField))
                        ]
                    )
                )
            )
        
        XCTAssertNotNil(service!.preChatSurvey)
        XCTAssertEqual(service!.preChatSurvey?.name, "Prechat Survey")
        XCTAssertEqual(service!.preChatSurvey?.customFields.count, 4)
    }
    
    func testCreateThreadThrowsNotConnected() async {
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .checkForConnection().willThrow(CXoneChatError.notConnected)
        
        await XCTAssertAsyncThrowsError(try await service!.create()) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, .notConnected)
        }
        
        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(0)
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testCreateThreadThrowsUnsupportedChannelConfig() async {
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: false))
        
        given(socketService)
            .checkForConnection().willReturn()
        
        service!.threads = [MockData.getThread()]
        
        await XCTAssertAsyncThrowsError(try await service!.create()) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, .unsupportedChannelConfig)
        }
        
        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(0)
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testCreateThreadThrowsMissingPrechatCustomFields() async {
        given(uuidProvider)
            .next.willReturn(UUID())
        
        given(connectionContext)
            .channelConfig.willReturn(
                MockData.getChannelConfiguration(
                    isMultithread: true,
                    prechatSurvey: PreChatSurveyDTO(name: "pre-chat", customFields: [
                        PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.nameTextCustomField))
                    ])
                )
            )
        
        given(socketService)
            .checkForConnection().willReturn()
        
        await XCTAssertAsyncThrowsError(try await service!.create()) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, .missingPreChatCustomFields)
        }
        
        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(0)
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testCreateThreadSuccess() async throws {
        given(uuidProvider)
            .next.willReturn(UUID())
        
        given(connectionContext)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: false))
        
        given(socketService)
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
            .onChatUpdated(.any, mode: .any).willReturn()
        
        try await service!.create()
        
        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(0)
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
    }
    
    func testCreateThreadWithAdditionalCustomFieldsSuccess() async throws {
        let threadId = UUID()
        let customFields = ["foo": "bar"]
        
        given(uuidProvider)
            .next.willReturn(threadId)
        
        given(connectionContext)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: false))
        
        given(socketService)
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
            .onChatUpdated(.any, mode: .any).willReturn()
        
        try await service!.create(with: customFields)
        
        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(0)
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
    }

    func testCreateWithRequiredPrechatTextCustomFieldNoThrow() async throws {
        let eventId = UUID()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(socketService)
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
            .onChatUpdated(.any, mode: .any).willReturn()
        
        given(connectionContext)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(
                MockData.getChannelConfiguration(
                    prechatSurvey: PreChatSurveyDTO(
                        name: "Prechat Survey",
                        customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.nameTextCustomField))])
                )
            )
        
        try await service!.create(with: ["firstName": "Peter"])
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
        
        XCTAssertFalse(service!.customFields.get(for: eventId).isEmpty)
    }
    
    func testCreateWithoutOptionalPrechatTextCustomFieldNoThrow() async throws {
        let eventId = UUID()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(socketService)
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
            .onChatUpdated(.any, mode: .any).willReturn()
        
        given(connectionContext)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(
                MockData.getChannelConfiguration(
                    prechatSurvey: PreChatSurveyDTO(
                        name: "Prechat Survey",
                        customFields: [PreChatSurveyCustomFieldDTO(isRequired: false, type: .textField(MockData.nameTextCustomField))])
                )
            )
        
        try await service!.create()
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
    }
    
    func testCreateWithRequiredPrechatEmailCustomFieldNoThrow() async throws {
        let eventId = UUID()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(socketService)
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
            .onChatUpdated(.any, mode: .any).willReturn()
        
        given(connectionContext)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(
                MockData.getChannelConfiguration(
                    prechatSurvey: PreChatSurveyDTO(
                        name: "Prechat Survey",
                        customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.emailTextCustomField))])
                )
            )
        
        try await service!.create(with: ["email": "john.doe@email.com"])
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
        
        XCTAssertFalse(service!.customFields.get(for: eventId).isEmpty)
    }
    
    func testCreateWithoutOptionalPrechatEmailCustomFieldNoThrow() async throws {
        let eventId = UUID()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(socketService)
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
            .onChatUpdated(.any, mode: .any).willReturn()
        
        given(connectionContext)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(
                MockData.getChannelConfiguration(
                    prechatSurvey: PreChatSurveyDTO(
                        name: "Prechat Survey",
                        customFields: [PreChatSurveyCustomFieldDTO(isRequired: false, type: .textField(MockData.emailTextCustomField))])
                )
            )
        
        try await service!.create()
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
    }
    
    func testCreateWithRequiredPrechatSelectorCustomFieldNoThrow() async throws {
        let eventId = UUID()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(socketService)
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
            .onChatUpdated(.any, mode: .any).willReturn()
        
        given(connectionContext)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(
                MockData.getChannelConfiguration(
                    prechatSurvey: PreChatSurveyDTO(
                        name: "Prechat Survey",
                        customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .selector(MockData.genderSelectorCustomField))])
                )
            )
        
        let provider = try await service!.create(with: ["gender": "gender-male"])
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
        
        XCTAssertFalse(service!.customFields.get(for: provider.chatThread.id).isEmpty)
    }
    
    func testCreateWithoutOptionalPrechatSelectorCustomFieldNoThrow() async throws {
        let eventId = UUID()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(socketService)
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
            .onChatUpdated(.any, mode: .any).willReturn()
        
        given(connectionContext)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(
                MockData.getChannelConfiguration(
                    prechatSurvey: PreChatSurveyDTO(
                        name: "Prechat Survey",
                        customFields: [PreChatSurveyCustomFieldDTO(isRequired: false, type: .selector(MockData.genderSelectorCustomField))])
                )
            )
        
        try await service!.create()
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
    }

    func testCreateWithRequiredPrechatHierarchicalCustomFieldNoThrow() async throws {
        let eventId = UUID()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(socketService)
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
            .onChatUpdated(.any, mode: .any).willReturn()
        
        given(connectionContext)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(
                MockData.getChannelConfiguration(
                    prechatSurvey: PreChatSurveyDTO(
                        name: "Prechat Survey",
                        customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .hierarchical(MockData.optionsHierarchicalCustomField))])
                )
            )
        
        try await service!.create(with: ["options": "option-b-1"])
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
        
        XCTAssertFalse(service!.customFields.get(for: eventId).isEmpty)
    }
    
    func testCreateWithoutOptionalPrechatHierarchicalCustomFieldNoThrow() async throws {
        let eventId = UUID()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(socketService)
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
            .onChatUpdated(.any, mode: .any).willReturn()
        
        given(connectionContext)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(
                MockData.getChannelConfiguration(
                    prechatSurvey: PreChatSurveyDTO(
                        name: "Prechat Survey",
                        customFields: [PreChatSurveyCustomFieldDTO(isRequired: false, type: .hierarchical(MockData.optionsHierarchicalCustomField))])
                )
            )
        
        try await service!.create()
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
    }
    
    func testCustomFieldsAreSetAfterCreate() async throws {
        let eventId = UUID()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(socketService)
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
            .onChatUpdated(.any, mode: .any).willReturn()
        
        given(connectionContext)
            .contactId.willReturn(nil)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(
                MockData.getChannelConfiguration(
                    prechatSurvey: PreChatSurveyDTO(
                        name: "Prechat Survey",
                        customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.emailTextCustomField))])
                )
            )
        
        let provider = try await service!.create(with: ["email": "john.doe@email.com"])
        
        try await service!.customFields.set(["firstName": "John", "gender": "Male"], for: provider.chatThread.id)
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
        
        XCTAssertFalse(service!.customFields.get(for: provider.chatThread.id).isEmpty)
        XCTAssertEqual(service!.customFields.get(for: provider.chatThread.id).count, 3)
    }
    
    func testCreateLivechatThreadSuccess() async throws {
        let eventId = UUID()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .deviceToken.willReturn(nil)
            .accessToken.willReturn(nil)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isOnline: true, isLiveChat: true))
        
        given(socketService)
            .cancellables.willReturn([])
            .accessToken.willReturn(nil)
            .checkForConnection().willReturn()
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                self.subject.send(GenericEventDTO(eventId: eventId, eventType: nil, postback: nil))
            }
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
            .onChatUpdated(.any, mode: .any).willReturn()
        
        try await service!.create()
        
        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(1)
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
    }
    
    func testCreateLivechatThreadFailedToSendBeginConversation() async {
        let eventId = UUID()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .deviceToken.willReturn(nil)
            .accessToken.willReturn(nil)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isOnline: true, isLiveChat: true))
        
        given(socketService)
            .cancellables.willReturn([])
            .accessToken.willReturn(nil)
            .checkForConnection().willReturn()
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                self.subject.send(
                    OperationError(
                        eventId: UUID.provide(),
                        errorCode: .inconsistentData,
                        transactionId: eventId.asLowerCaseUUID,
                        errorMessage: "error"
                    )
                )
            }
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
            .onChatUpdated(.any, mode: .any).willReturn()
        
        await XCTAssertAsyncThrowsError(try await service!.create()) { error in
            self.XCTAssertIs(error, OperationError.self)
            XCTAssertEqual((error as! OperationError).errorCode, .inconsistentData)
        }
        
        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(1)
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0) // Not called because the message content is Begin Conversation
    }
    
    func testRecoverMessagingSingleThreadAutomatedLoadNoThrow() async throws {
        let eventId = UUID()
        var didAuthorize = false
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: false))
            .chatState.willReturn(.prepared)
        
        given(delegate)
            .onChatUpdated(.any, mode: .any).willReturn()
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                if !didAuthorize {
                    didAuthorize = true
                    
                    self.subject.send(MockData.getCustomerAuthorizedEvent(eventId: eventId))
                } else {
                    self.subject.send(MockData.getThreadRecoveredEvent(eventId: eventId, channelId: Self.channelId))
                }
            }
            .disconnect(unexpectedly: .any).willReturn()
            .checkForConnection().willReturn()
            .connect(socketURL: .any).willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }
        
        try await connectionService!.connect()
        
        await fulfillment(of: [expectation], timeout: 10)
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
        
        verify(socketService)
            .send(data: .any, shouldCheck: .any)
            .called(2)
    }
    
    func testRecoverMessagingMultiThreadAutomatedLoadNoThrow() async throws {
        enum TestStep {
            case authorize
            case fetchThreadList
            case loadThreadMetadata
        }
        
        let eventId = UUID()
        var testStep: TestStep = .authorize
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
            .chatState.willReturn(.prepared)
        
        given(delegate)
            .onChatUpdated(.any, mode: .any).willReturn()
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                switch testStep {
                case .authorize:
                    self.subject.send(MockData.getCustomerAuthorizedEvent(eventId: eventId))
                    testStep = .fetchThreadList
                case .fetchThreadList:
                    self.subject.send(MockData.getThreadListFetchedEvent(eventId: eventId, channelId: Self.channelId))
                    testStep = .loadThreadMetadata
                case .loadThreadMetadata:
                    self.subject.send(MockData.getThreadMetadataLoadedEvent(eventId: eventId))
                }
            }
            .disconnect(unexpectedly: .any).willReturn()
            .checkForConnection().willReturn()
            .connect(socketURL: .any).willReturn()
        
        given(delegate)
            .onThreadsUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }
        
        try await connectionService!.connect()
        
        await fulfillment(of: [expectation], timeout: 10)
        
        verify(delegate)
            .onThreadsUpdated(.any)
            .called(1)
        
        verify(socketService)
            .send(data: .any, shouldCheck: .any)
            .called(3)
    }
    
    func testRecoverLivechatThreadAutomatedLoadNoThrow() async throws {
        let eventId = UUID()
        var didAuthorize = false
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isOnline: true, isLiveChat: true))
            .chatState.willReturn(.prepared)
        
        given(delegate)
            .onChatUpdated(.any, mode: .any).willReturn()
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                if !didAuthorize {
                    didAuthorize = true
                    
                    self.subject.send(MockData.getCustomerAuthorizedEvent(eventId: eventId))
                } else {
                    self.subject.send(MockData.getLivechatRecoveredEvent(eventId: eventId, channelId: Self.channelId))
                }
            }
            .disconnect(unexpectedly: .any).willReturn()
            .checkForConnection().willReturn()
            .connect(socketURL: .any).willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }
        
        try await connectionService!.connect()
        
        await fulfillment(of: [expectation], timeout: 10)
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
        
        verify(socketService)
            .send(data: .any, shouldCheck: .any)
            .called(2)
    }
    
    func testRecoverMessagingThreadThrowsNotConnected() async {
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .checkForConnection().willThrow(CXoneChatError.notConnected)
        
        await XCTAssertAsyncThrowsError(try await service!.load(with: UUID())) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, .notConnected)
        }
        
        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(0)
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testRecoverMessagingThreadLocalThreadSuccess() async throws {
        let threadId = UUID()
        let thread = MockData.getThread(threadId: threadId, state: .pending)
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(threadId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
            .chatState.willReturn(.connected)
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.matching({ $0.id == threadId })).willProduce({ _ in
                expectation.fulfill()
                return()
            })
            .onChatUpdated(.any, mode: .any).willReturn()
        
        service!.threads = [thread]
        
        try await service!.load(with: threadId)
        
        await fulfillment(of: [expectation], timeout: 10)
        
        verify(delegate)
            .onThreadUpdated(.matching({ $0.id == threadId }))
            .called(1)
            .onChatUpdated(.any, mode: .any)
            .called(1)
    }
    
    func testRecoverMessagingSingleThread() async throws {
        let threadId = UUID()
        let thread = MockData.getThread(threadId: threadId, state: .ready)
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(threadId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: false))
            .chatState.willReturn(.connected)
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce({ _, _ in
                self.subject.send(MockData.getThreadRecoveredEvent(eventId: threadId, channelId: Self.channelId))
            })
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.matching({ $0.id == threadId })).willProduce({ _ in
                expectation.fulfill()
                return()
            })
            .onChatUpdated(.any, mode: .any).willReturn()
        
        service!.threads = [thread]
        
        try await service!.load(with: threadId)
        
        await fulfillment(of: [expectation], timeout: 10)
        
        verify(delegate)
            .onThreadUpdated(.matching({ $0.id == threadId }))
            .called(1)
            .onChatUpdated(.any, mode: .any)
            .called(1)
    }
    
    func testRecoverMessagingMultiThread() async throws {
        let threadId = UUID()
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(threadId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
            .chatState.willReturn(.connected)
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce({ _, _ in
                self.subject.send(MockData.getThreadRecoveredEvent(eventId: threadId, channelId: Self.channelId))
            })
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.matching({ $0.id == threadId })).willProduce({ _ in
                expectation.fulfill()
                return()
            })
            .onChatUpdated(.any, mode: .any).willReturn()
        
        try await service!.load(with: threadId)
        
        await fulfillment(of: [expectation], timeout: 10)
        
        verify(delegate)
            .onThreadUpdated(.matching({ $0.id == threadId }))
            .called(1)
            .onChatUpdated(.any, mode: .any)
            .called(1)
    }
    
    func testRecoverLivechatThreadThrowsNotConnected() async {
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .checkForConnection().willThrow(CXoneChatError.notConnected)
        
        await XCTAssertAsyncThrowsError(try await service!.load(with: UUID())) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, .notConnected)
        }
        
        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(0)
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testRecoverClosedLivechatThread() async throws {
        let threadId = UUID()
        
        given(uuidProvider)
            .next.willReturn(threadId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isOnline: true, isLiveChat: true))
            .chatState.willReturn(.connected)
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce({ _, _ in
                self.subject.send(MockData.getLivechatRecoveredEvent(eventId: threadId, channelId: Self.channelId, contactStatus: .closed))
            })
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
            .onChatUpdated(.any, mode: .any).willReturn()
        
        try await service!.load(with: threadId)
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
            .onChatUpdated(.any, mode: .any)
            .called(1)
    }
    
    func testRecoverLivechatThreadSuccess() async throws {
        let threadId = UUID()
        let thread = MockData.getThread(threadId: threadId, state: .ready)
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(threadId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isOnline: true, isLiveChat: true))
            .chatState.willReturn(.connected)
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce({ _, _ in
                self.subject.send(MockData.getLivechatRecoveredEvent(eventId: threadId, channelId: Self.channelId))
            })
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.matching({ $0.id == threadId })).willProduce({ _ in
                expectation.fulfill()
                return()
            })
            .onChatUpdated(.any, mode: .any).willReturn()
        
        service!.threads = [thread]
        
        try await service!.load(with: threadId)
        
        await fulfillment(of: [expectation], timeout: 10)
        
        verify(delegate)
            .onThreadUpdated(.matching({ $0.id == threadId }))
            .called(1)
            .onChatUpdated(.any, mode: .any)
            .called(1)
    }
    
    func testGetProviderWithThreadIdThrowsInvalidThread() async {
        let threadId = UUID()
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        XCTAssertThrowsError(try service!.provider(for: threadId)) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, .invalidThread)
        }
    }
    
    func testGetProviderWithThreadThrowsInvalidThread() async {
        let thread = MockData.getThread()
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        XCTAssertThrowsError(try service!.provider(for: thread)) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, .invalidThread)
        }
    }
    
    func testGetProviderWithThreadIdNoThrow() async throws {
        let threadId = UUID()
        let thread = MockData.getThread(threadId: threadId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        service!.threads = [thread]
        
        let provider = try service!.provider(for: threadId)
        
        XCTAssertEqual(thread.id, provider.chatThread.id)
    }
    
    func testGetProviderWithThreadNoThrow() async throws {
        let threadId = UUID()
        let thread = MockData.getThread(threadId: threadId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        service!.threads = [thread]
        
        let provider = try service!.provider(for: thread)
        
        XCTAssertEqual(thread.id, provider.chatThread.id)
    }
    
    func testFetchThreadListSinglethreadThrowsUnsupportedChannelConfig() async {
        given(uuidProvider)
            .next.willReturn(UUID())
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: false))
        
        await XCTAssertAsyncThrowsError(try await service!.fetchThreadList()) { error in
            XCTAssertEqual(error as! CXoneChatError, .unsupportedChannelConfig)
        }
    }
    
    func testFetchThreadListLivechatThrowsUnsupportedChannelConfig() async {
        given(uuidProvider)
            .next.willReturn(UUID())
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isLiveChat: true))
        
        await XCTAssertAsyncThrowsError(try await service!.fetchThreadList()) { error in
            XCTAssertEqual(error as! CXoneChatError, .unsupportedChannelConfig)
        }
    }
    
    func testFetchThreadListSuccess() async throws {
        var shouldLoadMetadata = false
        let eventId = UUID()
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
            .chatState.willReturn(.connected)
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                if shouldLoadMetadata {
                    self.subject.send(MockData.getThreadMetadataLoadedEvent(eventId: eventId))
                } else {
                    self.subject.send(
                        GenericEventDTO(
                            eventId: eventId,
                            eventType: .threadListFetched,
                            postback: GenericEventPostbackDTO(
                                eventType: .threadListFetched,
                                threads: [
                                    ReceivedThreadDataDTO(idOnExternalPlatform: eventId, channelId: Self.channelId, threadName: "", canAddMoreMessages: true)
                                ]
                            )
                        )
                    )
                    
                    shouldLoadMetadata = true
                }
            }
        
        given(delegate)
            .onChatUpdated(.any, mode: .any).willReturn()
            .onThreadsUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }
        
        try await service!.fetchThreadList()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        verify(delegate)
            .onThreadsUpdated(.any)
            .called(1)
        
        verify(socketService)
            .send(data: .any, shouldCheck: .any)
            .called(2)
    }

    func testLiveChatDoesNotFailToggleDisabled() async throws {
        let eventId = UUID()
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .deviceToken.willReturn(nil)
            .chatState.willReturn(.connected)
            .channelConfig.willReturn(
                MockData.getChannelConfiguration(features: ["isRecoverLivechatDoesNotFailEnabled": false], isOnline: true, isLiveChat: true)
            )
        
        given(socketService)
            .accessToken.willReturn(nil)
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                self.subject.send(GenericEventDTO(eventId: eventId, eventType: nil, postback: nil))
            }
            .checkForConnection().willReturn()
        
        given(delegate)
            .onChatUpdated(.any, mode: .any).willReturn()
            .onThreadUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }
        
        XCTAssertFalse(connectionContext.channelConfig.settings.isRecoverLiveChatDoesNotFailEnabled)
        
        let error = OperationError(
            eventId: UUID.provide(),
            errorCode: .recoveringThreadFailed,
            transactionId: eventId.asLowerCaseUUID,
            errorMessage: "Recovering failed"
        )
        try await service!.processRecoveringThreadFailedError(error)
        
        await fulfillment(of: [expectation], timeout: 10.0)
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
        
        verify(socketService)
            .send(data: .any, shouldCheck: .any)
            .called(1)
    }
    
    func testLiveChatDoesNotFailToggleEnabledThrows() async throws {
        let eventId = UUID()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(
                MockData.getChannelConfiguration(features: ["isRecoverLivechatDoesNotFailEnabled": true], isOnline: true, isLiveChat: true)
            )
        
        XCTAssertTrue(connectionContext.channelConfig.settings.isRecoverLiveChatDoesNotFailEnabled)
        
        let error = OperationError(
            eventId: UUID.provide(),
            errorCode: .recoveringThreadFailed,
            transactionId: LowerCaseUUID(),
            errorMessage: "Recovering failed"
        )
        
        await XCTAssertAsyncThrowsError(try await service!.processRecoveringThreadFailedError(error)) { error in
            XCTAssertEqual((error as! OperationError).errorCode, .recoveringThreadFailed)
        }
    }

    func testInboxAssigneeImageUrlMappedCorrectly() throws {
        let data = try loadBundleData(from: "CaseInboxAssigneeChanged", type: "json")
        let event = try JSONDecoder().decode(ContactInboxAssigneeChangedEventDTO.self, from: data)
        
        guard let inboxAssignee = event.data.inboxAssignee else {
            throw XCTError("inboxAssignee is nil")
        }
        
        XCTAssertEqual(inboxAssignee.id, 12328)
        XCTAssertEqual(inboxAssignee.nickname, "Nickname")
        XCTAssertFalse(inboxAssignee.isBotUser)
        XCTAssertFalse(inboxAssignee.isSurveyUser)
        XCTAssertEqual(inboxAssignee.publicImageUrl, "https://app-de-na1.niceincontact.com/img/user/z.png")
    }
}
