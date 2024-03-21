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
import XCTest

class ThreadsProviderTests: CXoneXCTestCase {
    
    func testCreateThreadThrowsError() async throws {
        try await setUpConnection()
        
        threadsService.threads.append(ChatThreadMapper.map(MockData.getThread()))
        
        XCTAssertThrowsError(try CXoneChat.threads.create())
    }
    
    func testCreateThreadThrowsWithoutConnected() {
        XCTAssertThrowsError(try CXoneChat.threads.create())
    }
    
    func testCreateThreadNotThrowError() async throws {
        try await setUpConnection()
        
        XCTAssertNoThrow(try CXoneChat.threads.create(with: ["email": "john@doe.com"]))
    }
    
    func testLoadThreadsDoesNotThrows() async throws {
        currentExpectation = XCTestExpectation(description: "Load Threads Called")
        
        socketService.messageSent = { [weak self] message in
            XCTAssertTrue(!message.isEmpty)
            
            self?.currentExpectation.fulfill()
        }
        
        try await setUpConnection()
        
        XCTAssertEqual(socketService.messageSend, 2, "2 event should be called - Authorize, Load")
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testLoadThreadThrowErrorWithSingleThreadConfig() async throws {
        try await setUpConnection()
        
        threadsService.threads.append(ChatThreadMapper.map(MockData.getThread()))
        
        XCTAssertThrowsError(try CXoneChat.threads.load(), "Error catched") { error in
            XCTAssertEqual(error.localizedDescription, CXoneChatError.unsupportedChannelConfig.localizedDescription)
        }
    }
    
    func testLoadThread() async throws {
        currentExpectation = XCTestExpectation(description: "closure Called")
        
        try await setUpConnection()
        
        socketService.messageSend = 0
        socketService.messageSent = { [weak self] message in
            XCTAssertTrue(!message.isEmpty)
            
            self?.currentExpectation.fulfill()
        }
        
        XCTAssertNoThrow(try CXoneChat.threads.load())
        XCTAssertEqual(socketService.messageSend, 1)
        
        wait(for: [currentExpectation], timeout: 1.0)
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
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testLoadThreadInfo() async throws {
        currentExpectation = XCTestExpectation(description: "closure Called")
        
        try await setUpConnection()
        
        let thread = ChatThreadMapper.map(MockData.getThread())
        threadsService.threads.append(thread)
        
        socketService.messageSend = 0
        socketService.messageSent = { [weak self] message in
            XCTAssertTrue(!message.isEmpty)
            
            self?.currentExpectation.fulfill()
        }
        
        XCTAssertNoThrow(try CXoneChat.threads.loadInfo(for: thread))
        XCTAssertEqual(socketService.messageSend, 1)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testArchiveThreadThrowsUnsupportedChannelConfigError() {
        connectionService.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: true),
            isAuthorizationEnabled: true,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )
        
        XCTAssertThrowsError(try CXoneChat.threads.archive(ChatThreadMapper.map(MockData.getThread())))
    }
    
    func testArchiveThreadThrowsThreadIndexError() async throws {
        try await setUpConnection(isMultithread: true)
        
        XCTAssertThrowsError(try CXoneChat.threads.archive(ChatThreadMapper.map(MockData.getThread())), "invalid thread") { error in
            XCTAssertEqual(error as? CXoneChatError, .invalidThread)
        }
    }
    func testArchiveThreadRemoveFromList() async throws {
        currentExpectation = XCTestExpectation(description: "archivedThread")
        
        try await setUpConnection(isMultithread: true)
        
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
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testArchiveThreadSendToServerMessage() async throws {
        currentExpectation = XCTestExpectation(description: "closure Called")
        
        try await setUpConnection(isMultithread: true)
        
        let thread = ChatThreadMapper.map(MockData.getThread())
        threadsService.threads.append(thread)
        
        socketService.messageSend = 0
        socketService.messageSent = { [weak self] message in
            XCTAssertTrue(!message.isEmpty)
            
            self?.currentExpectation.fulfill()
        }
        
        XCTAssertNoThrow(try CXoneChat.threads.archive(thread))
        XCTAssertEqual(socketService.messageSend, 1)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testThreadRecover() throws {
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
                    customerContactFields: []
                )
            )
        )
        
        let data = try JSONEncoder().encode(event)
        
        try threadsService.processThreadRecoveredEvent(try data.decode() as ThreadRecoveredEventDTO)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testFetchThreadList() async throws {
        currentExpectation = XCTestExpectation(description: "testFetchThreadListLoadThreads")
        
        try await setUpConnection()
        
        socketService.messageSent = { sendMessage in
            guard sendMessage.contains("LoadThreadMetadata") else {
                return
            }
            
            // Skip and simulate loading metadata since this is not an integration test
            self.CXoneChat.delegate = self
            self.threadsService.threads.removeAll(where: { $0.id.uuidString != "3118D0DF-99AA-49E9-A115-C5B98736DEE7" })
            
            do {
                let data = try self.loadStubFromBundle(withName: "ThreadMetadataLoadedEvent", extension: "json")
                let event = try JSONDecoder().decode(ThreadMetadataLoadedEventDTO.self, from: data)
                
                try self.threadsService.processThreadMetadataLoadedEvent(event)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        let data = try loadStubFromBundle(withName: "ThreadListFetchedEvent", extension: "json")
        let event = try JSONDecoder().decode(GenericEventDTO.self, from: data)
        
        try threadsService.processThreadListFetchedEvent(event)
        
        wait(for: [currentExpectation], timeout: 1.0)
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
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testNotifyArchiveThreadEvent() async {
        currentExpectation = XCTestExpectation(description: "Thread Archive Event")
        
        threadsService.processThreadArchivedEvent()
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessThreadLoad() throws {
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
        
        let data = try JSONEncoder().encode(eventData)
        
        try threadsService.processThreadRecoveredEvent(try data.decode() as ThreadRecoveredEventDTO)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessThreadLastMessage() throws {
        currentExpectation = XCTestExpectation(description: "On ThreadInfo load")
        
        let data = try loadStubFromBundle(withName: "ThreadMetadataLoadedEvent", extension: "json")
        let event = try JSONDecoder().decode(ThreadMetadataLoadedEventDTO.self, from: data)
        
        threadsService.threads.append(ChatThreadMapper.map(MockData.getThread(threadId: UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7")!)))
        
        try threadsService.processThreadMetadataLoadedEvent(event)
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testProcessThreadLastMessageThrowsInvalidThread() throws {
        let data = try loadStubFromBundle(withName: "ThreadMetadataLoadedEvent", extension: "json")
        
        XCTAssertThrowsError(try threadsService.processThreadMetadataLoadedEvent(try data.decode() as ThreadMetadataLoadedEventDTO)) { error in
            XCTAssertEqual(error as? CXoneChatError, CXoneChatError.invalidThread)
        }
    }
    
    func testUpdateThreadNameThrowsUnsupportedChannelConfigError() throws {
        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }
        
        connectionService.connectionContext.channelConfig = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: true),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            contactCustomFieldDefinitions: [],
            customerCustomFieldDefinitions: []
        )
        
        threadsService.threads.append(ChatThreadMapper.map(MockData.getThread(threadId: uuid)))
        
        XCTAssertThrowsError(try CXoneChat.threads.updateName("Thread Name", for: UUID()))
    }
    
    func testUpdateThreadNameThrowsInvalidThreadError() async throws {
        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }
        
        try await setUpConnection(isMultithread: true)
        
        threadsService.threads.append(ChatThreadMapper.map(MockData.getThread(threadId: uuid)))
        
        XCTAssertThrowsError(try CXoneChat.threads.updateName("Thread Name", for: UUID())) { error in
            XCTAssertEqual(error as? CXoneChatError, CXoneChatError.invalidThread)
        }
    }
    
    func testUpdateThreadNameNoEmptyMessageArray() async throws {
        currentExpectation = XCTestExpectation(description: "On update threadName ")
        
        try await setUpConnection(isMultithread: true)
        
        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }
        
        var thread = ChatThreadMapper.map(MockData.getThread(threadId: uuid))
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
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testUpdateThreadNameWithEmptyMessageArray() async throws {
        currentExpectation = XCTestExpectation(description: "On update threadName ")
        
        socketService.messageSent = { [weak self] sendMessage in
            self?.currentExpectation.fulfill()
        }
        
        try await setUpConnection(isMultithread: true)
        
        let threadId = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7")!
        threadsService.threads.append(ChatThreadMapper.map(MockData.getThread(threadId: threadId)))
        
        XCTAssertNoThrow(try CXoneChat.threads.updateName("Thread Name", for: threadId))
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testGetPrechatSurveyEmpty() async throws {
        try await setUpConnection(
            prechatSurvey: PreChatSurveyDTO(
                name: "Prechat Survey",
                customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.nameTextCustomField))]
            )
        )
        
        XCTAssertNil(CXoneChat.threads.preChatSurvey)
    }
    
    func testGetPrechatSurveyNoEmpty() async throws {
        try await setUpConnection(
            prechatSurvey: PreChatSurveyDTO(
                name: "Prechat Survey",
                customFields: [
                    PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.nameTextCustomField)),
                    PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.emailTextCustomField)),
                    PreChatSurveyCustomFieldDTO(isRequired: true, type: .selector(MockData.genderSelectorCustomField)),
                    PreChatSurveyCustomFieldDTO(isRequired: true, type: .hierarchical(MockData.optionsHierarchicalCustomField))
                ]
            ),
            contactCustomFields: [
                .textField(MockData.nameTextCustomField),
                .textField(MockData.emailTextCustomField),
                .selector(MockData.genderSelectorCustomField),
                .hierarchical(MockData.optionsHierarchicalCustomField)
            ]
        )
        
        XCTAssertNotNil(CXoneChat.threads.preChatSurvey)
    }
    
    func testGetPrechatSurveyWithFilteredCustomFields() async throws {
        try await setUpConnection(
            prechatSurvey: PreChatSurveyDTO(
                name: "Prechat Survey",
                customFields: [
                    PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.nameTextCustomField)),
                    PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.emailTextCustomField))
                ]),
            contactCustomFields: [.textField(MockData.emailTextCustomField)]
        )
        
        XCTAssertNotNil(CXoneChat.threads.preChatSurvey)
        XCTAssertEqual(CXoneChat.threads.preChatSurvey?.customFields.count, 1)
    }
    
    func testCreateWithoutCustomFieldsDefinitionThrows() async throws {
        try await setUpConnection(
            prechatSurvey: PreChatSurveyDTO(
                name: "Prechat Survey",
                customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.nameTextCustomField))]),
            contactCustomFields: [.textField(MockData.nameTextCustomField)]
        )
        
        XCTAssertThrowsError(try CXoneChat.threads.create())
    }
    
    func testCreateWithCustomFieldsDefinitionNoThrow() async throws {
        try await setUpConnection(
            prechatSurvey: PreChatSurveyDTO(
                name: "Prechat Survey",
                customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.nameTextCustomField))]),
            contactCustomFields: [.textField(MockData.nameTextCustomField)]
        )
        
        XCTAssertNoThrow(try CXoneChat.threads.create(with: ["firstName": "Peter"]))
    }
    
    func testCreateWithTextCustomFieldNoThrow() async throws {
        try await setUpConnection(
            prechatSurvey: PreChatSurveyDTO(
                name: "Prechat Survey",
                customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.nameTextCustomField))]),
            contactCustomFields: [.textField(MockData.nameTextCustomField)]
        )
        
        _ = try CXoneChat.threads.create(with: ["firstName": "Peter"])
    }
    
    func testCreateWithEmailCustomFieldNoThrow() async throws {
        try await setUpConnection(
            prechatSurvey: PreChatSurveyDTO(
                name: "Prechat Survey",
                customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.emailTextCustomField))]),
            contactCustomFields: [.textField(MockData.emailTextCustomField)]
        )
        
        _ = try CXoneChat.threads.create(with: ["email": "john.doe@email.com"])
    }
    
    func testCreateWithSelectorCustomFieldNoThrow() async throws {
        try await setUpConnection(
            prechatSurvey: PreChatSurveyDTO(
                name: "Prechat Survey",
                customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .selector(MockData.genderSelectorCustomField))]
            ),
            contactCustomFields: [.selector(MockData.genderSelectorCustomField)]
        )
        
        _ = try CXoneChat.threads.create(with: ["gender": "gender-male"])
    }
    
    func testCreateWithHierarchicalCustomFieldNoThrow() async throws {
        try await setUpConnection(
            prechatSurvey: PreChatSurveyDTO(
                name: "Prechat Survey",
                customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .hierarchical(MockData.optionsHierarchicalCustomField))]
            ),
            contactCustomFields: [.hierarchical(MockData.optionsHierarchicalCustomField)]
        )
        
        _ = try CXoneChat.threads.create(with: ["options": "option-b-1"])
    }
    
    func testCustomFieldsAreSetAfterCreate() async throws {
        try await setUpConnection(
            prechatSurvey: PreChatSurveyDTO(
                name: "Prechat Survey",
                customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.emailTextCustomField))]
            ),
            contactCustomFields: [.textField(MockData.emailTextCustomField)]
        )
        
        let threadId = try CXoneChat.threads.create(with: ["email": "john.doe@mail.com"])
        
        XCTAssertFalse((CXoneChat.threads.customFields.get(for: threadId) as [CustomFieldType]).isEmpty)
    }
    
    func testCustomFieldsNotOverrideStoredOnes() async throws {
        try await setUpConnection(
            prechatSurvey: PreChatSurveyDTO(
                name: "Prechat Survey",
                customFields: [PreChatSurveyCustomFieldDTO(isRequired: true, type: .textField(MockData.emailTextCustomField))]
            ),
            contactCustomFields: [
                .textField(MockData.nameTextCustomField),
                .textField(MockData.emailTextCustomField),
                .selector(MockData.genderSelectorCustomField)
            ]
        )
        
        let threadId = try CXoneChat.threads.create(with: ["email": "john.doe@mail.com"])
        
        try CXoneChat.threads.customFields.set(["firstName": "John", "gender": "Male"], for: threadId)
        
        XCTAssertFalse((CXoneChat.threads.customFields.get(for: threadId) as [CustomFieldType]).isEmpty)
        XCTAssertEqual((CXoneChat.threads.customFields.get(for: threadId) as [CustomFieldType]).count, 3)
    }
}
