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
        inContactId: UUID(),
        emailAddress: nil,
        loginUsername: "kjoe",
        firstName: "name",
        surname: "surname",
        nickname: nil,
        isBotUser: false,
        isSurveyUser: false,
        imageUrl: ""
    )
    

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
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(.init(id: .init()))
        
        socketService.connectionContext.channelConfig = .init(
            settings: .init(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: true),
            isAuthorizationEnabled: false
        )
        
        XCTAssertThrowsError(try CXoneChat.threads.create())
    }
    
    func testCreateThreadThrowsWithoutConnected() {
        CXoneChat.connection.disconnect()

        XCTAssertThrowsError(try CXoneChat.threads.create())
    }

    func testCreateThreadNotThrowError() {
        XCTAssertNoThrow(try CXoneChat.threads.create())
    }

    func testLoadThreadsDoesNotThrows() {
        let expectation = XCTestExpectation(description: "closure Called")

        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = .init(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false
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
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = .init(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: false),
            isAuthorizationEnabled: false
        )

        (CXoneChat.threads as? ChatThreadsService)?.threads.append(.init(id: UUID()))

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
        let thread = ChatThread(_id: UUID().uuidString, id: uuid)
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
        
        let thread = ChatThread(_id: UUID().uuidString, id: UUID())
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
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = .init(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: true),
            isAuthorizationEnabled: true
        )
        
        XCTAssertThrowsError(try CXoneChat.threads.archive(ChatThread(_id: "", id: UUID())))
    }

    func testArchiveThreadThrowsThreadIndexError() {
        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = .init(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true),
            isAuthorizationEnabled: true
        )

        XCTAssertThrowsError(try CXoneChat.threads.archive(ChatThread(_id: "", id: UUID())), "invalid thread") { error in
            XCTAssertEqual(error as? CXoneChatError, .invalidThread)
        }
    }

    func testArchiveThreadRemoveFromList() {
        let expectation = XCTestExpectation(description: "archivedThread")

        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = .init(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true),
            isAuthorizationEnabled: true
        )
        var thread = ChatThread(_id: UUID().uuidString, id: UUID())
        thread._id = UUID().uuidString
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

        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = .init(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true),
            isAuthorizationEnabled: true
        )
        var thread = ChatThreadDTO(
            id: UUID().uuidString,
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
                messageContent: .init(type: .text, payload: .init(text: "", elements: []), fallbackText: ""),
                createdAt: try Date.ISO8601(from: "2022-07-31T21:22:47+00:00"),
                attachments: [],
                direction: .inbound,
                userStatistics: .init(seenAt: nil, readAt: nil),
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

        let thread = ChatThread(_id: UUID().uuidString, id: UUID())
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
                        createdAt: try Date.ISO8601(from: "2022-07-31T21:22:57+00:00")
                    ),
                    messages: [
                        MessageDTO(
                            idOnExternalPlatform: UUID(),
                            threadIdOnExternalPlatform: thread.id,
                            messageContent: .init(type: .text, payload: .init(text: "", elements: []), fallbackText: ""),
                            createdAt: try Date.ISO8601(from: "2022-07-31T21:22:47+00:00"),
                            attachments: [],
                            direction: .inbound,
                            userStatistics: .init(seenAt: nil, readAt: nil),
                            authorUser: nil,
                            authorEndUserIdentity: nil
                        ),
                        MessageDTO(
                            idOnExternalPlatform: UUID(),
                            threadIdOnExternalPlatform: thread.id,
                            messageContent: .init(type: .text, payload: .init(text: "", elements: []), fallbackText: ""),
                            createdAt: try Date.ISO8601(from: "2022-07-31T21:22:57+00:00"),
                            attachments: [],
                            direction: .inbound,
                            userStatistics: .init(seenAt: nil, readAt: nil),
                            authorUser: nil,
                            authorEndUserIdentity: nil
                        )
                    ],
                    ownerAssignee: nil,
                    thread: ReceivedThreadDataDTO(
                        id: UUID().uuidString,
                        idOnExternalPlatform: thread.id,
                        channelId: "channel_1",
                        threadName: "name",
                        createdAt: try Date.ISO8601(from: "2022-07-31T21:22:57+00:00"),
                        updatedAt: try Date.ISO8601(from: "2022-07-31T21:22:57+00:00"),
                        canAddMoreMessages: true
                    ),
                    messagesScrollToken: "token"
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

        let thread = ChatThread(_id: UUID().uuidString, id: UUID())
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
        var thread = ChatThread(_id: UUID().uuidString, id: UUID())
        thread._id = UUID().uuidString
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)

        XCTAssertEqual(CXoneChat.threads.get().count, 1)

        XCTAssertThrowsError(try CXoneChat.socketDelegateManager.setThreadAgent(agent: agent, threadIdOnExternalPlatform: UUID()))
    }

    func testSetThreadAgent() throws {
        var thread = ChatThread(_id: UUID().uuidString, id: UUID())
        thread._id = UUID().uuidString
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)

        XCTAssertEqual(CXoneChat.threads.get().count, 1)

        try CXoneChat.socketDelegateManager.setThreadAgent(agent: agent, threadIdOnExternalPlatform: thread.id)

        XCTAssertEqual(CXoneChat.threads.get().first?.assignedAgent?.id, agent.id)
        XCTAssertEqual(CXoneChat.threads.get().first?.assignedAgent?.fullName, agent.fullName)
    }

    func testNotifyArchiveThreadEvent() {
        currentExpectation = XCTestExpectation(description: "Thread Archive Event")

        CXoneChat.socketDelegateManager.notifyThreadArchivedEvent()

        wait(for: [currentExpectation], timeout: 1.0)
    }

    func testProcessThreadLoad() throws {
        currentExpectation = XCTestExpectation(description: "On Thread Load from Process")

        CXoneChat.socketDelegateManager.processThreadRecoverEvent(
            .init(
                eventId: UUID(),
                postback: .init(
                    eventType: .recoverThread,
                    data: .init(
                        consumerContact: .init(id: UUID().uuidString, threadIdOnExternalPlatform: UUID(), status: .open, createdAt: Date()),
                        messages: [],
                        ownerAssignee: nil,
                        thread: .init(
                            id: "asd",
                            idOnExternalPlatform: UUID(),
                            channelId: "",
                            threadName: "",
                            createdAt: Date(),
                            updatedAt: Date(),
                            canAddMoreMessages: true
                        ),
                        messagesScrollToken: "asdasda"
                    )
                )
            )
        )

        wait(for: [currentExpectation], timeout: 1.0)
    }

    func testProcessThreadLastMessage() throws {
        currentExpectation = XCTestExpectation(description: "On ThreadInfo load ")

        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }

        var thread = ChatThread(id: uuid)
        thread._id = UUID().uuidString

        let data = try loadStubFromBundle(withName: "ThreadMetadataLoadedEvent", extension: "json")
        let event = try JSONDecoder().decode(ThreadMetadataLoadedEventDTO.self, from: data)
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)
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

        var thread = ChatThread(id: uuid)
        thread._id = UUID().uuidString

        let data = try loadStubFromBundle(withName: "ThreadMetadataLoadedEvent", extension: "json")
        let event = try JSONDecoder().decode(ThreadMetadataLoadedEventDTO.self, from: data)
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)

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

        var thread = ChatThread(id: uuid)
        thread._id = UUID().uuidString

        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = .init(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: true),
            isAuthorizationEnabled: false
        )

        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)

        XCTAssertThrowsError(try CXoneChat.threads.updateName("Thread Name", for: UUID()))
    }
    func testUpdateThreadNameThrowsInvalidThreadError() throws {
        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }

        var thread = ChatThread(id: uuid)
        thread._id = UUID().uuidString

        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = .init(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true),
            isAuthorizationEnabled: false
        )

        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)

        XCTAssertThrowsError(try CXoneChat.threads.updateName("Thread Name", for: UUID()))
    }

    func testUpdateThreadNameNoEmptyMessageArray() throws {
        currentExpectation = XCTestExpectation(description: "On update threadName ")

        guard let uuid = UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7") else {
            throw CXoneChatError.invalidData
        }

        var thread = ChatThread(id: uuid)
        thread._id = UUID().uuidString
        var check = false

        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = .init(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true),
            isAuthorizationEnabled: false
        )
        thread.messages.append(
            .init(
                id: UUID(),
                threadId: UUID(),
                messageContent: .init(type: .text, payload: .init(text: "", elements: []), fallbackText: ""),
                createdAt: Date(),
                attachments: [],
                direction: .inbound,
                userStatistics: .init(seenAt: nil, readAt: nil),
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

        var thread = ChatThread(id: uuid)
        thread._id = UUID().uuidString

        (CXoneChat.connection as? ConnectionService)?.connectionContext.channelConfig = .init(
            settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true),
            isAuthorizationEnabled: false
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
            messageContent: .init(type: .text, payload: .init(text: "", elements: []), fallbackText: ""),
            createdAt: Date(),
            attachments: [],
            direction: .inbound,
            userStatistics: .init(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        XCTAssertThrowsError(try (CXoneChat.threads as? ChatThreadsService)?.appendMessageToThread(message))
    }
    
    func testAppendMessageToThreadNoThrows() {
        let uuid = UUID()
        
        let thread = ChatThread(id: uuid)
        (CXoneChat.threads as? ChatThreadsService)?.threads.append(thread)
        
        let message = MessageDTO(
            idOnExternalPlatform: uuid,
            threadIdOnExternalPlatform: UUID(),
            messageContent: .init(type: .text, payload: .init(text: "", elements: []), fallbackText: ""),
            createdAt: Date(),
            attachments: [],
            direction: .inbound,
            userStatistics: .init(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        XCTAssertNoThrow(try (CXoneChat.threads as? ChatThreadsService)?.appendMessageToThread(message))
    }
    
    func testWelcomeMessageHandlerNoThrow() throws {
        UserDefaults.standard.set("Hello {{customer.firstName|stranger}}!", forKey: "welcomeMessage")
        
        XCTAssertNoThrow(try CXoneChat.threads.create())
    }
    
    func testWelcomeMessagePostHandlerThrowsMissingMessage() {
        currentExpectation = XCTestExpectation(description: "Welcome message post handler")
        
        XCTAssertNoThrow(try CXoneChat.threads.create())
        
        (CXoneChat.threads as? ChatThreadsService)?.onWelcomeMessageReceived()
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testWelcomeMessagePostHandlerThrowsMissingCustomer() {
        currentExpectation = XCTestExpectation(description: "Welcome message post handler")
        
        XCTAssertNoThrow(try CXoneChat.threads.create())
        
        UserDefaults.standard.set("Hello {{customer.firstName|stranger}}!", forKey: "welcomeMessage")
        socketService.connectionContext.customer = nil
        
        (CXoneChat.threads as? ChatThreadsService)?.onWelcomeMessageReceived()
        
        wait(for: [currentExpectation], timeout: 1.0)
    }
    
    func testWelcomeMessagePostHandler() {
        XCTAssertNoThrow(try CXoneChat.threads.create())
        
        UserDefaults.standard.set("Hello {{customer.firstName|stranger}}!", forKey: "welcomeMessage")
        (CXoneChat.threads as? ChatThreadsService)?.onWelcomeMessageReceived()
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
