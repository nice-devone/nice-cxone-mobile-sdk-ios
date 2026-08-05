//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//
// swiftlint:disable file_length

import CXoneGuideUtility
import Foundation

final class ChatThreadListService: Sendable {
    
    // MARK: - Properties
    
    let socketService: SocketService
    let eventsService: EventsService
    let customerCustomFields: CustomerCustomFieldsProvider
    let welcomeMessageManager: WelcomeMessageManager
    let broadcaster: EventBroadcaster

    var threadProviders: [ChatThreadService] {
        get { _threadProviders.content }
        set {
            _threadProviders.mutate { content in
                content = newValue
            }
        }
    }
    var threads: [ChatThread] {
        threadProviders.map(\.chatThread)
    }
    var persistedSetPositionInQueueEvent: SetPositionInQueueEventDTO? {
        get { connectionContext.persistedSetPositionInQueueEvent }
        set { connectionContext.persistedSetPositionInQueueEvent = newValue }
    }

    private let _threadProviders = SafeAccessContainer<[ChatThreadService]>([])

    private var connectionContext: ConnectionContext {
        socketService.connectionContext
    }
    private var contactCustomFieldsService: ContactCustomFieldsService? {
        customFields as? ContactCustomFieldsService
    }
    private var customerCustomFieldsService: CustomerCustomFieldsService? {
        customerCustomFields as? CustomerCustomFieldsService
    }
    private var userDefaultsService: UserDefaultsService {
        connectionContext.userDefaultsService
    }

    // MARK: - Protocol Properties

    let customFields: ContactCustomFieldsProvider
    
    var eventBroadcast: EventBroadcast { socketService.eventBroadcast }
    var listenerTasks: [Task<Void, Never>] {
        get { socketService.listenerTasks }
        set { socketService.listenerTasks = newValue }
    }

    // MARK: - Init

    init(
        contactCustomFields: ContactCustomFieldsProvider,
        customerCustomFields: CustomerCustomFieldsProvider,
        socketService: SocketService,
        eventsService: EventsService,
        welcomeMessageManager: WelcomeMessageManager,
        broadcaster: EventBroadcaster
    ) {
        self.customFields = contactCustomFields
        self.customerCustomFields = customerCustomFields
        self.socketService = socketService
        self.eventsService = eventsService
        self.welcomeMessageManager = welcomeMessageManager
        self.broadcaster = broadcaster
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
    @MainActor
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
        
        let thread = ChatThread(id: LowercaseUUID().uuidString, state: .pending)
        
        if !customFields.isEmpty {
            let mappedCustomFields = customFields.map { CustomFieldDTO(ident: $0.key, value: $0.value, updatedAt: Date()) }
            
            contactCustomFieldsService?.updateFields(mappedCustomFields, for: thread.id)
        }
        
        if !allPrechatCustomFieldsFilled(for: thread.id) {
            throw CXoneChatError.missingPreChatCustomFields
        }

        let service = createAndStoreProviderIfNeeded(for: thread)

        if let message = userDefaultsService.get(String.self, for: .welcomeMessage) {
            service.chatThread = thread.merged(with: [try service.getParsedWelcomeMessage(message)])
            try service.handleWelcomeMessage(message)
        }
        
        connectionContext.chatState = .ready
        
        if connectionContext.chatMode != .liveChat {
            broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
        }

        // Thread has been successfully created, store its ID for faster recovering
        if connectionContext.chatMode != .multithread {
            userDefaultsService.set(thread.id, for: .cachedThreadIdOnExternalPlatform)
        }

        if connectionContext.chatMode == .liveChat {
            try await service.sendBeginLiveChatConversation()
        }

        // Broadcast the canonical stored state, not the parameter — service.chatThread may
        // already have been mutated by the welcome-message merge above and the parameter
        // would carry a stale snapshot.
        broadcaster.send(.threadUpdated(service.chatThread))

        return service
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func load(with threadId: String?) async throws {
        try socketService.checkForConnection()

        try await recoverThread(threadId: threadId)
    }
    
    /// Convenience wrapper around the `provider(for threadId: String)` overload that
    /// forwards `thread.id`.
    ///
    /// - Parameter thread: The thread whose provider is being requested.
    /// - Throws: ``CXoneChatError/invalidThread`` if no provider exists for `thread.id`.
    func provider(for thread: ChatThread) throws -> any ChatThreadProvider {
        try provider(for: thread.id)
    }

    /// - Parameter threadId: The id of the thread whose provider is being requested.
    /// - Throws: ``CXoneChatError/invalidThread`` if no provider matches `threadId` in the current thread list.
    func provider(for threadId: String) throws -> any ChatThreadProvider {
        guard let provider = threadProviders.first(where: { $0.chatThread.id == threadId }) else {
            throw CXoneChatError.invalidThread
        }

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
            let cachedThreadId: String? = userDefaultsService.get(String.self, for: .cachedThreadIdOnExternalPlatform)

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

        let response = try await eventBroadcast.waitFor(
            GenericEventDTO.self,
            eventType: .threadListFetched,
            origin: event,
            socketService: socketService,
            eventsService: eventsService
        )
        
        try await processThreadListFetchedEvent(response)
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the threadsService is not correctly registered.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func recoverThread(threadId: String?) async throws {
        LogManager.trace("Loading the a thread for the customer and gets messages")

        let validChatThreadStates: [ChatThreadState] = connectionContext.chatMode == .liveChat ? [.pending] : [.pending, .closed]

        if let threadId, let thread = threadProviders.getThread(with: threadId), validChatThreadStates.contains(thread.state) {
            LogManager.info("Thread has been created locally or is archived -> no need to recover it")

            connectionContext.chatState = .ready

            broadcaster.send(.threadUpdated(thread))
            broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
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
            let response = try await eventBroadcast.waitFor(
                ThreadRecoveredEventDTO.self,
                eventType: .threadRecovered,
                origin: event,
                socketService: socketService,
                eventsService: eventsService
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
            let response = try await eventBroadcast.waitFor(
                LiveChatRecoveredDTO.self,
                eventType: .liveChatRecovered,
                origin: event,
                socketService: socketService,
                eventsService: eventsService
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
    func loadInfo(for threadId: String) async throws {
        guard let thread = threadProviders.getThread(with: threadId) else {
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

        let response = try await eventBroadcast.waitFor(
            ThreadMetadataLoadedEventDTO.self,
            eventType: .threadMetadataLoaded,
            origin: event,
            socketService: socketService,
            eventsService: eventsService
        )
        
        try processThreadMetadataLoadedEvent(response)
    }
}

// MARK: - EventReceiver

extension ChatThreadListService: EventReceiver {
    
    func addListeners() {
        addListener(for: .senderTypingStarted) { [weak self] event in
            self?.processAgentTypingEvent(event)
        }
        addListener(for: .senderTypingEnded) { [weak self] event in
            self?.processAgentTypingEvent(event)
        }
        addListener { [weak self] event in
            try self?.processMessageReadChangeEvent(event)
        }
        addListener { [weak self] event in
            try self?.processMessageSeenChangedEvent(event)
        }
        addListener { [weak self] event in
            try self?.processContactInboxAssigneeChangedEvent(event)
        }
        addListener { [weak self] event in
            try self?.processCaseStatusChangedEvent(event)
        }
        addListener { [weak self] event in
            try self?.processSetPositionInQueueEvent(event)
        }
        addListener { [weak self] event in
            try self?.processMessageCreatedEvent(event)
        }
    }

    func clearStoredData() {
        LogManager.info("Removing stored data for chat threads service")

        _threadProviders.mutate { content in
            content = []
        }

        contactCustomFieldsService?.clearStoredData()
    }
}

// MARK: - Socket Methods

extension ChatThreadListService {
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processThreadRecoveredEvent(_ event: ThreadRecoveredEventDTO) throws {
        LogManager.trace("Processing thread recovered with identifier - \(event.postback.data.thread.idOnExternalPlatform)")
        
        socketService.connectionContext.contactId = event.postback.data.consumerContact.id
        
        contactCustomFieldsService?.updateFields(
            event.postback.data.consumerContact.customFields,
            for: event.postback.data.thread.idOnExternalPlatform
        )
        customerCustomFieldsService?.updateFields(event.postback.data.customerCustomFields)
        
        let data = event.postback.data
        let baseThread = threadProviders.getThread(with: data.thread.idOnExternalPlatform) ?? ChatThread(
            id: data.thread.idOnExternalPlatform,
            state: data.thread.canAddMoreMessages ? .ready : .closed
        )
        let finalThread = baseThread.merging(from: data)
        let service = createAndStoreProviderIfNeeded(for: baseThread)
        service.chatThread = finalThread

        connectionContext.chatState = .ready

        broadcaster.send(.threadUpdated(finalThread))
        broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processLiveChatRecoveredEvent(_ event: LiveChatRecoveredDTO) throws {
        LogManager.trace("Processing thread recovered with identifier - \(String(describing: event.postback.data?.thread.idOnExternalPlatform))")
        
        guard let data = event.postback.data, data.contact.status != .closed else {
            LogManager.trace(
                event.postback.data == nil
                    ? "Live Chat recovered but there is no data available -> proceed to create a thread"
                    : "Received thread has been closed -> ignore it and proceed to create a thread"
            )

            closeStaleLivechatThread(matching: event.postback.data?.thread.idOnExternalPlatform)

            connectionContext.chatState = .ready

            broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
            return
        }

        socketService.connectionContext.contactId = data.contact.id
        
        contactCustomFieldsService?.updateFields(data.contact.customFields, for: data.thread.idOnExternalPlatform)
        customerCustomFieldsService?.updateFields(data.customerCustomFields)

        let baseThread = threadProviders.getThread(with: data.thread.idOnExternalPlatform) ?? ChatThread(
            id: data.thread.idOnExternalPlatform,
            state: data.thread.canAddMoreMessages ? .ready : .closed
        )
        let finalThread = baseThread.merging(from: data)
        let service = createAndStoreProviderIfNeeded(for: baseThread)
        service.chatThread = finalThread

        // Process inactivity popup messages after thread update (they are filtered out during thread update) if it is the last message on the thread
        // Notice it's mapped here as a `first` message but it's actually the last one as messages are sorted descending by `createdAt` date
        if let message = data.messages.first, message.contentType.type == .inactivityPopup {
            try service.processInactivityPopup(message)
        }

        connectionContext.chatState = .ready

        broadcaster.send(.threadUpdated(finalThread))
        broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the threadsService is not correctly registered.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func processThreadListFetchedEvent(_ event: GenericEventDTO) async throws {
        LogManager.trace("Processing thread list fetched")
        
        // Store threads that have been created locally but not yet on the BE so they are not overridden with the BE threads
        let beThreads = event.postback?.threads?.map(ChatThreadMapper.map) ?? []
        _threadProviders.mutate { providers in
            let beIds = Set(beThreads.map(\.id))
            let beProviders = mapToProviders(beThreads: beThreads, existing: providers)
            // Keep locally-created `.pending` providers that the BE doesn't know about
            // yet; drop any pending provider whose id collides with a BE thread (it's
            // already in `beProviders`) so the final list has no duplicates.
            let pendingProviders = providers.filter {
                $0.chatThread.state == .pending && !beIds.contains($0.chatThread.id)
            }
            providers = beProviders + pendingProviders
        }

        // Single snapshot of the post-mutate state, reused for the empty-check,
        // the broadcasts below, and the `filteredThreads` filter — avoids re-walking
        // `threadProviders` three times in succession.
        let threads = threadProviders.map(\.chatThread)

        guard !threads.isEmpty else {
            LogManager.info("There are no threads for loading their metadata - setting chat state to `.ready`")

            connectionContext.chatState = .ready
            broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
            broadcaster.send(.threadsUpdated(threads))
            return
        }

        let filteredThreads = threads.filter { $0.state != .pending }

        if filteredThreads.isEmpty {
            connectionContext.chatState = .ready

            broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
            broadcaster.send(.threadsUpdated(threads))

            // It is necessary notify also the only one thread in the array for singlethread and livechat modes
            if let thread = threads.first {
                broadcaster.send(.threadUpdated(thread))
            }
        } else {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for thread in filteredThreads {
                    let threadId = thread.id

                    group.addTask { @Sendable [weak self] in
                        try await self?.loadInfo(for: threadId)
                    }
                }
                
                try await group.waitForAll()
            }
        }
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processThreadMetadataLoadedEvent(_ event: ThreadMetadataLoadedEventDTO) throws {
        LogManager.trace("Processing thread metadata loaded")
        
        let message = MessageMapper.map(event.postback.data.lastMessage)

        guard let service = try provider(for: event.postback.data.lastMessage.threadIdOnExternalPlatform) as? ChatThreadService else {
            throw CXoneChatError.invalidThread
        }

        var updated = service.chatThread
        if let message {
            updated = updated.merged(with: [message])
        }
        updated = updated.copy(
            state: updated.state != .closed ? .loaded : updated.state,
            // Intended: the metadata-loaded event carries only `ownerAssignee`, which is mapped into
            // `assignedAgent` here. This behavior is long-standing (in place for several years) and is
            // deliberately left as-is; do not change it to populate `ownerAssignee` instead.
            assignedAgent: event.postback.data.ownerAssignee.map(AgentMapper.map)
        )
        service.chatThread = updated

        let allThreads = threadProviders.map(\.chatThread)
        let allLoaded = allThreads.allSatisfy { $0.state == .pending || $0.state.isLoaded }

        // There can be more threads and one of them could be locally created so it is necessary to invoke `onThreadsUpdated(_:)`
        // even for thread in `.pending` state.
        if allLoaded {
            connectionContext.chatState = .ready

            broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
            broadcaster.send(.threadsUpdated(allThreads))
        }
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processMessageReadChangeEvent(_ event: MessageReadByAgentEventDTO) throws {
        LogManager.trace("Processing message read change")

        let threadId = event.data.message.threadIdOnExternalPlatform

        // Don't handle specific messages (Welcome message, Begin liveChat conversation, etc.
        guard let service = try provider(for: threadId) as? ChatThreadService, !service.shouldIgnoreMessage(event.data.message) else {
            LogManager.trace("Skip message read change for non-relevant message")
            return
        }

        if let mapped = MessageMapper.map(event.data.message) {
            service.chatThread = service.chatThread.merged(with: [mapped])
        }

        broadcaster.send(.threadUpdated(service.chatThread))
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processMessageSeenChangedEvent(_ event: MessageSeenChangedDTO) throws {
        LogManager.trace("Process message seen by customer")

        let threadId = event.message.threadIdOnExternalPlatform

        // Don't handle specific messages (welcome message, Begin live chat conversation, etc.)
        guard let service = try provider(for: threadId) as? ChatThreadService, !service.shouldIgnoreMessage(event.message) else {
            LogManager.trace("Skip message seen change for non-relevant message")
            return
        }

        if let mapped = MessageMapper.map(event.message) {
            service.chatThread = service.chatThread.merged(with: [mapped])
        }

        broadcaster.send(.threadUpdated(service.chatThread))
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processContactInboxAssigneeChangedEvent(_ event: ContactInboxAssigneeChangedEventDTO) throws {
        LogManager.trace("Processing thread assignee has changed")
        
        if connectionContext.chatMode == .liveChat, threadProviders.getThread(with: event.data.case.threadIdOnExternalPlatform) == nil {
            LogManager.info("Event received for a thread other than the active thread")
            return
        }

        guard let service = threadProviders.first(where: { $0.chatThread.id == event.data.case.threadIdOnExternalPlatform }) else {
            throw CXoneChatError.invalidThread
        }

        let thread = service.chatThread
        let agent = event.data.inboxAssignee.map(AgentMapper.map)
        let previousAgent = event.data.previousInboxAssignee.map(AgentMapper.map)

        // It is not necessary to change thread state based on assignee change event for messaging channel configuration
        let newState: ChatThreadState? = connectionContext.chatMode == .liveChat ? {
            // If event indicates the thread is closed, update the state
            // But don't change state from closed to anything else
            if event.data.case.status == .closed {
                return .closed
            } else if thread.state != .closed {
                return .ready
            }
            return nil
        }() : nil

        let updated = ChatThread(
            id: thread.id,
            state: newState ?? thread.state,
            name: thread.name,
            messages: thread.messages,
            assignedAgent: agent,
            lastAssignedAgent: previousAgent,
            ownerAssignee: thread.ownerAssignee,
            contactId: thread.contactId,
            scrollToken: thread.scrollToken,
            positionInQueue: nil
        )
        service.chatThread = updated

        broadcaster.send(.threadUpdated(updated))
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
        
        guard let service = threadProviders.first(where: { $0.chatThread.id == event.data.thread.idOnExternalPlatform }) else {
            throw CXoneChatError.invalidThread
        }

        connectionContext.contactId = event.data.case.id
        service.chatThread = service.chatThread.merging(contactId: event.data.case.id)

        // Promote the thread to .ready *before* any nested handler runs. The persisted
        // SetPositionInQueueEvent broadcast below reads the live storage state at the
        // moment it broadcasts — if we leave the thread at .pending here, that broadcast
        // would carry state=.pending and the livechat loading overlay would be shown
        // (and then stick, because no later broadcast brings the state back down).
        if [.ready, .closed].contains(service.chatThread.state) == false {
            service.chatThread = service.chatThread.copy(state: .ready)
        }

        if connectionContext.chatMode == .liveChat {
            LogManager.trace("Current channel configuration is live chat - processing additional data")

            // Process persisted SetPositionInQueue` if needed
            if let persistedSetPositionInQueueEvent, persistedSetPositionInQueueEvent.data.consumerContact == event.data.case.id {
                self.persistedSetPositionInQueueEvent = nil

                try processSetPositionInQueueEvent(persistedSetPositionInQueueEvent)
            }
            // Process inactivity popup
            if case .inactivityPopup = event.data.message.contentType {
                LogManager.trace("Processing inactivity popup message")

                try service.processInactivityPopup(event.data.message)
                // Cancel rest of the method processing since Inactivity popup event is not process as regular `MessageCreated` event
                return
            }
        }

        // Don't handle specific messages (Welcome message, Begin liveChat conversation, etc.
        if service.shouldIgnoreMessage(event.data.message) {
            LogManager.trace("Skipping merging other message created event - it's content is begin live chat conversation or welcome message")
        } else {
            LogManager.trace("Adding message to the thread")

            let message = MessageMapper.map(event.data.message)

            if let message {
                service.chatThread = service.chatThread.merged(with: [message])
            }

            // Send information that the message is not supported to an agent
            if case .unknown(let fallbackText) = message?.contentType, service.chatThread.state == .ready {
                Task { [weak service] in
                    do {
                        try await service?.sendUnsupportedMessageTypeAnswer(fallbackText: fallbackText)
                    } catch {
                        error.logError()
                    }
                }
            }
        }

        broadcaster.send(.threadUpdated(service.chatThread))
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
        } else if connectionContext.chatMode != .multithread, let service = threadProviders.first(where: { $0.chatThread.state == .pending }) {
            LogManager.info("Trying to recover thread that has been created locally so BE does not know about it. Error: \(error.localizedDescription)")
            
            connectionContext.chatState = .ready

            broadcaster.send(.threadUpdated(service.chatThread))
        } else if connectionContext.channelConfig.prechatSurvey != nil {
            LogManager.info("Channel Configuration contains pre-chat which has to be filled-in. Notify about ready chat. Error: \(error.localizedDescription)")

            // Clean up stale threads before showing pre-chat form
            clearStaleThreadsAfterRecoveryFailure()

            connectionContext.chatState = .ready
            broadcaster.send(.chatUpdated(state: connectionContext.chatState, mode: connectionContext.chatMode))
        } else {
            LogManager.info("No thread available and no form needs to be filled-in -> automatically create a new one. Error: \(error.localizedDescription)")

            // Clean up stale threads before creating new thread
            clearStaleThreadsAfterRecoveryFailure()

            try await create()
        }
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processCaseStatusChangedEvent(_ event: CaseStatusChangedEventDTO) throws {
        LogManager.trace("Processing case status changed")
        
        let threadId = event.data.case.threadIdOnExternalPlatform
        let shouldClose = connectionContext.chatMode == .liveChat && event.data.case.status == .closed

        guard let service = threadProviders.first(where: { $0.chatThread.id == threadId }) else {
            throw CXoneChatError.invalidThread
        }

        if shouldClose {
            service.chatThread = service.chatThread.copy(state: .closed, positionInQueue: nil)
        }

        broadcaster.send(.threadUpdated(service.chatThread))
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processSetPositionInQueueEvent(_ event: SetPositionInQueueEventDTO) throws {
        LogManager.trace("Processing setPositionInQueueEvent")

        // Store the event for later processing if threads are not loaded yet
        if let thread = threadProviders.first?.chatThread, thread.contactId == nil {
            self.persistedSetPositionInQueueEvent = event
            return
        }
        // Check if the persistend thread is related to the event
        guard let service = threadProviders.first(where: { $0.chatThread.contactId == event.data.consumerContact }) else {
            throw CXoneChatError.invalidThread
        }

        service.chatThread = service.chatThread.copy(positionInQueue: event.data.positionInQueue)

        broadcaster.send(.threadUpdated(service.chatThread))
    }

    func processAgentTypingEvent(_ event: AgentTypingEventDTO) {
        let isTyping = event.eventType == .senderTypingStarted

        guard let agent = event.data.user else {
            LogManager.info("Received typing event for unassigned agent")
            return
        }
        
        LogManager.trace("Processing agent typing did \(isTyping ? "started" : "ended")")
        
        guard threadProviders.getThread(with: event.data.thread.idOnExternalPlatform) != nil else {
            LogManager.warning("Agent is typing in an unknown thread")
            return
        }
        
        broadcaster.send(.agentTyping(isTyping: isTyping, agent: AgentMapper.map(agent), threadId: event.data.thread.idOnExternalPlatform))
    }
}

// MARK: - Private methods

private extension ChatThreadListService {
    
    func allPrechatCustomFieldsFilled(for threadId: String) -> Bool {
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
    
    /// Clears stale threads and cached data after thread recovery failure.
    ///
    /// When the server indicates a thread no longer exists (RecoveringThreadFailed or RecoveringLivechatFailed error),
    /// we need to clean up any local references to that thread before proceeding with
    /// new chat creation or showing pre-chat forms.
    func clearStaleThreadsAfterRecoveryFailure() {
        // Clear cached thread ID for single-thread and LiveChat modes
        // Do this FIRST, regardless of threads array state
        if connectionContext.chatMode != .multithread {
            userDefaultsService.remove(.cachedThreadIdOnExternalPlatform)
        }

        guard !threads.isEmpty else {
            LogManager.info("No threads to clear, but cached thread ID was removed")
            return
        }

        LogManager.info("Clearing \(threadProviders.count) stale thread(s) that failed recovery")

        _threadProviders.mutate { content in
            content = []
        }
    }

    /// Maps backend thread snapshots to `ChatThreadService` instances, reusing any
    /// `existing` provider whose id already matches (the snapshot is refreshed in place)
    /// and constructing a new `ChatThreadService` only for ids that are not yet in
    /// storage. Preserving provider identity matters because callers may hold references
    /// returned by `provider(for:)` — replacing the instance would detach those
    /// references from the canonical store and silently lose any in-flight work on them.
    ///
    /// `existing` is pre-indexed into a `[String: ChatThreadService]` so the per-thread
    /// lookup is O(1) and the overall mapping stays O(n) regardless of thread count.
    /// The dictionary is built with `uniquingKeysWith` (last-write-wins) instead of
    /// `uniqueKeysWithValues` so a duplicate id in `existing` is overwritten silently
    /// rather than trapping — duplicates shouldn't occur, but a hard crash here is
    /// unkind.
    func mapToProviders(beThreads: [ChatThread], existing: [ChatThreadService]) -> [ChatThreadService] {
        let existingById = Dictionary(existing.map { ($0.chatThread.id, $0) }) { _, latest in latest }
        
        return beThreads.map { thread in
            if let existing = existingById[thread.id] {
                existing.chatThread = thread
                return existing
            }

            return ChatThreadService(
                chatThread: thread,
                contactFieldsProvider: customFields,
                customerFieldsProvider: customerCustomFields,
                socketService: socketService,
                eventsService: eventsService,
                welcomeMessageManager: welcomeMessageManager,
                broadcaster: broadcaster
            )
        }
    }

    /// Marks the active livechat thread closed during a `LiveChatRecovered` event where
    /// the BE either returned no data or reported the contact already closed.
    ///
    /// When `threadId` is supplied **and** matches a stored provider we close that
    /// specific provider (defensive id match against the BE payload). In every other
    /// case — `threadId == nil`, or `threadId != nil` but unmatched — we fall back to
    /// the first provider in storage. Livechat is singlethread so the fallback target
    /// is unambiguous.
    func closeStaleLivechatThread(matching threadId: String?) {
        let toClose = threadId.flatMap { id in
            threadProviders.first { $0.chatThread.id == id }
        } ?? threadProviders.first
        
        guard let toClose else {
            return
        }
        
        toClose.chatThread = toClose.chatThread.copy(state: .closed)
    }

    /// Returns the `ChatThreadService` for `thread.id`, creating and storing a new one if
    /// no provider exists yet. The concrete return type (rather than `any
    /// ChatThreadProvider`) reflects the single-source-of-truth design: `_threadProviders`
    /// is `[ChatThreadService]` and every code path here constructs / returns that exact
    /// type, so callers don't need to downcast.
    func createAndStoreProviderIfNeeded(for thread: ChatThread) -> ChatThreadService {
        _threadProviders.mutate { providers -> ChatThreadService in
            // SafeAccessContainer's underlying lock is non-recursive: nothing inside this
            // closure may read or write _threadProviders (even transitively) or the lock
            // will trap on re-entry. The existence check runs against `providers` (the local
            // inout snapshot), never via `self.threadProviders`.
            if let existing = providers.first(where: { $0.chatThread.id == thread.id }) {
                return existing
            }

            let provider = ChatThreadService(
                chatThread: thread,
                contactFieldsProvider: customFields,
                customerFieldsProvider: customerCustomFields,
                socketService: socketService,
                eventsService: eventsService,
                welcomeMessageManager: welcomeMessageManager,
                broadcaster: broadcaster
            )

            providers.append(provider)

            return provider
        }
    }
}

// MARK: - Helpers

extension Array where Element: Hashable {
    
    func difference(from other: [Element]) -> [Element] {
        self.filter { !other.contains($0) }
    }
}
