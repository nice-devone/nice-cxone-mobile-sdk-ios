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

// swiftlint:disable type_body_length function_body_length file_length

@testable import CXoneChatSDK
import XCTest

class ThreadsProviderTests: CXoneXCTestCase {
    
    func testCreateThreadThrowsError() async throws {
        try await setUpConnection()
        
        threadsService.threads.append(ChatThreadMapper.map(MockData.getThread()))
        
        await XCTAssertAsyncThrowsError(try await CXoneChat.threads.create())
    }
    
    func testCreateThreadThrowsWithoutConnected() async {
        await XCTAssertAsyncThrowsError(try await CXoneChat.threads.create())
    }
    
    func testCreateThreadNoThrow() async throws {
        try await setUpConnection()
        
        try await CXoneChat.threads.create(with: ["email": "john@doe.com"])
    }
    
    func testLoadThreadsDoesNotThrows() async throws {
        currentExpectation = XCTestExpectation(description: "Load Threads Called")
        
        socketService.messageSent = { [weak self] message in
            if message.contains("AuthorizeCustomer") {
                do {
                    try self?.customerService.processCustomerReconnectEvent()
                } catch {
                    XCTFail(error.localizedDescription)
                }
            } else {
                XCTAssertTrue(!message.isEmpty)
                
                self?.currentExpectation.fulfill()
            }
        }
        
        try await setUpConnection(isEventMessageHandlerActive: false)
        
        XCTAssertEqual(socketService.messageSend, 2, "2 event should be called - Authorize, Load")
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }

    func testLoadThreadThrowsWithGivenId() {
        XCTAssertThrowsError(try CXoneChat.threads.load(with: UUID()))
    }
    
    func testLoadThreadWithGivenId() async throws {
        currentExpectation = XCTestExpectation(description: "closure Called")
        
        try await setUpConnection()
        
        let thread = ChatThreadMapper.map(MockData.getThread())
        threadsService.threads.append(thread)
        
        socketService.messageSend = 0
        socketService.messageSent = { [weak self] message in
            XCTAssertTrue(!message.isEmpty)
            
            self?.currentExpectation.fulfill()
        }
        
        XCTAssertNoThrow(try CXoneChat.threads.load(with: thread.id))
        XCTAssertEqual(socketService.messageSend, 1)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testArchiveThreadThrowsUnsupportedChannelConfigError() {
        connectionService.connectionContext.channelConfig = MockData.getChannelConfiguration()
        
        XCTAssertThrowsError(try CXoneChat.threads.archive(ChatThreadMapper.map(MockData.getThread())))
    }
    
    func testArchiveThreadThrowsThreadIndexError() async throws {
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(isMultithread: true))
        
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(ChatThread(id: UUID(), state: .pending))

        XCTAssertThrowsError(try CXoneChat.threads.archive(ChatThreadMapper.map(MockData.getThread())), "invalid thread") { error in
            XCTAssertEqual(error as? CXoneChatError, .invalidThread)
        }
    }

    func testArchiveThreadRemoveFromList() async throws {
        currentExpectation = XCTestExpectation(description: "archivedThread")
        
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(isMultithread: true))
        
        let thread = ChatThreadMapper.map(MockData.getThread())
        threadsService.threads.append(thread)
        var check = false
        
        socketService.messageSent = { [weak self] _ in
            if !check {
                self?.currentExpectation.fulfill()
                check = true
            }
        }
        
        XCTAssertNoThrow(try CXoneChat.threads.archive(thread))
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testThreadRecover() async throws {
        currentExpectation = XCTestExpectation(description: "loadthread exp")
        
        let thread = ChatThreadMapper.map(MockData.getThread())
        threadsService.threads.append(thread)
        
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
                    inboxAssignee: MockData.agent,
                    thread: ReceivedThreadDataDTO(idOnExternalPlatform: thread.id, channelId: "channel_1", threadName: "name", canAddMoreMessages: true),
                    messagesScrollToken: "token",
                    customerCustomFields: []
                )
            )
        )
        
        let data = try encoder.encode(event)
        
        try threadsService.processThreadRecoveredEvent(try data.decode() as ThreadRecoveredEventDTO)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testFetchThreadList() async throws {
        currentExpectation = XCTestExpectation(description: "testFetchThreadListLoadThreads")
        
        try await setUpConnection()
        
        socketService.messageSent = { [weak self] sendMessage in
            guard let self, sendMessage.contains("LoadThreadMetadata") else {
                return
            }
            
            self.CXoneChat.add(delegate: self)

            do {
                let data = try self.loadBundleData(from: "ThreadMetadataLoadedEvent", type: "json")
                let event = try self.decoder.decode(ThreadMetadataLoadedEventDTO.self, from: data)
                
                try self.threadsService.processThreadMetadataLoadedEvent(event)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        let data = try loadBundleData(from: "ThreadListFetchedEvent", type: "json")
        let event = try decoder.decode(GenericEventDTO.self, from: data)
        
        try threadsService.processThreadListFetchedEvent(event)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testMarkThreadAsReadSuccess() async throws {
        currentExpectation = XCTestExpectation(description: "closure Called")
        
        try await setUpConnection()
        
        let thread = ChatThreadMapper.map(MockData.getThread())
        threadsService.threads.append(thread)
        
        socketService.messageSend = 0
        socketService.messageSent = { [weak self] message in
            XCTAssertTrue(!message.isEmpty)
            
            self?.currentExpectation.fulfill()
        }
        
        XCTAssertNoThrow(try CXoneChat.threads.markRead(thread))
        XCTAssertEqual(socketService.messageSend, 1)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessThreadLoad() async throws {
        currentExpectation = XCTestExpectation(description: "On Thread Load from Process")
        
        let eventData = ThreadRecoveredEventDTO(
            eventId: UUID(),
            postback: ThreadRecoveredEventPostbackDTO(
                eventType: .recoverThread,
                data: ThreadRecoveredEventPostbackDataDTO(
                    consumerContact: ContactDTO(
                        id: UUID().uuidString,
                        threadIdOnExternalPlatform: UUID(),
                        status: .open,
                        createdAt: Date.provide(),
                        customFields: [CustomFieldDTO(ident: "contact.customFields.location", value: "EU", updatedAt: Date.provide())]
                    ),
                    messages: [],
                    inboxAssignee: nil,
                    thread: ReceivedThreadDataDTO(idOnExternalPlatform: UUID(), channelId: "", threadName: "", canAddMoreMessages: true),
                    messagesScrollToken: "asdasda",
                    customerCustomFields: [CustomFieldDTO(ident: "customer.customFields.age", value: "EU", updatedAt: Date.provide())]
                )
            )
        )
        
        let data = try encoder.encode(eventData)
        
        try threadsService.processThreadRecoveredEvent(try data.decode() as ThreadRecoveredEventDTO)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessThreadLastMessage() async throws {
        currentExpectation = XCTestExpectation(description: "On ThreadInfo load")
        
        let data = try loadBundleData(from: "ThreadMetadataLoadedEvent", type: "json")
        let event = try decoder.decode(ThreadMetadataLoadedEventDTO.self, from: data)
        
        threadsService.threads.append(ChatThreadMapper.map(MockData.getThread(threadId: UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7")!)))
        
        try threadsService.processThreadMetadataLoadedEvent(event)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessThreadLastMessageThrowsInvalidThread() throws {
        let data = try loadBundleData(from: "ThreadMetadataLoadedEvent", type: "json")

        XCTAssertThrowsError(try threadsService.processThreadMetadataLoadedEvent(try data.decode() as ThreadMetadataLoadedEventDTO)) { error in
            XCTAssertEqual(error as? CXoneChatError, CXoneChatError.invalidThread)
        }
    }
    
    func testUpdateThreadNameThrowsUnsupportedChannelConfigError() throws {
        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }
        
        connectionService.connectionContext.channelConfig = MockData.getChannelConfiguration()
        
        threadsService.threads.append(ChatThreadMapper.map(MockData.getThread(threadId: uuid)))
        
        XCTAssertThrowsError(try CXoneChat.threads.updateName("Thread Name", for: UUID()))
    }
    
    func testUpdateThreadNameThrowsInvalidThreadError() async throws {
        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }
        
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(isMultithread: true))
        
        threadsService.threads.append(ChatThreadMapper.map(MockData.getThread(threadId: uuid)))
        
        XCTAssertThrowsError(try CXoneChat.threads.updateName("Thread Name", for: UUID())) { error in
            XCTAssertEqual(error as? CXoneChatError, CXoneChatError.invalidThread)
        }
    }
    
    func testUpdateThreadNameNoEmptyMessageArray() async throws {
        currentExpectation = XCTestExpectation(description: "On update threadName ")
        
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(isMultithread: true))
        
        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }
        
        let thread = ChatThreadMapper.map(MockData.getThread(threadId: uuid))
        var check = false
        
        socketService.messageSend = 0
        socketService.messageSent = { [weak self] sendMessage in
            guard !check, sendMessage.contains("UpdateThread") else {
                return
            }
            guard let index = self?.CXoneChat.threads.get().index(of: thread.id) else {
                XCTFail("\(#function) could not get index.")
                return
            }
            
            XCTAssertFalse(self?.CXoneChat.threads.get()[index].name?.isEmpty ?? true)
            XCTAssertEqual(self?.CXoneChat.threads.get()[index].name, "Thread Name")
            
            self?.currentExpectation.fulfill()
            check = true
        }
        
        threadsService.threads.append(thread)
        
        XCTAssertNoThrow(try CXoneChat.threads.updateName("Thread Name", for: thread.id))
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testUpdateThreadNameWithEmptyMessageArray() async throws {
        currentExpectation = XCTestExpectation(description: "On update threadName ")
        
        socketService.messageSent = { [weak self] sendMessage in
            if sendMessage.contains("AuthorizeCustomer") {
                do {
                    try self?.customerService.processCustomerReconnectEvent()
                } catch {
                    XCTFail(error.localizedDescription)
                }
            } else {
                self?.currentExpectation.fulfill()
            }
        }
        
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(isMultithread: true), isEventMessageHandlerActive: false)
        
        let threadId = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7")!
        threadsService.threads.append(ChatThreadMapper.map(MockData.getThread(threadId: threadId)))
        
        XCTAssertNoThrow(try CXoneChat.threads.updateName("Thread Name", for: threadId))
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testGetPrechatSurveyNoEmpty() async throws {
        try await setUpConnection(
            channelConfiguration: MockData.getChannelConfiguration(
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
        
        XCTAssertNotNil(CXoneChat.threads.preChatSurvey)
    }
    
    func testCreateWithoutCustomFieldsDefinitionThrows() async throws {
        try await setUpConnection(
            channelConfiguration: MockData.getChannelConfiguration(
                prechatSurvey: PreChatSurveyDTO(
                    name: "Prechat Survey",
                    customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.nameTextCustomField))])
            )
        )
        
        await XCTAssertAsyncThrowsError(try await CXoneChat.threads.create())
    }
    
    func testCreateWithCustomFieldsDefinitionNoThrow() async throws {
        try await setUpConnection(
            channelConfiguration: MockData.getChannelConfiguration(
                prechatSurvey: PreChatSurveyDTO(
                    name: "Prechat Survey",
                    customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.nameTextCustomField))])
            )
        )
        
        try await CXoneChat.threads.create(with: ["firstName": "Peter"])
    }
    
    func testCreateWithTextCustomFieldNoThrow() async throws {
        try await setUpConnection(
            channelConfiguration: MockData.getChannelConfiguration(
                prechatSurvey: PreChatSurveyDTO(
                    name: "Prechat Survey",
                    customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.nameTextCustomField))])
            )
        )
        
        _ = try await CXoneChat.threads.create(with: ["firstName": "Peter"])
    }
    
    func testCreateWithEmailCustomFieldNoThrow() async throws {
        try await setUpConnection(
            channelConfiguration: MockData.getChannelConfiguration(
                prechatSurvey: PreChatSurveyDTO(
                    name: "Prechat Survey",
                    customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.emailTextCustomField))])
            )
        )
        
        _ = try await CXoneChat.threads.create(with: ["email": "john.doe@email.com"])
    }
    
    func testCreateWithSelectorCustomFieldNoThrow() async throws {
        try await setUpConnection(
            channelConfiguration: MockData.getChannelConfiguration(
                prechatSurvey: PreChatSurveyDTO(
                    name: "Prechat Survey",
                    customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .selector(MockData.genderSelectorCustomField))]
                )
            )
        )
        
        _ = try await CXoneChat.threads.create(with: ["gender": "gender-male"])
    }
    
    func testCreateWithHierarchicalCustomFieldNoThrow() async throws {
        try await setUpConnection(
            channelConfiguration: MockData.getChannelConfiguration(
                prechatSurvey: PreChatSurveyDTO(
                    name: "Prechat Survey",
                    customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .hierarchical(MockData.optionsHierarchicalCustomField))]
                )
            )
        )
        
        _ = try await CXoneChat.threads.create(with: ["options": "option-b-1"])
    }
    
    func testCustomFieldsAreSetAfterCreate() async throws {
        try await setUpConnection(
            channelConfiguration: MockData.getChannelConfiguration(
                prechatSurvey: PreChatSurveyDTO(
                    name: "Prechat Survey",
                    customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.emailTextCustomField))]
                )
            )
        )
        
        try await CXoneChat.threads.create(with: ["email": "john.doe@mail.com"])
        
        guard let thread = CXoneChat.threads.get().last else {
            throw XCTError("Unable to retrieve required thread")
        }
        
        XCTAssertFalse(CXoneChat.threads.customFields.get(for: thread.id).isEmpty)
    }
    
    func testCustomFieldsNotOverrideStoredOnes() async throws {
        try await setUpConnection(
            channelConfiguration: MockData.getChannelConfiguration(
                prechatSurvey: PreChatSurveyDTO(
                    name: "Prechat Survey",
                    customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.emailTextCustomField))]
                )
            )
        )
        
        try await CXoneChat.threads.create(with: ["email": "john.doe@mail.com"])
        
        guard let thread = CXoneChat.threads.get().last else {
            throw XCTError("Unable to retrieve required thread")
        }
        
        try CXoneChat.threads.customFields.set(["firstName": "John", "gender": "Male"], for: thread.id)
        
        XCTAssertFalse(CXoneChat.threads.customFields.get(for: thread.id).isEmpty)
        XCTAssertEqual(CXoneChat.threads.customFields.get(for: thread.id).count, 3)
    }
    
    func testLiveChatDoesNotFailToggleEnabled() async throws {
        currentExpectation = XCTestExpectation(description: "testLiveChatDoesNotFailToggleEnabled")

        connectionService.connectionContext.channelConfig = MockData.getChannelConfiguration(features: ["isRecoverLivechatDoesNotFailEnabled": true], isOnline: true, isLiveChat: true)
        
        XCTAssertTrue(connectionContext.channelConfig.settings.isRecoverLiveChatDoesNotFailEnabled)

        let error = OperationError(errorCode: .recoveringThreadFailed, transactionId: LowerCaseUUID(), errorMessage: "Recovering failed")
        threadsService.processRecoveringThreadFailedError(error)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testLiveChatDoesNotFailToggleDisabled() async throws {
        currentExpectation = XCTestExpectation(description: "testLiveChatDoesNotFailToggleDisabled")
        currentExpectation.isInverted = true
        
        try await setUpConnection(channelConfiguration: MockData.getChannelConfiguration(features: ["isRecoverLivechatDoesNotFailEnabled": false], isOnline: true, isLiveChat: true))
        
        XCTAssertFalse(connectionContext.channelConfig.settings.isRecoverLiveChatDoesNotFailEnabled)
        
        let error = OperationError(errorCode: .recoveringThreadFailed, transactionId: LowerCaseUUID(), errorMessage: "Recovering failed")
        threadsService.processRecoveringThreadFailedError(error)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testInboxAssigneeImageUrlMappedCorrectly() throws {
        let data = try loadBundleData(from: "CaseInboxAssigneeChanged", type: "json")
        let event = try decoder.decode(ContactInboxAssigneeChangedEventDTO.self, from: data)
        
        guard let inboxAssignee = event.data.inboxAssignee else {
            throw XCTError("inboxAssignee is nil")
        }
        
        XCTAssertEqual(inboxAssignee.id, 12328)
        XCTAssertEqual(inboxAssignee.nickname, "Nickname")
        XCTAssertFalse(inboxAssignee.isBotUser)
        XCTAssertFalse(inboxAssignee.isSurveyUser)
        XCTAssertEqual(inboxAssignee.publicImageUrl, "https://app-de-na1.niceincontact.com/img/user/z.png")
        
        let agent = AgentMapper.map(inboxAssignee)
        XCTAssertNil(agent.inContactId)
        XCTAssertEqual(agent.loginUsername, "")
        XCTAssertNil(agent.emailAddress)
    }
}
