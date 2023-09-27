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

// swiftlint:disable type_body_length function_body_length file_length

@testable import CXoneChatSDK
import KeychainSwift
import XCTest

class ThreadsProviderTests: CXoneXCTestCase {

    // MARK: - Properties

    private var currentExpectation = XCTestExpectation(description: "")
    private var didCheckDelegate = false
    
    let agent = AgentDTO(
        id: 123,
        inContactId: "",
        emailAddress: nil,
        loginUsername: "kjoe",
        firstName: "name",
        surname: "surname",
        nickname: nil,
        isBotUser: false,
        isSurveyUser: false,
        imageUrl: ""
    )

    // included fields must fulfill prechat survey in ChannelConfiguration.json
    let defaultAnswers = [
        "email": "john@doe.com",
        "broken_device": "140232dc-8168-4f5c-9f5e-b709adbf8ab1"
    ]

    // MARK: - Lifecycle
    
    override func setUp() async throws {
        try await super.setUp()
        
        try await setUpConnection()
        
        CXoneChat.delegate = self
        didCheckDelegate = false
        UserDefaults.standard.removeObject(forKey: "welcomeMessage")
    }

    // MARK: - Tests

    func testCreateThreadThrowsError() {
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(ChatThread(id: UUID()))
        
        socketService.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: true),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )
        
        XCTAssertThrowsError(try CXoneChat.threads.create())
    }
    
    func testCreateThreadThrowsWithoutConnected() {
        CXoneChat.connection.disconnect()

        XCTAssertThrowsError(try CXoneChat.threads.create())
    }

    func testCreateThreadNotThrowError() {
        XCTAssertNoThrow(try CXoneChat.threads.create(with: defaultAnswers))
    }

    func testLoadThreadsDoesNotThrows() {
        let expectation = XCTestExpectation(description: "closure Called")

        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )

        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)

            expectation.fulfill()
        }

        XCTAssertNoThrow(try CXoneChat.threads.load())
        XCTAssertEqual(socketService.messageSend, 2)

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadThreadThrowErrorWithSingleThreadConfig() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )

        (CXoneChat.threads as? ChatThreadsService)?.threads.append(ChatThread(id: UUID()))

        XCTAssertThrowsError(try CXoneChat.threads.load(), "Error catched") { error in
            XCTAssertEqual(error.localizedDescription, CXoneChatError.unsupportedChannelConfig.localizedDescription)
        }
    }

    func testLoadThread() {
        let expectation = XCTestExpectation(description: "closure Called")

        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)

            expectation.fulfill()
        }

        XCTAssertNoThrow(try CXoneChat.threads.load())
        XCTAssertEqual(socketService.messageSend, 1)

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadThreadThrowsWithGivenId() {
        XCTAssertThrowsError(try CXoneChat.threads.load(with: UUID()))
    }

    func testLoadThreadWithGivenId() {
        let expectation = XCTestExpectation(description: "closure Called")

        let uuid = UUID()
        let thread = ChatThread(id: uuid)
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)

        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)

            expectation.fulfill()
        }

        XCTAssertNoThrow(try CXoneChat.threads.load(with: uuid))
        XCTAssertEqual(socketService.messageSend, 1)

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadThreadInfo() {
        let expectation = XCTestExpectation(description: "closure Called")
        
        let thread = ChatThread(id: UUID())
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)
        
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            
            expectation.fulfill()
        }
        
        XCTAssertNoThrow(try CXoneChat.threads.loadInfo(for: thread))
        XCTAssertEqual(socketService.messageSend, 1)
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testArchiveThreadThrowsUnsupportedChannelConfigError() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: true),
            isAuthorizationEnabled: true,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )
        
        XCTAssertThrowsError(try CXoneChat.threads.archive(ChatThread(id: UUID())))
    }

    func testArchiveThreadThrowsThreadIndexError() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true),
            isAuthorizationEnabled: true,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )

        XCTAssertThrowsError(try CXoneChat.threads.archive(ChatThread(id: UUID())), "invalid thread") { error in
            XCTAssertEqual(error as? CXoneChatError, .invalidThread)
        }
    }

    func testArchiveThreadRemoveFromList() {
        let expectation = XCTestExpectation(description: "archivedThread")

        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true),
            isAuthorizationEnabled: true,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )
        let thread = ChatThread(id: UUID())
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)
        var check = false

        socketService.messageSent = { _ in
            if !check {
                expectation.fulfill()
                check = true
            }
        }

        XCTAssertNoThrow(try CXoneChat.threads.archive(thread))

        wait(for: [expectation], timeout: 1.0)
    }

    func testArchiveThreadSendToServerMessage() throws {
        let expectation = XCTestExpectation(description: "closure Called")

        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true),
            isAuthorizationEnabled: true,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )
        var thread = ChatThreadDTO(
            idOnExternalPlatform: UUID(),
            threadName: nil,
            messages: [],
            threadAgent: nil,
            canAddMoreMessages: true,
            contactId: nil,
            scrollToken: ""
        )
        thread.messages.append(
            MessageDTO(
                idOnExternalPlatform: UUID(),
                threadIdOnExternalPlatform: thread.idOnExternalPlatform,
                contentType: .text(MessagePayloadDTO(text: "", postback: nil)),
                createdAt: try Date.ISO8601(from: "2022-07-31T21:22:47+00:00"),
                attachments: [],
                direction: .inbound,
                userStatistics: UserStatisticsDTO(seenAt: nil, readAt: nil),
                authorUser: nil,
                authorEndUserIdentity: nil
            )
        )
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(ChatThreadMapper.map(thread))

        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)

            expectation.fulfill()
        }

        XCTAssertNoThrow(try CXoneChat.threads.archive(ChatThreadMapper.map(thread)))
        XCTAssertEqual(socketService.messageSend, 1)

        wait(for: [expectation], timeout: 1.0)
    }

    func testThreadRecover() throws {
        currentExpectation = XCTestExpectation(description: "loadthread exp")

        let thread = ChatThread(id: UUID())
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)

        let event = ThreadRecoveredEventDTO(
            eventId: UUID(),
            postback: ThreadRecoveredEventPostbackDTO(
                eventType: .recoverThread,
                data: ThreadRecoveredEventPostbackDataDTO(
                    consumerContact: ContactDTO(
                        id: UUID().uuidString,
                        threadIdOnExternalPlatform: UUID(),
                        status: .new,
                        createdAt: try Date.ISO8601(from: "2022-07-31T21:22:57+00:00"),
                        customFields: []
                    ),
                    messages: [
                        MessageDTO(
                            idOnExternalPlatform: UUID(),
                            threadIdOnExternalPlatform: thread.id,
                            contentType: .text(MessagePayloadDTO(text: "", postback: nil)),
                            createdAt: try Date.ISO8601(from: "2022-07-31T21:22:47+00:00"),
                            attachments: [],
                            direction: .inbound,
                            userStatistics: UserStatisticsDTO(seenAt: nil, readAt: nil),
                            authorUser: nil,
                            authorEndUserIdentity: nil
                        ),
                        MessageDTO(
                            idOnExternalPlatform: UUID(),
                            threadIdOnExternalPlatform: thread.id,
                            contentType: .text(MessagePayloadDTO(text: "", postback: nil)),
                            createdAt: try Date.ISO8601(from: "2022-07-31T21:22:57+00:00"),
                            attachments: [],
                            direction: .inbound,
                            userStatistics: UserStatisticsDTO(seenAt: nil, readAt: nil),
                            authorUser: nil,
                            authorEndUserIdentity: nil
                        )
                    ],
                    inboxAssignee: AgentDTO(
                        id: 0,
                        inContactId: UUID().uuidString,
                        emailAddress: nil,
                        loginUsername: "jdoe",
                        firstName: "John",
                        surname: "Doe",
                        nickname: nil,
                        isBotUser: false,
                        isSurveyUser: false,
                        imageUrl: ""
                    ),
                    thread: ReceivedThreadDataDTO(idOnExternalPlatform: thread.id, channelId: "channel_1", threadName: "name", canAddMoreMessages: true),
                    messagesScrollToken: "token",
                    customerContactFields: []
                )
            )
        )
        
        CXoneChat.socketDelegateManager.threadRecovered(event)

        wait(for: [currentExpectation], timeout: 1.0)
    }

    func testFetchThreadList() throws {
        currentExpectation = XCTestExpectation(description: "On Thread list load ")

        let data = try loadStubFromBundle(withName: "ThreadListFetchedEvent", extension: "json")
        let event = try JSONDecoder().decode(GenericEventDTO.self, from: data)
        CXoneChat.socketDelegateManager.processThreadListFetchedEvent(event: event)

        wait(for: [currentExpectation], timeout: 1.0)
    }

    func testMarkThreadAsReadSuccess() {
        let expectation = XCTestExpectation(description: "closure Called")

        let thread = ChatThread(id: UUID())
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)

        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)

            expectation.fulfill()
        }

        XCTAssertNoThrow(try CXoneChat.threads.markRead(thread))
        XCTAssertEqual(socketService.messageSend, 1)

        wait(for: [expectation], timeout: 1.0)
    }

    func testSetThreadAgentThrowsInvalidThreadError() throws {
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(ChatThread(id: UUID()))

        XCTAssertEqual(CXoneChat.threads.get().count, 1)

        XCTAssertThrowsError(try CXoneChat.socketDelegateManager.setThreadAgent(agent: agent, threadIdOnExternalPlatform: UUID()))
    }

    func testSetThreadAgent() throws {
        let thread = ChatThread(id: UUID())
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)

        XCTAssertEqual(CXoneChat.threads.get().count, 1)

        try CXoneChat.socketDelegateManager.setThreadAgent(agent: agent, threadIdOnExternalPlatform: thread.id)

        XCTAssertEqual(CXoneChat.threads.get().first?.assignedAgent?.id, agent.id)
        XCTAssertEqual(CXoneChat.threads.get().first?.assignedAgent?.fullName, agent.fullName)
    }

    func testNotifyArchiveThreadEvent() async {
        currentExpectation = XCTestExpectation(description: "Thread Archive Event")

        CXoneChat.socketDelegateManager.notifyThreadArchivedEvent()

        wait(for: [currentExpectation], timeout: 1.0)
    }

    func testProcessThreadLoad() throws {
        currentExpectation = XCTestExpectation(description: "On Thread Load from Process")

        CXoneChat.socketDelegateManager.processThreadRecoverEvent(
            ThreadRecoveredEventDTO(
                eventId: UUID(),
                postback: ThreadRecoveredEventPostbackDTO(
                    eventType: .recoverThread,
                    data: ThreadRecoveredEventPostbackDataDTO(
                        consumerContact: ContactDTO(
                            id: UUID().uuidString,
                            threadIdOnExternalPlatform: UUID(),
                            status: .open,
                            createdAt: dateProvider.now,
                            customFields: [CustomFieldDTO(ident: "contact.customFields.location", value: "EU", updatedAt: dateProvider.now)]
                        ),
                        messages: [],
                        inboxAssignee: nil,
                        thread: ReceivedThreadDataDTO(idOnExternalPlatform: UUID(), channelId: "", threadName: "", canAddMoreMessages: true),
                        messagesScrollToken: "asdasda",
                        customerContactFields: [CustomFieldDTO(ident: "customer.customFields.age", value: "EU", updatedAt: dateProvider.now)]
                    )
                )
            )
        )

        wait(for: [currentExpectation], timeout: 1.0)
    }

    func testProcessThreadLastMessage() throws {
        currentExpectation = XCTestExpectation(description: "On ThreadInfo load")

        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }

        let data = try loadStubFromBundle(withName: "ThreadMetadataLoadedEvent", extension: "json")
        let event = try JSONDecoder().decode(ThreadMetadataLoadedEventDTO.self, from: data)
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(ChatThread(id: uuid))
        CXoneChat.socketDelegateManager.processThreadLastMessage(event.postback.data.lastMessage)

        wait(for: [currentExpectation], timeout: 1.0)
    }

    func testProcessThreadLastMessageFailsWithError() throws {
        currentExpectation = XCTestExpectation(description: "On ThreadInfo load")

        let data = try loadStubFromBundle(withName: "ThreadMetadataLoadedEvent", extension: "json")
        let event = try JSONDecoder().decode(ThreadMetadataLoadedEventDTO.self, from: data)
        CXoneChat.socketDelegateManager.processThreadLastMessage(event.postback.data.lastMessage)

        wait(for: [currentExpectation], timeout: 1.0)
    }

    func testProcessThreadAgent() throws {
        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }

        let data = try loadStubFromBundle(withName: "ThreadMetadataLoadedEvent", extension: "json")
        let event = try JSONDecoder().decode(ThreadMetadataLoadedEventDTO.self, from: data)
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(ChatThread(id: uuid))

        guard let ownerAssignee = event.postback.data.ownerAssignee else {
            throw CXoneChatError.invalidData
        }

        CXoneChat.socketDelegateManager.processThreadAgent(event.postback.data.lastMessage, ownerAssignee)

        XCTAssertNotNil(CXoneChat.threads.get().last?.assignedAgent)
    }

    func testUpdateThreadNameThrowsUnsupportedChannelConfigError() throws {
        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }

        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: true),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )

        (CXoneChat.threads as? ChatThreadsService)?.threads.append(ChatThread(id: uuid))

        XCTAssertThrowsError(try CXoneChat.threads.updateName("Thread Name", for: UUID()))
    }
    func testUpdateThreadNameThrowsInvalidThreadError() throws {
        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }

        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )

        (CXoneChat.threads as? ChatThreadsService)?.threads.append(ChatThread(id: uuid))

        XCTAssertThrowsError(try CXoneChat.threads.updateName("Thread Name", for: UUID()))
    }

    func testUpdateThreadNameNoEmptyMessageArray() throws {
        currentExpectation = XCTestExpectation(description: "On update threadName ")

        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }

        var thread = ChatThread(id: uuid)
        var check = false

        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )
        thread.messages.append(
            Message(
                id: UUID(),
                threadId: UUID(),
                contentType: .text(MessagePayload(text: "", postback: nil)),
                createdAt: dateProvider.now,
                attachments: [],
                direction: .toAgent,
                userStatistics: UserStatistics(seenAt: nil, readAt: nil),
                authorUser: nil,
                authorEndUserIdentity: nil
            )
        )
        socketService.messageSend = 0
        socketService.messageSent = { [weak self] sendMessage in
            guard !check, sendMessage.contains("UpdateThread") else {
                return
            }
            guard let index = self?.CXoneChat.threads.get().index(of: thread.id) else {
                XCTFail("\(#function) could not get index.")
                return
            }

            XCTAssertNotNil(index)
            XCTAssertFalse(self?.CXoneChat.threads.get()[index].name?.isEmpty ?? true)
            XCTAssertEqual(self?.CXoneChat.threads.get()[index].name, "Thread Name")

            self?.currentExpectation.fulfill()
            check = true
        }

        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)

        XCTAssertNoThrow(
            try CXoneChat.threads.updateName("Thread Name", for: thread.id)
        )

        wait(for: [currentExpectation], timeout: 1.0)
    }

    func testUpdateThreadNameWithEmptyMessageArray() throws {
        currentExpectation = XCTestExpectation(description: "On update threadName ")

        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }

        let thread = ChatThread(id: uuid)

        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )

        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)

        XCTAssertNoThrow(
            try CXoneChat.threads.updateName("Thread Name", for: thread.id)
        )

        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testAppendMessageToThreadThrows() {
        let message = MessageDTO(
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
        
        XCTAssertThrowsError(try (CXoneChat.threads as? ChatThreadsService)?.appendMessageToThread(message))
    }
    
    func testAppendMessageToThreadNoThrow() {
        let uuid = UUID()
        
        let thread = ChatThread(id: uuid)
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)
        
        let message = MessageDTO(
            idOnExternalPlatform: UUID(),
            threadIdOnExternalPlatform: uuid,
            contentType: .text(MessagePayloadDTO(text: "", postback: nil)),
            createdAt: dateProvider.now,
            attachments: [],
            direction: .inbound,
            userStatistics: UserStatisticsDTO(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        XCTAssertNoThrow(try (CXoneChat.threads as? ChatThreadsService)?.appendMessageToThread(message))
    }
    
    func testWelcomeMessageHandlerNoThrow() throws {
        UserDefaults.standard.set("Hello {{customer.firstName|stranger}}!", forKey: "welcomeMessage")
        
        XCTAssertNoThrow(try CXoneChat.threads.create(with: defaultAnswers))
    }
    
    func testWelcomeMessagePostHandlerThrowsMissingMessage() async {
        currentExpectation = XCTestExpectation(description: "Welcome message post handler")
        
        XCTAssertNoThrow(try CXoneChat.threads.create(with: defaultAnswers))
        
        (CXoneChat.threads as? ChatThreadsService)?.onWelcomeMessageReceived()
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testWelcomeMessagePostHandlerThrowsMissingCustomer() async {
        currentExpectation = XCTestExpectation(description: "Welcome message post handler")
        
        XCTAssertNoThrow(try CXoneChat.threads.create(with: defaultAnswers))
        
        UserDefaults.standard.set("Hello {{customer.firstName|stranger}}!", forKey: "welcomeMessage")
        socketService.connectionContext.customer = nil
        
        (CXoneChat.threads as? ChatThreadsService)?.onWelcomeMessageReceived()
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testWelcomeMessagePostHandler() {
        XCTAssertNoThrow(try CXoneChat.threads.create(with: defaultAnswers))
        
        UserDefaults.standard.set("Hello {{customer.firstName|stranger}}!", forKey: "welcomeMessage")
        (CXoneChat.threads as? ChatThreadsService)?.onWelcomeMessageReceived()
    }
    
    func testGetPrechatSurveyEmpty() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: PreChatSurveyDTO(name: "", customFields: [
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .textField(CustomFieldTextFieldDTO(ident: "fistName", label: "First Name", value: nil, updatedAt: .distantPast, isEmail: false))
                ),
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .textField(CustomFieldTextFieldDTO(ident: "email", label: "E-mail", value: nil, updatedAt: .distantPast, isEmail: true))
                )
            ]),
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )
        
        XCTAssertNil(CXoneChat.threads.preChatSurvey)
    }
    
    func testGetPrechatSurveyNoEmpty() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: PreChatSurveyDTO(name: "", customFields: [
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .textField(CustomFieldTextFieldDTO(ident: "fistName", label: "First Name", value: nil, updatedAt: .distantPast, isEmail: false))
                ),
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .textField(CustomFieldTextFieldDTO(ident: "email", label: "E-mail", value: nil, updatedAt: .distantPast, isEmail: true))
                ),
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .selector(
                        CustomFieldSelectorDTO(
                            ident: "gender",
                            label: "Gender",
                            value: nil,
                            updatedAt: .distantPast,
                            options: ["gender-male": "Male", "gender-female": "Female"])
                    )
                ),
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .hierarchical(
                        CustomFieldHierarchicalDTO(
                            ident: "options",
                            label: "Options",
                            value: nil,
                            updatedAt: .distantPast,
                            nodes: [
                                CustomFieldHierarchicalNodeDTO(value: "option-a", label: "Option A", children: [
                                    CustomFieldHierarchicalNodeDTO(value: "option-a-1", label: "Option A1")
                                ]),
                                CustomFieldHierarchicalNodeDTO(value: "option-b", label: "Option B", children: [
                                    CustomFieldHierarchicalNodeDTO(value: "option-b-1", label: "Option B1")]
                                )
                            ]
                        )
                    )
                )
            ]),
            contactCustomFieldDefinitions: [
                .textField(CustomFieldTextFieldDTO(ident: "firstName", label: "First Name", value: nil, updatedAt: .distantPast, isEmail: false)),
                .textField(CustomFieldTextFieldDTO(ident: "email", label: "E-mail", value: nil, updatedAt: .distantPast, isEmail: true)),
                .selector(CustomFieldSelectorDTO(ident: "gender", label: "Gender", value: nil, updatedAt: .distantPast, options: [
                    "gender-male": "Male",
                    "gender-female": "Female"
                ])),
                .hierarchical(CustomFieldHierarchicalDTO(ident: "options", label: "Options", value: nil, updatedAt: .distantPast, nodes: [
                    CustomFieldHierarchicalNodeDTO(value: "option-a", label: "Option A", children: [
                        CustomFieldHierarchicalNodeDTO(value: "option-a-1", label: "Option A1")
                    ]),
                    CustomFieldHierarchicalNodeDTO(value: "option-b", label: "Option B", children: [
                        CustomFieldHierarchicalNodeDTO(value: "option-b-1", label: "Option B1")]
                                                  )
                ]))
            ],
            customerCustomFieldDefinitions: []
        )
        
        XCTAssertNotNil(CXoneChat.threads.preChatSurvey)
    }
    
    func testGetPrechatSurveyWithFilteredCustomFields() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: PreChatSurveyDTO(name: "", customFields: [
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .textField(CustomFieldTextFieldDTO(ident: "fistName", label: "First Name", value: nil, updatedAt: .distantPast, isEmail: false))
                ),
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .textField(CustomFieldTextFieldDTO(ident: "email", label: "E-mail", value: nil, updatedAt: .distantPast, isEmail: true))
                )
            ]),
            contactCustomFieldDefinitions: [
                .textField(CustomFieldTextFieldDTO(ident: "email", label: "E-mail", value: nil, updatedAt: .distantPast, isEmail: true))
            ],
            customerCustomFieldDefinitions: []
        )
        
        XCTAssertNotNil(CXoneChat.threads.preChatSurvey)
        XCTAssertEqual(CXoneChat.threads.preChatSurvey?.customFields.count, 1)
    }
    
    func testCreateWithoutCustomFieldsDefinitionThrows() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: PreChatSurveyDTO(name: "", customFields: [
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .textField(CustomFieldTextFieldDTO(ident: "location", label: "Location", value: nil, updatedAt: .distantPast, isEmail: false))
                )
            ]),
            contactCustomFieldDefinitions: [
                .textField(CustomFieldTextFieldDTO(ident: "location", label: "Location", value: nil, updatedAt: .distantPast, isEmail: false))],
            customerCustomFieldDefinitions: []
        )
        
        XCTAssertThrowsError(try CXoneChat.threads.create())
    }
    
    func testCreateWithCustomFieldsDefinitionNoThrow() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: PreChatSurveyDTO(name: "", customFields: [
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .textField(CustomFieldTextFieldDTO(ident: "location", label: "Location", value: nil, updatedAt: .distantPast, isEmail: false))
                )
            ]),
            contactCustomFieldDefinitions: [
                .textField(CustomFieldTextFieldDTO(ident: "location", label: "Location", value: nil, updatedAt: .distantPast, isEmail: false))
            ],
            customerCustomFieldDefinitions: []
        )
        
        XCTAssertNoThrow(try CXoneChat.threads.create(with: ["location": "EU"]))
    }
    
    func testCreateWithTextCustomFieldNoThrow() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: PreChatSurveyDTO(name: "", customFields: [
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .textField(CustomFieldTextFieldDTO(ident: "location", label: "Location", value: nil, updatedAt: .distantPast, isEmail: false))
                )
            ]),
            contactCustomFieldDefinitions: [
                .textField(CustomFieldTextFieldDTO(ident: "location", label: "Location", value: nil, updatedAt: .distantPast, isEmail: false))],
            customerCustomFieldDefinitions: []
        )
        
        do {
            _ = try CXoneChat.threads.create(with: ["location": "EU"])
        } catch {
            XCTFail("Method should not thrown an error")
        }
    }
    
    func testCreateWithEmailCustomFieldNoThrow() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: PreChatSurveyDTO(name: "", customFields: [
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .textField(CustomFieldTextFieldDTO(ident: "email", label: "Email", value: nil, updatedAt: .distantPast, isEmail: true))
                )
            ]),
            contactCustomFieldDefinitions: [
                .textField(CustomFieldTextFieldDTO(ident: "email", label: "Email", value: nil, updatedAt: .distantPast, isEmail: true))],
            customerCustomFieldDefinitions: []
        )
        
        do {
            _ = try CXoneChat.threads.create(with: ["email": "john.doe@email.com"])
        } catch {
            XCTFail("Method should not thrown an error")
        }
    }
    
    func testCreateWithSelectorCustomFieldNoThrow() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: PreChatSurveyDTO(name: "", customFields: [
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .selector(
                        CustomFieldSelectorDTO(
                            ident: "gender",
                            label: "Gender",
                            value: nil,
                            updatedAt: .distantPast,
                            options: ["gender-male": "Male", "gender-female": "Female"]
                        )
                    )
                )
            ]),
            contactCustomFieldDefinitions: [
                .selector(
                    CustomFieldSelectorDTO(
                        ident: "gender",
                        label: "Gender",
                        value: nil,
                        updatedAt: .distantPast,
                        options: ["gender-male": "Male", "gender-female": "Female"]
                    )
                )
            ],
            customerCustomFieldDefinitions: []
        )
        
        do {
            _ = try CXoneChat.threads.create(with: ["gender": "gender-male"])
        } catch {
            XCTFail("Method should not thrown an error")
        }
    }
    
    func testCreateWithHierarchicalCustomFieldNoThrow() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: PreChatSurveyDTO(name: "", customFields: [
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .hierarchical(
                        CustomFieldHierarchicalDTO(
                            ident: "options",
                            label: "Options",
                            value: nil,
                            updatedAt: .distantPast,
                            nodes: [
                                CustomFieldHierarchicalNodeDTO(value: "option-a", label: "Option A", children: [.init(value: "option-a-1", label: "Option A1")]),
                                CustomFieldHierarchicalNodeDTO(value: "option-b", label: "Option B", children: [.init(value: "option-b-1", label: "Option B1")])
                            ]
                        )
                    )
                )
            ]),
            contactCustomFieldDefinitions: [
                .hierarchical(
                    CustomFieldHierarchicalDTO(
                        ident: "options",
                        label: "Options",
                        value: nil,
                        updatedAt: .distantPast,
                        nodes: [
                            CustomFieldHierarchicalNodeDTO(value: "option-a", label: "Option A", children: [.init(value: "option-a-1", label: "Option A1")]),
                            CustomFieldHierarchicalNodeDTO(value: "option-b", label: "Option B", children: [.init(value: "option-b-1", label: "Option B1")])
                        ]
                    )
                )
            ],
            customerCustomFieldDefinitions: []
        )
        
        do {
            _ = try CXoneChat.threads.create(with: ["options": "option-b-1"])
        } catch {
            XCTFail("Method should not thrown an error")
        }
    }
    
    func testCustomFieldsAreSetAfterCreate() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: PreChatSurveyDTO(name: "", customFields: [
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .textField(CustomFieldTextFieldDTO(ident: "email", label: "E-mail", value: nil, updatedAt: .distantPast, isEmail: true))
                )
            ]),
            contactCustomFieldDefinitions: [
                .textField(CustomFieldTextFieldDTO(ident: "email", label: "E-mail", value: nil, updatedAt: .distantPast, isEmail: true))
            ],
            customerCustomFieldDefinitions: []
        )
        
        do {
            let threadId = try CXoneChat.threads.create(with: ["email": "john.doe@mail.com"])
            
            XCTAssertFalse((CXoneChat.threads.customFields.get(for: threadId) as [CustomFieldType]).isEmpty)
        } catch {
            XCTFail("Method should not thrown an error")
        }
    }
    
    func testCustomFieldsNotOverrideStoredOnes() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false,
            prechatSurvey: PreChatSurveyDTO(name: "", customFields: [
                PreChatSurveyCustomFieldDTO(
                    isRequired: true,
                    type: .textField(CustomFieldTextFieldDTO(ident: "email", label: "E-mail", value: nil, updatedAt: .distantPast, isEmail: true))
                )
            ]),
            contactCustomFieldDefinitions: [
                .textField(CustomFieldTextFieldDTO(ident: "email", label: "E-mail", value: nil, updatedAt: .distantPast, isEmail: true)),
                .textField(CustomFieldTextFieldDTO(ident: "firstName", label: "First Name", value: nil, updatedAt: .distantPast, isEmail: false)),
                .textField(CustomFieldTextFieldDTO(ident: "lastName", label: "Last Name", value: nil, updatedAt: .distantPast, isEmail: false))
            ],
            customerCustomFieldDefinitions: []
        )
        
        do {
            let threadId = try CXoneChat.threads.create(with: ["email": "john.doe@mail.com"])
            
            try CXoneChat.threads.customFields.set(["firstName": "John", "lastName": "Doe"], for: threadId)
            
            XCTAssertFalse((CXoneChat.threads.customFields.get(for: threadId) as [CustomFieldType]).isEmpty)
            XCTAssertEqual((CXoneChat.threads.customFields.get(for: threadId) as [CustomFieldType]).count, 3)
        } catch {
            XCTFail("Method should not thrown an error")
        }
    }
}

// MARK: - CXoneChatDelegate

extension ThreadsProviderTests: CXoneChatDelegate {
    
    func onThreadsLoad(_ threads: [ChatThread]) {
        if !didCheckDelegate {
            currentExpectation.fulfill()
            didCheckDelegate = true
        }
    }
    
    func onThreadInfoLoad(_ thread: ChatThread) {
        if !didCheckDelegate {
            currentExpectation.fulfill()
            didCheckDelegate = true
        }
    }
    
    func onThreadLoad(_ thread: ChatThread) {
        if !didCheckDelegate {
            currentExpectation.fulfill()
            didCheckDelegate = true
        }
    }
    
    func onThreadArchive() {
        if !didCheckDelegate {
            currentExpectation.fulfill()
            didCheckDelegate = true
        }
    }
    
    func onThreadUpdate() {
        if !didCheckDelegate {
            currentExpectation.fulfill()
            didCheckDelegate = true
        }
    }
    
    func onError(_ error: Error) {
        if !didCheckDelegate {
            currentExpectation.fulfill()
            didCheckDelegate = true
        }
    }
}
