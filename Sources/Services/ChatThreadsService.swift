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

import Combine
import Foundation

class ChatThreadsService {

    // MARK: - Properties

    let socketService: SocketService
    let eventsService: EventsService
    let customerFields: CustomerCustomFieldsService?

    var threads = [ChatThread]()

    let delegate: CXoneChatDelegate

    private var persistedSetPositionInQueueEvent: SetPositionInQueueEventDTO?

    private var connectionContext: ConnectionContext {
        socketService.connectionContext
    }
    private var contactCustomFields: ContactCustomFieldsService? {
        customFields as? ContactCustomFieldsService
    }
        

    // MARK: - Protocol Properties

    let messages: MessagesProvider
    var customFields: ContactCustomFieldsProvider
    var events: AnyPublisher<any ReceivedEvent, Never> {
        socketService.events
    }
    var cancellables = [AnyCancellable]()

    // MARK: - Init

    init(
        messagesProvider: MessagesProvider,
        contactFields: ContactCustomFieldsProvider,
        customerFields: CustomerCustomFieldsProvider,
        socketService: SocketService,
        eventsService: EventsService,
        delegate: CXoneChatDelegate
    ) {
        self.messages = messagesProvider
        self.customFields = contactFields
        self.customerFields = customerFields as? CustomerCustomFieldsService
        self.socketService = socketService
        self.eventsService = eventsService
        self.delegate = delegate

        addListeners()
    }
}

// MARK: - ChatThreadsProvider Implementation

extension ChatThreadsService: ChatThreadsProvider {

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
    func create() async throws -> ChatThread {
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
    func create(with customFields: [String: String]) async throws -> ChatThread {
        LogManager.trace("Creating a new thread")

        try socketService.checkForConnection()

        // Enable to create a new conversation from End Conversation experience
        if connectionContext.chatMode == .liveChat, !threads.isEmpty {
            clearStoredData()
        }
        
        guard connectionContext.chatMode == .multithread || threads.isEmpty else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        
        let thread = ChatThread(id: UUID.provide(), state: .pending)
        
        if !customFields.isEmpty, let service = self.customFields as? ContactCustomFieldsService {
            let mappedCustomFields = customFields.map { CustomFieldDTO(ident: $0.key, value: $0.value, updatedAt: Date.provide()) }
            
            service.updateFields(mappedCustomFields, for: thread.id)
        }
        
        if !allPrechatCustomFieldsFilled(customFields) {
            throw CXoneChatError.missingPreChatCustomFields
        }
        
        threads.append(thread)
        connectionContext.activeThread = thread
        
        connectionContext.chatState = .ready

        // Thread has been successfully created, store its ID for faster recovering
        if connectionContext.chatMode != .multithread {
            UserDefaultsService.shared.set(thread.id, for: .cachedThreadIdOnExternalPlatform)
        }

        if connectionContext.chatMode == .liveChat, let service = messages as? MessagesService {
            try await service.sendBeginLiveChatConversation(for: thread)
        }

        delegate.onThreadUpdated(thread)

        return thread
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func load(with threadId: UUID?) throws {
        try socketService.checkForConnection()

        try recoverThread(threadId: threadId)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
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
        guard threads[index].state != .closed else {
            throw CXoneChatError.illegalThreadState
        }
        
        threads[index].name = name
        
        if threads[index].state == .ready {
            let data = try eventsService.create(
                .updateThread,
                with: .updateThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: id, threadName: name)))
            )
            
            try socketService.send(data: data)
        } else {
            LogManager.info("Thread does not contain any messages. Skipping message sending")
        }

        delegate.onThreadUpdated(threads[index])
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``OperationError`` if there is any operaton error received from the BE.
    func archive(_ thread: ChatThread) throws { // swiftlint:disable:this function_body_length
        LogManager.trace("Archiving thread")
        
        try socketService.checkForConnection()
        
        guard connectionContext.channelConfig.settings.hasMultipleThreadsPerEndUser else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        guard let index = threads.index(of: thread.id) else {
            throw CXoneChatError.invalidThread
        }
        guard threads[index].state != .closed else {
            throw CXoneChatError.illegalChatState
        }
        
        if thread.state.isLoaded {
            LogManager.trace("Thread exists in BE - Archive via socket and wait for response")
            let event = try eventsService.create(
                event: .archiveThread,
                with: .archiveThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: thread.id, threadName: thread.name)))
            )
            
            Task { [self] in
                var cancels = [AnyCancellable]()

                do {
                    try await withCheckedThrowingContinuation { continuation in
                        events
                            .with(type: .threadArchived, as: GenericEventDTO.self)
                            .sink { event in
                                if let eventId = event.eventId, eventId == event.eventId {
                                    LogManager.trace("Thread Archived: \(thread.id)")
                                    continuation.resume()
                                }
                            }
                            .store(in: &cancels)

                        events
                            .with(type: OperationError.self)
                            .sink { error in
                                if error.transactionId == event.eventId {
                                    continuation.resume(throwing: error)
                                }
                            }
                            .store(in: &cancels)

                        do {
                            try socketService.send(data: try eventsService.serialize(event: event))
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }

                    guard let index = threads.index(of: thread.id) else {
                        throw CXoneChatError.invalidThread
                    }

                    threads[index].state = .closed
                } catch {
                    LogManager.error("Thread Archive Failed: \(thread.id): \(error)")
                    delegate.onError(error)
                }
                delegate.onThreadUpdated(threads[index])
            }
        } else {
            LogManager.trace("Thread does not exist in BE - archive locally and immediately notify host application")
            
            threads[index].state = .closed
            
            delegate.onThreadUpdated(threads[index])
        }
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if the `contactId` has not been set properly or it was unable to unwrap it as a required type.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func endContact(_ thread: ChatThread) throws {
        LogManager.trace("Sending EndContactEvent")
        
        try socketService.checkForConnection()
        
        guard connectionContext.chatMode == .liveChat else {
            throw CXoneChatError.illegalChatState
        }
        guard thread.state != .closed else {
            LogManager.info("Conversation has been already closed -> ignoring this request")
            
            delegate.onThreadUpdated(thread)
            return
        }
        guard let contactId = thread.contactId else {
            throw CXoneChatError.missingParameter("contactId")
        }
        
        connectionContext.chatState = .closed
        
        connectionContext.activeThread = thread
        
        let data = try eventsService.create(.endContact, with: .endContact(EndContactEventDataDTO(thread: thread.id, contact: contactId)))

        try socketService.send(data: data)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func markRead(_ thread: ChatThread) throws {
        LogManager.trace("Marking thread as read")
        
        try socketService.checkForConnection()
        
        connectionContext.activeThread = thread
        
        guard thread.state != .closed else {
            return
        }
        guard ![.pending, .closed].contains(thread.state) else {
            LogManager.info("Trying to mark read thread that has been created locally or was archived")
            return
        }
        
        let data = try eventsService.create(
            .messageSeenByCustomer,
            with: .messageSeenByCustomer(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: thread.id, threadName: thread.name)))
        )
        
        try socketService.send(data: data)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func reportTypingStart(_ didStart: Bool, in thread: ChatThread) throws {
        LogManager.trace("Reporting user start typing")

        try socketService.checkForConnection()

        guard thread.state != .closed else {
            throw CXoneChatError.illegalChatState
        }

        connectionContext.activeThread = thread
        
        let data = try eventsService.create(
            didStart ? .senderTypingStarted : .senderTypingEnded,
            with: .customerTypingData(CustomerTypingEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: thread.id, threadName: thread.name)))
        )
        
        try socketService.send(data: data)
    }
}

// MARK: - Internal Methods

extension ChatThreadsService {
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the message services is not correctly registered.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func handleForCurrentChatMode(_ mode: ChatMode) throws {
        switch mode {
        case .singlethread, .liveChat:
            let cachedThreadId: UUID? = UserDefaultsService.shared.get(UUID.self, for: .cachedThreadIdOnExternalPlatform)

            try recoverThread(threadId: cachedThreadId)
        case .multithread:
            try fetchThreadList()
        }
    }

    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func fetchThreadList() throws {
        guard connectionContext.chatMode == .multithread || threads.isEmpty else {
            throw CXoneChatError.unsupportedChannelConfig
        }

        LogManager.trace("Loading all of the threads for the current customer")

        let data = try eventsService.create(.fetchThreadList)

        try socketService.send(data: data)
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the message services is not correctly registered.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func recoverThread(threadId: UUID?) throws {
        LogManager.trace("Loading the a thread for the customer and gets messages")

        let validChatThreadStates: [ChatThreadState] = connectionContext.chatMode == .liveChat ? [.pending] : [.pending, .closed]

        if let threadId, let thread = threads.getThread(with: threadId), validChatThreadStates.contains(thread.state) {
            LogManager.info("Thread has been created locally or is archived -> no need to recover it")

            if connectionContext.chatMode != .multithread {
                LogManager.info("Set thread as active for `.singlethread` or `.liveChat` channel")

                connectionContext.activeThread = thread
            }

            connectionContext.chatState = .ready
            
            delegate.onThreadUpdated(thread)
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
            return
        }

        let dataType = threadId.map { threadId -> EventDataType in
            if connectionContext.chatMode != .multithread, let thread = threads.getThread(with: threadId) {
                LogManager.info("Set thread as active for `.singlethread` or `.liveChat` channel")

                connectionContext.activeThread = thread
            }

            return .loadThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: threadId, threadName: nil)))
        }
        let data = try eventsService.create(connectionContext.chatMode == .liveChat ? .recoverLiveChat : .recoverThread, with: dataType)

        try socketService.send(data: data)
    }

    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func loadInfo(for threadId: UUID) throws {
        guard let thread = threads.getThread(with: threadId) else {
            throw CXoneChatError.invalidThread
        }
        guard thread.state != .pending else {
            LogManager.info("Loads information about the thread is available only for threads existing in the backend")
            // There is not way to optain information if the scene is chat list or single conversation, so it is necessary to notify both delegate methods
            delegate.onThreadsUpdated(threads)
            delegate.onThreadUpdated(thread)
            return
        }

        LogManager.trace("Loads information about the thread")

        let data = try eventsService.create(
            .loadThreadMetadata,
            with: .loadThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: threadId, threadName: nil)))
        )

        try socketService.send(data: data)
    }

    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the provided ID for the thread was invalid, so the action could not be performed.
    func handleWelcomeMessage(_ message: String) throws {
        UserDefaultsService.shared.set(message, for: .welcomeMessage)

        guard let activeThread = connectionContext.activeThread, activeThread.state == .pending else {
            // No available thread for handling welcome message or
            // no need to handle welcome message for thread that exists on the BE side -> first message should be the welcome message
            return
        }
        guard activeThread.messages.isEmpty else {
            // Thread already contains some messages -> no need to append welcome message because it has been already added
            return
        }
        guard let index = threads.index(of: activeThread.id) else {
            throw CXoneChatError.invalidThread
        }
        guard let service = messages as? MessagesService else {
            throw CXoneChatError.invalidParameter("messagesService")
        }

        threads[index].merge(messages: [try service.getParsedWelcomeMessage(message, for: activeThread)])

        // Override active thread with the one with updated message list of a welcome message
        connectionContext.activeThread = threads[index]
    }
}

// MARK: - EventReceiver

extension ChatThreadsService: EventReceiver {
    
    func addListeners() {
        addListener(for: .senderTypingStarted, with: processAgentTypingEvent(_:))
        addListener(for: .senderTypingEnded, with: processAgentTypingEvent(_:))
        addListener(processMessageCreatedEvent(_:))
        addListener(processThreadRecoveredEvent(_:))
        addListener(processMessageReadChangeEvent(_:))
        addListener(processContactInboxAssigneeChangedEvent(_:))
        addListener(processMoreMessagesLoaded(_:))
        addListener(for: .threadListFetched, with: processThreadListFetchedEvent(_:))
        addListener(processThreadMetadataLoadedEvent(_:))
        addListener(processCaseStatusChangedEvent(_:))
        addListener(processSetPositionInQueueEvent(_:))
        addListener(processLiveChatRecoveredEvent(_:))
        addListener(processOperationError(_:))
    }

    func clearStoredData() {
        LogManager.info("Removing stored data for chat threads service")

        threads.removeAll()

        contactCustomFields?.clearStoredData()
    }
}

// MARK: - Socket Methods

extension ChatThreadsService {
    
    func processOperationError(_ event: OperationError) {
        #warning("DE-114311 - takes recoveringThreadFailed out of this list")
        #warning("DE-114310 - takes recoveringLiveChatFailed out of this list")
        switch event.errorCode {
        case .recoveringThreadFailed, .recoveringLiveChatFailed:
            processRecoveringThreadFailedError(event)
        default:
            break
        }
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processThreadRecoveredEvent(_ event: ThreadRecoveredEventDTO) throws {
        LogManager.trace("Processing thread recovered with UUID - \(event.postback.data.thread.idOnExternalPlatform)")
        
        socketService.connectionContext.contactId = event.postback.data.consumerContact.id
        
        contactCustomFields?.updateFields(
            event.postback.data.consumerContact.customFields,
            for: event.postback.data.thread.idOnExternalPlatform
        )
        customerFields?.updateFields(event.postback.data.customerCustomFields)
        
        if !threads.contains(where: { $0.id == event.postback.data.thread.idOnExternalPlatform }) {
            threads.append(
                ChatThread(
                    id: event.postback.data.thread.idOnExternalPlatform,
                    state: event.postback.data.thread.canAddMoreMessages ? .ready : .closed
                )
            )
        }
        
        let thread = try threads.updateAndGetThread(with: event)
        
        if connectionContext.activeThread?.id == thread.id {
            // Update the metadata of the active thread if the event has updated it
            connectionContext.activeThread = thread
        }
        
        connectionContext.chatState = .ready

        delegate.onThreadUpdated(thread)
        delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processLiveChatRecoveredEvent(_ event: LiveChatRecoveredDTO) throws {
        guard let data = event.postback.data, data.contact.status != .closed else {
            LogManager.trace(
                event.postback.data == nil
                    ? "Live Chat recovered but there is no data available -> proceed to create a thread"
                    : "Received thread has been closed -> ignore it and proceed to create a thread"
            )
        
            connectionContext.chatState = .ready
            
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
            return
        }
        
        LogManager.trace("Processing thread recovered with UUID - \(data.thread.idOnExternalPlatform)")
        
        socketService.connectionContext.contactId = data.contact.id
        
        contactCustomFields?.updateFields(data.contact.customFields, for: data.thread.idOnExternalPlatform)
        customerFields?.updateFields(data.customerCustomFields)
        
        if !threads.contains(where: { $0.id == data.thread.idOnExternalPlatform }) {
            threads.append(ChatThread(id: data.thread.idOnExternalPlatform, state: .ready))
        }
        
        let thread = try threads.updateAndGetThread(with: data)
        connectionContext.activeThread = thread
        connectionContext.chatState = .ready

        delegate.onThreadUpdated(thread)
        delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the message services is not correctly registered.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func processThreadListFetchedEvent(_ event: GenericEventDTO) throws {
        LogManager.trace("Processing thread list fetched")
        
        // Store threads that has been created locally but not yet on the BE so they are not overriden with the BE threads
        let additionalThreads = threads.filter { $0.state == .pending }
        threads = event.postback?.threads?.map(ChatThreadMapper.map) ?? []
        threads.append(contentsOf: additionalThreads)
        
        connectionContext.chatState = .ready
        delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
        
        try threads.forEach { thread in
            if thread.id == connectionContext.activeThread?.id {
                LogManager.info("Fetched thread is the active one - recovering it directly instaed of loading its info and then calling recover")
                
                try recoverThread(threadId: thread.id)
            } else {
                try loadInfo(for: thread.id)
            }
        }
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processThreadMetadataLoadedEvent(_ event: ThreadMetadataLoadedEventDTO) throws {
        LogManager.trace("Processing thread metadata loaded")
        
        guard let index = threads.index(of: event.postback.data.lastMessage.threadIdOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }

        threads[index].merge(messages: [MessageMapper.map(event.postback.data.lastMessage)])
        threads[index].assignedAgent = event.postback.data.ownerAssignee.map(AgentMapper.map)

        if threads[index].state != .closed {
            threads[index].state = .loaded
        }
        
        // There can be more threads and one of them could be locally created so it is necessary to invoke `onThreadsUpdated(_:)`
        // even for thread in `.pending` state.
        if threads.allSatisfy({ $0.state == .pending || $0.state.isLoaded }) {
            delegate.onThreadsUpdated(threads)
        }
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the message services is not correctly registered.
    func processMoreMessagesLoaded(_ event: MoreMessagesLoadedEventDTO) throws {
        LogManager.trace("Processing more messages")
        
        guard let activeThread = connectionContext.activeThread, let index = threads.index(of: activeThread.id) else {
            throw CXoneChatError.invalidThread
        }
            
        if event.postback.data.messages.isEmpty {
            threads[index].scrollToken.removeAll()
            connectionContext.activeThread?.scrollToken.removeAll()
            
            delegate.onThreadUpdated(threads[index])
        } else {
            guard let messagesService = messages as? MessagesService else {
                throw CXoneChatError.invalidParameter("messagesService")
            }
            
            let messages = event.postback.data.messages
                .filter { !messagesService.shouldIgnoreMessage($0) }
                .map(MessageMapper.map)

            threads[index].merge(messages: messages)
            threads[index].scrollToken = event.postback.data.scrollToken
            connectionContext.activeThread = threads[index]
            
            delegate.onThreadUpdated(threads[index])
        }
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processMessageReadChangeEvent(_ event: MessageReadByAgentEventDTO) throws {
        LogManager.trace("Processing message read change")
        
        guard let index = threads.index(of: event.data.message.threadIdOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }

        // Don't handle specific messages (Welcome message, Begin liveChat conversation, etc.
        if let service = messages as? MessagesService, !service.shouldIgnoreMessage(event.data.message) {
            threads[index].merge(messages: [MessageMapper.map(event.data.message)])
            
            if connectionContext.activeThread?.id == threads[index].id {
                // Update the metadata of the active thread if the event has updated it
                connectionContext.activeThread = threads[index]
            }
            
            delegate.onThreadUpdated(threads[index])
        }
    }

    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processContactInboxAssigneeChangedEvent(_ event: ContactInboxAssigneeChangedEventDTO) throws {
        LogManager.trace("Processing thread assignee has changed")
        
        if connectionContext.chatMode == .liveChat, event.data.case.threadIdOnExternalPlatform != connectionContext.activeThread?.id {
            LogManager.info("Event received for a thread other than the active thread")
            return
        }
        
        guard let index = threads.index(of: event.data.case.threadIdOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        
        let agent = event.data.inboxAssignee.map(AgentMapper.map)
        threads[index].assignedAgent = agent
        threads[index].lastAssignedAgent = event.data.previousInboxAssignee.map(AgentMapper.map)
        threads[index].positionInQueue = nil
        
        // It is not necessary to change thread state based on assignee change event for messaging channel configuration
        if connectionContext.chatMode == .liveChat {
            threads[index].state = event.data.case.status == .closed ? .closed : .ready
        }
        
        if connectionContext.activeThread?.id == threads[index].id {
            // Update the metadata of the active thread if the event has updated it
            connectionContext.activeThread = threads[index]
        }
        
        delegate.onThreadUpdated(threads[index])
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func processMessageCreatedEvent(_ event: MessageCreatedEventDTO) throws {
        LogManager.trace("Processing message created")
        
        guard let index = threads.index(of: event.data.thread.idOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        
        connectionContext.contactId = event.data.case.id
        threads[index].contactId = event.data.case.id

        if persistedSetPositionInQueueEvent?.data.consumerContact == event.data.case.id, let persistedSetPositionInQueueEvent {
            self.persistedSetPositionInQueueEvent = nil
            
            try processSetPositionInQueueEvent(persistedSetPositionInQueueEvent)
        }
        
        // Don't handle specific messages (Welcome message, Begin liveChat conversation, etc.
        guard let service = messages as? MessagesService, !service.shouldIgnoreMessage(event.data.message) else {
            LogManager.info("Ignoring incomming message from BE - it's content is a special one like begin liveChat conversation or welcome message")
            return
        }
        
        let message = MessageMapper.map(event.data.message)
        
        threads[index].merge(messages: [message])

        if threads[index].state != .ready {
            threads[index].state = .ready
        }
        
        if connectionContext.activeThread?.id == threads[index].id {
            // Update the metadata of the active thread if the event has updated it
            connectionContext.activeThread = threads[index]
        }
        
        delegate.onThreadUpdated(threads[index])
    }
    
    func processAgentTypingEvent(_ event: AgentTypingEventDTO) {
        let isTyping = event.eventType == .senderTypingStarted

        guard event.data.user != nil else {
            LogManager.info("Received typing event for unassigned agent")
            return
        }
        
        LogManager.trace("Processing agent typing did \(isTyping ? "started" : "ended")")
        
        delegate.onAgentTyping(isTyping, threadId: event.data.thread.idOnExternalPlatform)
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
    func processRecoveringThreadFailedError(_ error: Error) {
        LogManager.error(error.localizedDescription)
        
        if connectionContext.chatMode == .liveChat, connectionContext.channelConfig.settings.isRecoverLiveChatDoesNotFailEnabled {
            delegate.onError(error)
        } else if connectionContext.chatMode != .multithread, let thread = threads.first(where: { $0.state == .pending }) {
            // Trying to recover thread that has been created locally so BE does not know about it
            connectionContext.chatState = .ready
            
            delegate.onThreadUpdated(thread)
        } else if connectionContext.channelConfig.prechatSurvey != nil {
            // Channel Configuration contains pre-chat which has to be filled-in. Notify about ready chat
            connectionContext.chatState = .ready
            
            delegate.onChatUpdated(connectionContext.chatState, mode: connectionContext.chatMode)
        } else {
            // No thread available and no form needs to be filled-in -> automatically create a new one
            Task {
                do {
                    try await create()
                } catch {
                    delegate.onError(error)
                }
            }
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
        
        if connectionContext.activeThread?.id == threads[index].id {
            // Update the metadata of the active thread if the event has updated it
            connectionContext.activeThread = threads[index]
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
        connectionContext.activeThread = threads[index]

        delegate.onThreadUpdated(threads[index])
    }
}

// MARK: - Private methods

private extension ChatThreadsService {
    
    func allPrechatCustomFieldsFilled(_ customFields: [String: String]?) -> Bool {
        guard let prechatSurveyCustomFields = connectionContext.channelConfig.prechatSurvey?.customFields else {
            return true
        }
        guard let customFields else {
            return false
        }
        
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

private extension [ChatThread] {
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    mutating func updateAndGetThread(with eventData: ThreadRecoveredEventDTO) throws -> ChatThread {
        guard let index = index(of: eventData.postback.data.thread.idOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        
        self[index] = self[index].updated(from: eventData.postback.data)
        
        return self[index]
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    mutating func updateAndGetThread(with data: LiveChatRecoveredPostbackDataDTO) throws -> ChatThread {
        guard let index = index(of: data.thread.idOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        
        self[index] = self[index].updated(from: data)
        
        return self[index]
    }
}

private extension MessageContentType {
    
    var text: String? {
        guard case .text(let payload) = self else {
            return nil
        }
        
        return payload.text
    }
}

extension Array where Element: Hashable {
    
    func difference(from other: [Element]) -> [Element] {
        self.filter { !other.contains($0) }
    }
}
