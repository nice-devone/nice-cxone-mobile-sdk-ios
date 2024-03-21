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

import Foundation

class ChatThreadsService: ChatThreadsProvider {
    
    // MARK: - Properties
    
    private var connectionContext: ConnectionContext {
        get { socketService.connectionContext }
        set { socketService.connectionContext = newValue }
    }
    
    let socketService: SocketService
    let eventsService: EventsService
    let customerFields: CustomerCustomFieldsService?
    
    var threads = [ChatThread]()
    
    weak var delegate: CXoneChatDelegate?
    
    // MARK: - Protocol Properties
    
    var messages: MessagesProvider
    var customFields: ContactCustomFieldsProvider
    
    // MARK: - Init
    
    init(
        messagesProvider: MessagesProvider,
        contactFields: ContactCustomFieldsProvider,
        customerFields: CustomerCustomFieldsProvider,
        socketService: SocketService,
        eventsService: EventsService
    ) {
        self.messages = messagesProvider
        self.customFields = contactFields
        self.customerFields = customerFields as? CustomerCustomFieldsService
        self.socketService = socketService
        self.eventsService = eventsService
    }
    
    // MARK: - Implementation
    
    var preChatSurvey: PreChatSurvey? {
        guard let prechat = connectionContext.channelConfig.prechatSurvey else {
            return nil
        }
        
        let fields = prechat.customFields.filter { field in
            connectionContext.channelConfig.contactCustomFieldDefinitions.contains { $0.ident == field.type.ident }
        }
        
        guard !fields.isEmpty else {
            LogManager.info("Unable to get case custom fields for Pre-chat survey because ")
            return nil
        }
        
        return PreChatSurvey(name: prechat.name, customFields: fields.map(PreChatSurveyCustomFieldMapper.map))
    }
    
    func get() -> [ChatThread] {
        threads
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/missingPreChatCustomFields`` if the server requires to fill-up some contact custom fields before initializing chat thread.
    @discardableResult
    func create() throws -> UUID {
        try create(with: [:])
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/missingPreChatCustomFields`` if the server requires to fill-up some contact custom fields before initializing chat thread.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    @discardableResult
    func create(with customFields: [String: String]) throws -> UUID {
        LogManager.trace("Creating a new thread")

        try socketService.checkForConnection()

        guard connectionContext.chatMode == .multithread || threads.isEmpty else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        
        var thread = ChatThread(id: UUID(), state: .pending)
        
        if !customFields.isEmpty, let service = self.customFields as? ContactCustomFieldsService {
            let mappedCustomFields = customFields.map { CustomFieldDTO(ident: $0.key, value: $0.value, updatedAt: Date()) }
            
            service.updateFields(mappedCustomFields, for: thread.id)
        }
        
        guard allCustomFieldsFilled(customFields) else {
            throw CXoneChatError.missingPreChatCustomFields
        }
        
        if let welcomeMessage = UserDefaultsService.shared.get(String.self, for: .welcomeMessage), let service = messages as? MessagesService {
            try thread.insert(message: service.getParsedWelcomeMessage(welcomeMessage, for: thread))
        }
        
        threads.append(thread)

        // Thread has been successfully created, store its ID for faster recovering
        if connectionContext.chatMode != .multithread {
            UserDefaultsService.shared.set(thread.id, for: .cachedThreadIdOnExternalPlatform)
        }

        delegate?.onThreadUpdate()
        delegate?.onThreadUpdated(thread)

        return thread.id
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func load() throws {
        try socketService.checkForConnection()

        try fetchThreadList()
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func load(with threadId: UUID?) throws {
        try socketService.checkForConnection()

        try recoverThread(threadId: threadId)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func loadInfo(for thread: ChatThread) throws {
        try socketService.checkForConnection()

        try loadInfo(for: thread.id)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func updateName(_ name: String, for id: UUID) throws {
        LogManager.trace("Updating the name for a thread")

        try socketService.checkForConnection()

        guard connectionContext.channelConfig.settings.hasMultipleThreadsPerEndUser else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        guard let index = threads.index(of: id) else {
            throw CXoneChatError.invalidThread
        }
        
        threads[index].name = name
        
        if threads[index].state == .ready {
            let data = try eventsService.create(
                .updateThread,
                with: .updateThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: id, threadName: name)))
            )
            
            socketService.send(message: data.utf8string)
        } else {
            LogManager.info("Thread does not contain any messages. Skipping message sending")
        }

        delegate?.onThreadUpdate()
        delegate?.onThreadUpdated(threads[index])
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func archive(_ thread: ChatThread) throws {
        LogManager.trace("Archiving thread")
        
        try socketService.checkForConnection()
        
        guard connectionContext.channelConfig.settings.hasMultipleThreadsPerEndUser else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        guard let index = threads.index(of: thread.id) else {
            throw CXoneChatError.invalidThread
        }
        
        threads[index].state = .closed
        
        if thread.messages.first?.userStatistics != nil {
            let data = try eventsService.create(
                .archiveThread,
                with: .archiveThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: thread.id, threadName: thread.name)))
            )
            
            socketService.send(message: data.utf8string)
        } else {
            delegate?.onThreadArchive()
        }
        
        delegate?.onThreadUpdated(threads[index])
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func markRead(_ thread: ChatThread) throws {
        LogManager.trace("Marking thread as read")
        
        try socketService.checkForConnection()
        
        guard thread.state == .ready else {
            LogManager.info("Trying to mark read thread that has been created locally and it not yet exists in the BE")
            return
        }
        
        let data = try eventsService.create(
            .messageSeenByCustomer,
            with: .messageSeenByCustomer(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: thread.id, threadName: thread.name)))
        )
        
        socketService.send(message: data.utf8string)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func reportTypingStart(_ didStart: Bool, in thread: ChatThread) throws {
        LogManager.trace("Reporting user start typing")

        try socketService.checkForConnection()

        let data = try eventsService.create(
            didStart ? .senderTypingStarted : .senderTypingEnded,
            with: .customerTypingData(CustomerTypingEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: thread.id, threadName: thread.name)))
        )
        
        socketService.send(message: data.utf8string)
    }
}

// MARK: - Internal Methods

extension ChatThreadsService {
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func handleForCurrentChatMode(_ mode: ChatMode) throws {
        switch mode {
        case .singlethread:
            let cachedThreadId: UUID? = UserDefaultsService.shared.get(UUID.self, for: .cachedThreadIdOnExternalPlatform)
            
            try recoverThread(threadId: cachedThreadId)
        case .multithread:
            try fetchThreadList()
        case .livechat:
            LogManager.info("Recover of \(mode) is not implemented yet")
        }
    }
    
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func fetchThreadList() throws {
        guard connectionContext.chatMode == .multithread || threads.isEmpty else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        
        LogManager.trace("Loading all of the threads for the current customer")
        
        let data = try eventsService.create(.fetchThreadList)
        
        socketService.send(message: data.utf8string)
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func recoverThread(threadId: UUID?) throws {
        LogManager.trace("Loading the a thread for the customer and gets messages")
        
        if let threadId, let thread = threads.getThread(with: threadId), thread.state == .pending {
            // Thread has been created locally -> no need to recover it
            delegate?.onThreadUpdated(thread)
            return
        }
        
        let eventData = threadId.map { threadId -> EventDataType in
            .loadThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: threadId, threadName: nil)))
        }
        let data = try eventsService.create(.recoverThread, with: eventData)
        
        socketService.send(message: data.utf8string)
    }
    
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func loadInfo(for threadId: UUID) throws {
        LogManager.trace("Loads information about the thread")
        
        let data = try eventsService.create(
            .loadThreadMetadata,
            with: .loadThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: threadId, threadName: nil)))
        )
        
        socketService.send(message: data.utf8string)
    }
}

// MARK: - Socket Methods

extension ChatThreadsService {
    
    func processThreadRecoveredEvent(_ event: ThreadRecoveredEventDTO) throws {
        LogManager.trace("Processing thread recovered with UUID - \(event.postback.data.thread.idOnExternalPlatform)")
        
        connectionContext.chatState = .ready
        
        socketService.connectionContext.contactId = event.postback.data.consumerContact.id
        
        (customFields as? ContactCustomFieldsService)?.updateFields(
            event.postback.data.consumerContact.customFields,
            for: event.postback.data.thread.idOnExternalPlatform
        )
        customerFields?.updateFields(event.postback.data.customerContactFields)
        
        if !threads.contains(where: { $0.id == event.postback.data.thread.idOnExternalPlatform }) {
            threads.append(ChatThread(id: event.postback.data.thread.idOnExternalPlatform, state: .ready))
        }
        
        let thread = try threads.updateAndGetRecoveredThread(event)
        
        delegate?.onThreadLoad(thread)
        delegate?.onThreadUpdated(thread)
    }
    
    func processThreadListFetchedEvent(_ event: GenericEventDTO) throws {
        LogManager.trace("Processing thread list fetched")
        
        threads = event.postback?.threads?.map(ChatThreadMapper.map) ?? []
        
        delegate?.onThreadsLoad(threads)
        
        if threads.isEmpty {
            connectionContext.chatState = .ready
            
            delegate?.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
        } else {
            try threads.forEach { thread in
                try loadInfo(for: thread.id)
            }
        }
    }
    
    func processThreadMetadataLoadedEvent(_ event: ThreadMetadataLoadedEventDTO) throws {
        LogManager.trace("Processing thread metadata loaded")
        
        guard let threadIndex = threads.index(of: event.postback.data.lastMessage.threadIdOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }

        threads[threadIndex].merge(messages: [MessageMapper.map(event.postback.data.lastMessage)])
        threads[threadIndex].assignedAgent = event.postback.data.ownerAssignee.map(AgentMapper.map)

        if threads[threadIndex].state != .closed {
            threads[threadIndex].state = .loaded
        }
        
        delegate?.onThreadInfoLoad(threads[threadIndex])
        
        if threads.allSatisfy(\.state.isLoaded) {
            delegate?.onThreadsUpdated(threads)
        }
    }
    
    func processMoreMessagesLoaded(_ event: MoreMessagesLoadedEventDTO) throws {
        LogManager.trace("Processing more messages")
        
        guard let activeThread = connectionContext.activeThread, let threadIndex = threads.index(of: activeThread.id) else {
            throw CXoneChatError.invalidThread
        }
            
        if event.postback.data.messages.isEmpty {
            threads[threadIndex].scrollToken.removeAll()
            
            delegate?.onLoadMoreMessages([])
            delegate?.onThreadUpdated(threads[threadIndex])
        } else {
            let messages = event.postback.data.messages.map(MessageMapper.map)

            threads[threadIndex].merge(messages: messages)
            threads[threadIndex].scrollToken = event.postback.data.scrollToken
            
            delegate?.onLoadMoreMessages(messages)
            delegate?.onThreadUpdated(threads[threadIndex])
        }
    }
    
    func processMessageReadChangeEvent(_ event: MessageReadByAgentEventDTO) throws {
        LogManager.trace("Processing message read change")
        
        guard let readThread = threads.getThread(with: event.data.message.threadIdOnExternalPlatform) else {
            throw CXoneChatError.missingParameter("readThread")
        }
        guard let readThreadIndex = threads.index(of: readThread.id) else {
            throw CXoneChatError.missingParameter("readThreadIndex")
        }
        guard let messageIndex = readThread.messages.firstIndex(where: { $0.id == event.data.message.idOnExternalPlatform }) else {
            throw CXoneChatError.missingParameter("messageIndex")
        }

        threads[readThreadIndex].insert(message: MessageMapper.map(event.data.message))

        delegate?.onAgentReadMessage(threadId: readThread.id)
        delegate?.onThreadUpdated(threads[readThreadIndex])
    }
    
    func processContactInboxAssigneeChangedEvent(_ event: ContactInboxAssigneeChangedEventDTO) throws {
        LogManager.trace("Processing thread assignee has changed")
        
        guard let index = threads.index(of: event.data.case.threadIdOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        
        let agent = AgentMapper.map(event.data.inboxAssignee)
        threads[index].assignedAgent = agent
        
        delegate?.onAgentChange(agent, for: event.data.case.threadIdOnExternalPlatform)
        delegate?.onThreadUpdated(threads[index])
    }
    
    func processMessageCreatedEvent(_ data: Data) throws {
        LogManager.trace("Processing message created")
        
        if let event = try? data.decode() as MessageCreatedEventDTO, event.eventType != .custom {
            guard let threadIndex = threads.index(of: event.data.thread.idOnExternalPlatform) else {
                throw CXoneChatError.invalidThread
            }
            
            connectionContext.contactId = event.data.case.id
            
            // Don't handle welcome message again
            guard let service = messages as? MessagesService, !service.isMessageContentWelcomeMessage(event.data.message) else {
                return
            }
            
            let message = MessageMapper.map(event.data.message)
            
            threads[threadIndex].insert(message: message)

            if threads[threadIndex].state != .ready {
                threads[threadIndex].state = .ready
            }
            
            delegate?.onNewMessage(message)
            delegate?.onThreadUpdated(threads[threadIndex])
        } else {
            guard let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw CXoneChatError.invalidData
            }
            
            let data = dict["data"] as? [String: Any]
            let message = data?["message"] as? [String: Any]
            let content = message?["messageContent"] as? [String: Any]
            let payload = content?["payload"] as? [String: Any]
            
            guard let elements = payload?["elements"] as? [Any] else {
                throw CXoneChatError.missingParameter("elements")
            }
            
            delegate?.onCustomPluginMessage(elements)
        }
    }
    
    func processAgentTypingEvent(_ event: AgentTypingEventDTO, isTyping: Bool) {
        guard event.data.user != nil else {
            LogManager.info("Received typing event for unassigned agent")
            return
        }
        
        LogManager.trace("Processing agent typing did \(isTyping ? "started" : "ended")")
        
        delegate?.onAgentTyping(isTyping, threadId: event.data.thread.idOnExternalPlatform)
    }
    
    func processThreadArchivedEvent() {
        LogManager.trace("Thread has been archived")
        
        delegate?.onThreadArchive()
    }
    
    func processRecoveringThreadFailedError(_ error: Error) {
        LogManager.info(error.localizedDescription)
        
        if connectionContext.chatMode != .multithread, !threads.isEmpty {
            // Trying to recover thread that has been created locally so BE does not know about it
            delegate?.onThreadUpdated(threads[0])
        } else if connectionContext.channelConfig.prechatSurvey != nil {
            // Channel Configuration contains pre-chat which has to be filled-in. Notify about ready chat
            delegate?.onChatUpdated(.ready, mode: connectionContext.chatMode)
        } else {
            // No thread available and no form needs to be filled-in -> automatically create a new one
            do {
                try create()
            } catch {
                delegate?.onError(error)
            }
        }
    }
    
    func processCaseStatusChangedEvent(_ event: CaseStatusChangedEventDTO) throws {
        LogManager.trace("Processing case status changed")
        
        guard let index = threads.index(of: event.data.case.threadIdOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        
        delegate?.onThreadUpdated(threads[index])
    }
}

// MARK: - Private methods

private extension ChatThreadsService {
    
    func allCustomFieldsFilled(_ customFields: [String: String]?) -> Bool {
        guard let prechatSurveyCustomFields = connectionContext.channelConfig.prechatSurvey?.customFields else {
            return true
        }
        
        let customFieldsIdents = customFields?
            .filter { !$0.value.isEmpty }
            .map(\.key) ?? []
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
            .filter { ident in
                connectionContext.channelConfig.contactCustomFieldDefinitions.contains { $0.ident == ident }
            }
        
        return preChatIdents.difference(from: customFieldsIdents).isEmpty
    }
}

// MARK: - Helpers

private extension [ChatThread] {
    
    mutating func updateAndGetRecoveredThread(_ eventData: ThreadRecoveredEventDTO) throws -> ChatThread {
        guard let index = index(of: eventData.postback.data.thread.idOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        guard var thread = getThread(with: eventData.postback.data.thread.idOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }

        thread.merge(messages: eventData.postback.data.messages.map(MessageMapper.map(_:)))
        thread.assignedAgent = eventData.postback.data.inboxAssignee.map(AgentMapper.map)
        thread.name = eventData.postback.data.thread.threadName
        thread.contactId = eventData.postback.data.consumerContact.id
        thread.name = eventData.postback.data.thread.threadName
        thread.scrollToken = eventData.postback.data.messagesScrollToken
        thread.state = eventData.postback.data.thread.canAddMoreMessages ? .ready : .closed
        
        self[index] = thread
        
        return thread
    }
}

extension Array where Element: Hashable {
    
    func difference(from other: [Element]) -> [Element] {
        self.filter { !other.contains($0) }
    }
}
