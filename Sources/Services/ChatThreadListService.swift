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
// swiftlint:disable file_length

import Combine
import Foundation

class ChatThreadListService {

    // MARK: - Sub objects
    
    struct WeakContainer<Object: AnyObject> {
        weak var object: Object?
    }
    
    // MARK: - Properties

    let socketService: SocketService
    let eventsService: EventsService
    let customerCustomFields: CustomerCustomFieldsProvider
    let welcomeMessageManager: WelcomeMessageManager
    
    var threads = [ChatThread]()
    /// The array is used to store the providers of the threads that are currently active.
    /// The providers are stored as weak references to prevent retain cycles when the thread is deallocated.
    var threadProviders = [WeakContainer<ChatThreadService>]()
    
    let delegate: CXoneChatDelegate

    private var persistedSetPositionInQueueEvent: SetPositionInQueueEventDTO?

    private var connectionContext: ConnectionContext {
        socketService.connectionContext
    }
    private var contactCustomFieldsService: ContactCustomFieldsService? {
        customFields as? ContactCustomFieldsService
    }
    private var customerCustomFieldsService: CustomerCustomFieldsService? {
        customerCustomFields as? CustomerCustomFieldsService
    }

    // MARK: - Protocol Properties

    var customFields: ContactCustomFieldsProvider
    
    var events: AnyPublisher<any ReceivedEvent, Never> {
        socketService.events
    }
    var cancellables: [AnyCancellable] {
        get { socketService.cancellables }
        set { socketService.cancellables = newValue }
    }

    // MARK: - Init

    init(
        contactCustomFields: ContactCustomFieldsProvider,
        customerCustomFields: CustomerCustomFieldsProvider,
        socketService: SocketService,
        eventsService: EventsService,
        welcomeMessageManager: WelcomeMessageManager,
        delegate: CXoneChatDelegate
    ) {
        self.customFields = contactCustomFields
        self.customerCustomFields = customerCustomFields
        self.socketService = socketService
        self.eventsService = eventsService
        self.welcomeMessageManager = welcomeMessageManager
        self.delegate = delegate
    }
}

// MARK: - ChatThreadListProvider Implementation

extension ChatThreadListService: ChatThreadListProvider {

    var preChatSurvey: PreChatSurvey? {
        guard let prechat = connectionContext.channelConfig.prechatSurvey else {
            return nil
        }

        guard !prechat.customFields.isEmpty else {
            LogManager.info("Unable to get case custom fields for pre-chat survey")
            return nil
        }

        return PreChatSurvey(name: prechat.name, customFields: prechat.customFields.map(PreChatSurveyCustomFieldMapper.map))
    }

    func get() -> [ChatThread] {
        threads
    }
    
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/missingPreChatCustomFields`` if the server requires to fill-up some contact custom fields before initializing chat thread.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/attachmentError`` if the provided attachment was unable to be sent.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if attachments upload `url` has not been set properly or attachment uploaded data object is missing
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the the outbound message has no ``postback``, empty ``text``, and empty ``attachments``.
    /// - Throws: ``CXoneChatError/noSuchFile`` if an attached file could not be found.
    /// - Throws: ``CXoneChatError/invalidFileSize`` if size of the attachment exceeds the allowed size
    /// - Throws: ``CXoneChatError/invalidFileType`` if type of the attachment is not included in the allowed file MIME type
    /// - Throws: ``CXoneChatError/invalidData`` if the conversion from object instance to data failed
    ///     or when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    /// - Throws: An error if any value throws an error during encoding.
    @discardableResult
    func create() async throws -> ChatThreadProvider {
        try await create(with: [:])
    }
    
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/missingPreChatCustomFields`` if the server requires to fill-up some contact custom fields before initializing chat thread.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/attachmentError`` if the provided attachment was unable to be sent.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if attachments upload `url` has not been set properly or attachment uploaded data object is missing
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the the outbound message has no ``postback``, empty ``text``, and empty ``attachments``.
    /// - Throws: ``CXoneChatError/noSuchFile`` if an attached file could not be found.
    /// - Throws: ``CXoneChatError/invalidFileSize`` if size of the attachment exceeds the allowed size
    /// - Throws: ``CXoneChatError/invalidFileType`` if type of the attachment is not included in the allowed file MIME type
    /// - Throws: ``CXoneChatError/invalidData`` if the conversion from object instance to data failed
    ///     or when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    /// - Throws: An error if any value throws an error during encoding.
    @discardableResult
    func create(with customFields: [String: String]) async throws -> ChatThreadProvider {
        LogManager.trace("Creating a new thread")

        try socketService.checkForConnection()

        // Enable to create a new conversation from End Conversation experience
        if connectionContext.chatMode == .liveChat, !threads.isEmpty {
            clearStoredData()
        }
        
        guard connectionContext.chatMode == .multithread || threads.isEmpty else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        
        let thread = ChatThread(id: UUID(), state: .pending)
        
        if !customFields.isEmpty {
            let mappedCustomFields = customFields.map { CustomFieldDTO(ident: $0.key, value: $0.value, updatedAt: Date()) }
            
            contactCustomFieldsService?.updateFields(mappedCustomFields, for: thread.id)
        }
        
        if !allPrechatCustomFieldsFilled(for: thread.id) {
            throw CXoneChatError.missingPreChatCustomFields
        }
        
        threads.append(thread)
        
        let provider = try provider(for: thread)
        
        if let service = provider as? ChatThreadService, let message = UserDefaultsService.shared.get(String.self, for: .welcomeMessage) {
            thread.merge(messages: [try service.getParsedWelcomeMessage(message)])
        }
        
        if let message = UserDefaultsService.shared.get(String.self, for: .welcomeMessage), let threadService = provider as? ChatThreadService {
            try threadService.handleWelcomeMessage(message)
        }
        
        connectionContext.chatState = .ready
        
        if connectionContext.chatMode != .liveChat {
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
        }
        
        // Thread has been successfully created, store its ID for faster recovering
        if connectionContext.chatMode != .multithread {
            UserDefaultsService.shared.set(thread.id, for: .cachedThreadIdOnExternalPlatform)
        }

        if connectionContext.chatMode == .liveChat, let threadService = provider as? ChatThreadService {
            try await threadService.sendBeginLiveChatConversation()
        }

        delegate.onThreadUpdated(thread)

        return provider
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func load(with threadId: UUID?) async throws {
        try socketService.checkForConnection()

        try await recoverThread(threadId: threadId)
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func provider(for threadId: UUID) throws -> any ChatThreadProvider {
        guard let thread = threads.first(where: { $0.id == threadId }) else {
            throw CXoneChatError.invalidThread
        }
        
        return try provider(for: thread)
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func provider(for thread: ChatThread) throws -> any ChatThreadProvider {
        guard threads.contains(where: { $0.id == thread.id }) else {
            throw CXoneChatError.invalidThread
        }
        
        if let provider = threadProviders.first(where: { $0.object?.chatThread.id == thread.id })?.object {
            return provider
        }
        
        let provider = ChatThreadService(
            chatThread: thread,
            contactFieldsProvider: customFields,
            customerFieldsProvider: customerCustomFields,
            socketService: socketService,
            eventsService: eventsService,
            welcomeMessageManager: welcomeMessageManager,
            delegate: delegate
        )
        
        self.threadProviders.append(WeakContainer(object: provider))
        
        return provider
    }
}

// MARK: - Internal Methods

extension ChatThreadListService {
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the threadsService is not correctly registered.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError/invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func handleForCurrentChatMode(_ mode: ChatMode) async throws {
        switch mode {
        case .singlethread, .liveChat:
            let cachedThreadId: UUID? = UserDefaultsService.shared.get(UUID.self, for: .cachedThreadIdOnExternalPlatform)

            try await recoverThread(threadId: cachedThreadId)
        case .multithread:
            try await fetchThreadList()
        }
    }

    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func fetchThreadList() async throws {
        guard connectionContext.chatMode == .multithread else {
            throw CXoneChatError.unsupportedChannelConfig
        }

        LogManager.trace("Loading all of the threads for the current customer")

        let event = try eventsService.create(event: .fetchThreadList)

        let response = try await events.sink(
            type: .threadListFetched,
            as: GenericEventDTO.self,
            origin: event,
            socketService: socketService,
            eventsService: eventsService,
            cancellables: &cancellables
        )
        
        try await processThreadListFetchedEvent(response)
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the threadsService is not correctly registered.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func recoverThread(threadId: UUID?) async throws {
        LogManager.trace("Loading the a thread for the customer and gets messages")

        let validChatThreadStates: [ChatThreadState] = connectionContext.chatMode == .liveChat ? [.pending] : [.pending, .closed]

        if let threadId, let thread = threads.getThread(with: threadId), validChatThreadStates.contains(thread.state) {
            LogManager.info("Thread has been created locally or is archived -> no need to recover it")

            connectionContext.chatState = .ready
            
            delegate.onThreadUpdated(thread)
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
            return
        }

        let dataType = threadId.map { threadId -> EventDataType in
            let eventData = ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: threadId, threadName: nil))
            
            return connectionContext.chatMode == .liveChat ? .loadLiveChatData(eventData) : .loadThreadData(eventData)
        }
        
        if connectionContext.chatMode == .liveChat {
            try await recoverLivechatThread(eventDataType: dataType)
        } else {
            try await recoverMessagingThread(eventDataType: dataType)
        }
    }

    func recoverMessagingThread(eventDataType: EventDataType?) async throws {
        let event = try eventsService.create(event: .recoverThread, with: eventDataType)
        
        do {
            let response = try await events.sink(
                type: .threadRecovered,
                as: ThreadRecoveredEventDTO.self,
                origin: event,
                socketService: socketService,
                eventsService: eventsService,
                cancellables: &cancellables
            )
            
            try processThreadRecoveredEvent(response)
        } catch {
            if let error = error as? OperationError, error.errorCode == .recoveringThreadFailed {
                try await processRecoveringThreadFailedError(error)
            } else {
                throw error
            }
        }
    }
    
    func recoverLivechatThread(eventDataType: EventDataType?) async throws {
        let event = try eventsService.create(event: .recoverLiveChat, with: eventDataType)
        
        do {
            let response = try await events.sink(
                type: .liveChatRecovered,
                as: LiveChatRecoveredDTO.self,
                origin: event,
                socketService: socketService,
                eventsService: eventsService,
                cancellables: &cancellables
            )
            
            try processLiveChatRecoveredEvent(response)
        } catch {
            if let error = error as? OperationError, error.errorCode == .recoveringLivechatFailed {
                try await processRecoveringThreadFailedError(error)
            } else {
                throw error
            }
        }
    }
    
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func loadInfo(for threadId: UUID) async throws {
        guard let thread = threads.getThread(with: threadId) else {
            throw CXoneChatError.invalidThread
        }
        guard thread.state != .pending else {
            LogManager.info("Loads information about the thread is available only for threads existing in the backend")
            return
        }

        LogManager.trace("Loads information about the thread")

        let event = try eventsService.create(
            event: .loadThreadMetadata,
            with: .loadThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: threadId, threadName: nil)))
        )

        let response = try await events.sink(
            type: .threadMetadataLoaded,
            as: ThreadMetadataLoadedEventDTO.self,
            origin: event,
            socketService: socketService,
            eventsService: eventsService,
            cancellables: &cancellables
        )
        
        try processThreadMetadataLoadedEvent(response)
    }
}

// MARK: - EventReceiver

extension ChatThreadListService: EventReceiver {
    
    func addListeners() {
        addListener(for: .senderTypingStarted, with: processAgentTypingEvent)
        addListener(for: .senderTypingEnded, with: processAgentTypingEvent)
        addListener(processMessageReadChangeEvent)
        addListener(processMessageSeenChangedEvent)
        addListener(processContactInboxAssigneeChangedEvent)
        addListener(processCaseStatusChangedEvent)
        addListener(processSetPositionInQueueEvent)
        addListener(processMessageCreatedEvent)
    }

    func clearStoredData() {
        LogManager.info("Removing stored data for chat threads service")

        threads.removeAll()
        threadProviders.removeAll()

        contactCustomFieldsService?.clearStoredData()
    }
}

// MARK: - Socket Methods

extension ChatThreadListService {
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processThreadRecoveredEvent(_ event: ThreadRecoveredEventDTO) throws {
        LogManager.trace("Processing thread recovered with UUID - \(event.postback.data.thread.idOnExternalPlatform)")
        
        socketService.connectionContext.contactId = event.postback.data.consumerContact.id
        
        contactCustomFieldsService?.updateFields(
            event.postback.data.consumerContact.customFields,
            for: event.postback.data.thread.idOnExternalPlatform
        )
        customerCustomFieldsService?.updateFields(event.postback.data.customerCustomFields)
        
        let thread = threads.getThread(with: event.postback.data.thread.idOnExternalPlatform) ?? {
            let newThread = ChatThread(
                id: event.postback.data.thread.idOnExternalPlatform,
                state: event.postback.data.thread.canAddMoreMessages ? .ready : .closed
            )
            
            threads.append(newThread)
            
            return newThread
        }()
        
        thread.updated(from: event.postback.data)
        
        connectionContext.chatState = .ready

        delegate.onThreadUpdated(thread)
        delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processLiveChatRecoveredEvent(_ event: LiveChatRecoveredDTO) throws {
        LogManager.trace("Processing thread recovered with UUID - \(String(describing: event.postback.data?.thread.idOnExternalPlatform))")
        
        guard let data = event.postback.data, data.contact.status != .closed else {
            LogManager.trace(
                event.postback.data == nil
                    ? "Live Chat recovered but there is no data available -> proceed to create a thread"
                    : "Received thread has been closed -> ignore it and proceed to create a thread"
            )
            
            // Make sure that the stored thread is also in correct state
            threads.first?.state = .closed
            
            connectionContext.chatState = .ready
            
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
            return
        }
        
        socketService.connectionContext.contactId = data.contact.id
        
        contactCustomFieldsService?.updateFields(data.contact.customFields, for: data.thread.idOnExternalPlatform)
        customerCustomFieldsService?.updateFields(data.customerCustomFields)
        
        let thread = threads.getThread(with: data.thread.idOnExternalPlatform) ?? {
            let newThread = ChatThread(
                id: data.thread.idOnExternalPlatform,
                state: data.thread.canAddMoreMessages ? .ready : .closed
            )
            
            threads.append(newThread)
            
            return newThread
        }()
        
        thread.updated(from: data)
        
        // Process inactivity popup messages after thread update (they are filtered out during thread update) if it is the last message on the thread
        // Notice it's mapped here as a `first` message but it's actually the last one as messages are sorted descending by `createdAt` date
        if let message = data.messages.first, message.contentType.type == .inactivityPopup, let service = try? provider(for: thread) as? ChatThreadService {
            try service.processInactivityPopup(message)
        }
        
        connectionContext.chatState = .ready

        delegate.onThreadUpdated(thread)
        delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the threadsService is not correctly registered.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func processThreadListFetchedEvent(_ event: GenericEventDTO) async throws {
        LogManager.trace("Processing thread list fetched")
        
        // Store threads that has been created locally but not yet on the BE so they are not overriden with the BE threads
        let additionalThreads = threads.filter { $0.state == .pending }
        threads = event.postback?.threads?.map(ChatThreadMapper.map) ?? []
        threads.append(contentsOf: additionalThreads)
        
        guard !threads.isEmpty else {
            LogManager.info("There are no threads for loading their metadata - setting chat state to `.ready`")
            
            connectionContext.chatState = .ready
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
            delegate.onThreadsUpdated(threads)
            return
        }
        
        let filteredThreads = threads.filter { $0.state != .pending }
        
        if filteredThreads.isEmpty {
            connectionContext.chatState = .ready
            
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
            delegate.onThreadsUpdated(threads)
            
            // It is necessary notify also the only one thread in the array for singlethread and livechat modes
            if let thread = threads.first {
                delegate.onThreadUpdated(thread)
            }
        } else {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for thread in filteredThreads {
                    group.addTask { [weak self] in
                        try await self?.loadInfo(for: thread.id)
                    }
                }
                
                try await group.waitForAll()
            }
        }
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processThreadMetadataLoadedEvent(_ event: ThreadMetadataLoadedEventDTO) throws {
        LogManager.trace("Processing thread metadata loaded")
        
        guard let index = threads.index(of: event.postback.data.lastMessage.threadIdOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }

        if let message = MessageMapper.map(event.postback.data.lastMessage) {
            threads[index].merge(messages: [message])
        }
        
        threads[index].assignedAgent = event.postback.data.ownerAssignee.map(AgentMapper.map)

        if threads[index].state != .closed {
            threads[index].state = .loaded
        }
        
        // There can be more threads and one of them could be locally created so it is necessary to invoke `onThreadsUpdated(_:)`
        // even for thread in `.pending` state.
        if threads.allSatisfy({ $0.state == .pending || $0.state.isLoaded }) {
            connectionContext.chatState = .ready
            
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
            delegate.onThreadsUpdated(threads)
        }
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processMessageReadChangeEvent(_ event: MessageReadByAgentEventDTO) throws {
        LogManager.trace("Processing message read change")
        
        guard let index = threads.index(of: event.data.message.threadIdOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }

        // Don't handle specific messages (Welcome message, Begin liveChat conversation, etc.
        guard let service = try provider(for: threads[index]) as? ChatThreadService, !service.shouldIgnoreMessage(event.data.message) else {
            LogManager.trace("Skip message read change for non-relevant message")
            return
        }
        
        if let message = MessageMapper.map(event.data.message) {
            threads[index].merge(messages: [message])
        }
            
        delegate.onThreadUpdated(threads[index])
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processMessageSeenChangedEvent(_ event: MessageSeenChangedDTO) throws {
        LogManager.trace("Process message seen by customer")
        
        guard let thread = threads.getThread(with: event.message.threadIdOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        // Don't handle specific messages (welcome message, Begin live chat conversation, etc.)
        guard let service = try provider(for: thread) as? ChatThreadService, !service.shouldIgnoreMessage(event.message) else {
            LogManager.trace("Skip message seen change for non-relevant message")
            return
        }
        
        if let message = MessageMapper.map(event.message) {
            thread.merge(messages: [message])
        }
        
        delegate.onThreadUpdated(thread)
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processContactInboxAssigneeChangedEvent(_ event: ContactInboxAssigneeChangedEventDTO) throws {
        LogManager.trace("Processing thread assignee has changed")
        
        if connectionContext.chatMode == .liveChat, threads.getThread(with: event.data.case.threadIdOnExternalPlatform) == nil {
            LogManager.info("Event received for a thread other than the active thread")
            return
        }
        
        guard let thread = threads.getThread(with: event.data.case.threadIdOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        
        let agent = event.data.inboxAssignee.map(AgentMapper.map)
        thread.assignedAgent = agent
        thread.lastAssignedAgent = event.data.previousInboxAssignee.map(AgentMapper.map)
        thread.positionInQueue = nil
        
        // It is not necessary to change thread state based on assignee change event for messaging channel configuration
        if connectionContext.chatMode == .liveChat {
            // If event indicates the thread is closed, update the state
            // But don't change state from closed to anything else
            if event.data.case.status == .closed {
                thread.state = .closed
            } else if thread.state != .closed {
                thread.state = .ready
            }
        }
        
        delegate.onThreadUpdated(thread)
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/invalidData`` if the message content type is not `.inactivityPopup`.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func processMessageCreatedEvent(_ event: MessageCreatedEventDTO) throws {
        LogManager.trace("Processing message created")
        
        guard let thread = threads.getThread(with: event.data.thread.idOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        
        connectionContext.contactId = event.data.case.id
        thread.contactId = event.data.case.id

        if connectionContext.chatMode == .liveChat {
            LogManager.trace("Current channel configuration is live chat - processing additional data")
            
            // Process persisted SetPositionInQueue` if needed
            if persistedSetPositionInQueueEvent?.data.consumerContact == event.data.case.id, let persistedSetPositionInQueueEvent {
                self.persistedSetPositionInQueueEvent = nil
                
                try processSetPositionInQueueEvent(persistedSetPositionInQueueEvent)
            }
            // Process inactivity popup
            if case .inactivityPopup = event.data.message.contentType, let service = try? provider(for: thread) as? ChatThreadService {
                LogManager.trace("Processing inactivity popup message")
                
                try service.processInactivityPopup(event.data.message)
                // Cancel rest of the method processing since Inactivity popup event is not process as regular `MessageCreated` event
                return
            }
        }

        // Don't handle specific messages (Welcome message, Begin liveChat conversation, etc.
        if let service = try provider(for: thread) as? ChatThreadService, service.shouldIgnoreMessage(event.data.message) {
            LogManager.trace("Skipping merging other message created event - it's content is begin live chat conversation or welcome message")
        } else {
            LogManager.trace("Adding message to the thread")
            
            let message = MessageMapper.map(event.data.message)
            
            if let message {
                thread.merge(messages: [message])
            }
            
            // Send information that the message is not supported to an agent
            if case .unknown(let fallbackText) = message?.contentType, thread.state == .ready, let service = try provider(for: thread) as? ChatThreadService {
                Task { [weak service] in
                    do {
                        try await service?.sendUnsupportedMessageTypeAnswer(fallbackText: fallbackText)
                    } catch {
                        error.logError()
                    }
                }
            }
        }
        
        if thread.state != .ready && thread.state != .closed {
            LogManager.trace("Updating thread state to .ready")
            
            thread.state = .ready
        }
        
        delegate.onThreadUpdated(thread)
    }
    
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/missingPreChatCustomFields`` if the server requires to fill-up some contact custom fields before initializing chat thread.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/attachmentError`` if the provided attachment was unable to be sent.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if attachments upload `url` has not been set properly or attachment uploaded data object is missing
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the the outbound message has no ``postback``, empty ``text``, and empty ``attachments``.
    /// - Throws: ``CXoneChatError/noSuchFile`` if an attached file could not be found.
    /// - Throws: ``CXoneChatError/invalidFileSize`` if size of the attachment exceeds the allowed size
    /// - Throws: ``CXoneChatError/invalidFileType`` if type of the attachment is not included in the allowed file MIME type
    /// - Throws: ``CXoneChatError/invalidData`` if the conversion from object instance to data failed
    ///     or when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    /// - Throws: An error if any value throws an error during encoding.
    func processRecoveringThreadFailedError(_ error: Error) async throws {
        if connectionContext.chatMode == .liveChat, connectionContext.channelConfig.settings.isRecoverLiveChatDoesNotFailEnabled {
            LogManager.error("Feature toggle isRecoverLiveChatDoesNotFailEnabled is enabled but recovering thread failed: \( error.localizedDescription)")
            
            throw error
        } else if connectionContext.chatMode != .multithread, let thread = threads.first(where: { $0.state == .pending }) {
            LogManager.info("Trying to recover thread that has been created locally so BE does not know about it. Error: \(error.localizedDescription)")
            
            connectionContext.chatState = .ready
            
            delegate.onThreadUpdated(thread)
        } else if connectionContext.channelConfig.prechatSurvey != nil {
            LogManager.info("Channel Configuration contains pre-chat which has to be filled-in. Notify about ready chat. Error: \(error.localizedDescription)")
            
            // Clean up stale threads before showing pre-chat form
            clearStaleThreadsAfterRecoveryFailure()
            
            connectionContext.chatState = .ready
            
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
        } else {
            LogManager.info("No thread available and no form needs to be filled-in -> automatically create a new one. Error: \(error.localizedDescription)")
            
            // Clean up stale threads before showing pre-chat form
            clearStaleThreadsAfterRecoveryFailure()
            
            try await create()
        }
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processCaseStatusChangedEvent(_ event: CaseStatusChangedEventDTO) throws {
        LogManager.trace("Processing case status changed")
        
        guard let index = threads.index(of: event.data.case.threadIdOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        
        if connectionContext.chatMode == .liveChat, event.data.case.status == .closed {
            threads[index].state = .closed
            threads[index].positionInQueue = nil
        }
        
        delegate.onThreadUpdated(threads[index])
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processSetPositionInQueueEvent(_ event: SetPositionInQueueEventDTO) throws {
        LogManager.trace("Processing setPositionInQueueEvent")

        // Store the event for later processing if threads are not loaded yet
        if let thread = threads.first, thread.contactId == nil {
            self.persistedSetPositionInQueueEvent = event
            return
        }
        
        // Check if the persistend thread is related to the event
        guard let thread = threads.first(where: { $0.contactId == event.data.consumerContact }), let index = threads.index(of: thread.id) else {
            throw CXoneChatError.invalidThread
        }

        threads[index].positionInQueue = event.data.positionInQueue

        delegate.onThreadUpdated(threads[index])
    }
    
    func processAgentTypingEvent(_ event: AgentTypingEventDTO) {
        let isTyping = event.eventType == .senderTypingStarted

        guard let agent = event.data.user else {
            LogManager.info("Received typing event for unassigned agent")
            return
        }
        
        LogManager.trace("Processing agent typing did \(isTyping ? "started" : "ended")")
        
        guard let thread = threads.first(where: { $0.id == event.data.thread.idOnExternalPlatform }) else {
            LogManager.warning("Agent typing in unknown thread")
            return
        }
        
        delegate.onAgentTyping(isTyping, agent: AgentMapper.map(agent), threadId: thread.id)
    }
}

// MARK: - Private methods

private extension ChatThreadListService {
    
    /// Clears stale threads and cached data after thread recovery failure.
    ///
    /// When the server indicates a thread no longer exists (RecoveringThreadFailed or RecoveringLivechatFailed error),
    /// we need to clean up any local references to that thread before proceeding with
    /// new chat creation or showing pre-chat forms.
    func clearStaleThreadsAfterRecoveryFailure() {
        // Clear cached thread ID for single-thread and LiveChat modes
        // Do this FIRST, regardless of threads array state
        if connectionContext.chatMode != .multithread {
            UserDefaultsService.shared.remove(.cachedThreadIdOnExternalPlatform)
        }
        
        guard !threads.isEmpty else {
            LogManager.info("No threads to clear, but cached thread ID was removed")
            return
        }
        
        LogManager.info("Clearing \(threads.count) stale thread(s) that failed recovery")
        
        threads.removeAll()
        threadProviders.removeAll()
    }
    
    func allPrechatCustomFieldsFilled(for threadId: UUID) -> Bool {
        guard let prechatSurveyCustomFields = connectionContext.channelConfig.prechatSurvey?.customFields else {
            return true
        }
        
        let customFields = customFields.get(for: threadId)
        
        let preChatIdents = prechatSurveyCustomFields
            .compactMap { entity -> String? in
                guard entity.isRequired else {
                    return nil
                }

                switch entity.type {
                case .textField(let entity):
                    return entity.ident
                case .selector(let entity):
                    return entity.ident
                case .hierarchical(let entity):
                    return entity.ident
                }
            }
        let customFieldsIdents = customFields
            .filter { !$0.value.isEmpty }
            .map(\.key)
        
        return preChatIdents.difference(from: customFieldsIdents).isEmpty
    }
}

// MARK: - Helpers

extension Array where Element: Hashable {
    
    func difference(from other: [Element]) -> [Element] {
        self.filter { !other.contains($0) }
    }
}
