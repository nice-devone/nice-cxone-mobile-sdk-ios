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
import UniformTypeIdentifiers

final class ChatThreadService: Sendable {
    
    // MARK: - Properties
    
    static let beginLiveChatConversationMessage = "Begin Conversation"
    static let unsupportedMessageTypeAnswerMessage = "The last agent's message is not supported in the mobile SDK"

    /// How long the customer's first message waits for the backend's copy of the welcome message sent before it.
    static let backendWelcomeMessageTimeout: Double = 2
    
    let socketService: SocketService
    let eventsService: EventsService
    
    let broadcaster: EventBroadcaster

    private let contactCustomFieldsProvider: ContactCustomFieldsProvider
    private let customerCustomFieldsProvider: CustomerCustomFieldsProvider
    private let welcomeMessageManager: WelcomeMessageManager
    
    /// The welcome message the SDK added to a new thread itself, until the backend's copy of it replaces it.
    ///
    /// A single value, so whether the welcome message still has to be sent and which message to replace cannot disagree.
    ///
    /// Lock order: it is locked while ``chatThread``'s lock is held, never the other way round - a closure mutating it
    /// must not read ``chatThread``.
    private let _localWelcomeMessage = SafeAccessContainer<LocalWelcomeMessage?>(nil)

    /// The ID the welcome message is sent with - the same for every attempt. A send that reported an error may still
    /// have reached the backend, so a retry could otherwise leave two copies there; with one ID, they merge into one message.
    private let welcomeMessageOutboundId = LowercaseUUID().uuidString

    private var connectionContext: ConnectionContext {
        socketService.connectionContext
    }
    private var contactCustomFieldsService: ContactCustomFieldsService? {
        contactCustomFieldsProvider as? ContactCustomFieldsService
    }
    private var customerCustomFieldsService: CustomerCustomFieldsService? {
        customerCustomFieldsProvider as? CustomerCustomFieldsService
    }
    
    // MARK: - Protocol Properties

    private let _chatThread: SafeAccessContainer<ChatThread>
    var chatThread: ChatThread {
        get { _chatThread.content }
        set {
            _chatThread.mutate { content in
                // A write built from a snapshot taken before the backend's copy of the welcome message replaced
                // the local one must not bring the local copy back
                content = reconcilingReplacedLocalWelcomeMessage(in: newValue)
            }
        }
    }

    var eventBroadcast: EventBroadcast { socketService.eventBroadcast }
    var listenerTasks: [Task<Void, Never>] {
        get { socketService.listenerTasks }
        set { socketService.listenerTasks = newValue }
    }
    
    // MARK: - Init
    
    init(
        chatThread: ChatThread,
        contactFieldsProvider: ContactCustomFieldsProvider,
        customerFieldsProvider: CustomerCustomFieldsProvider,
        socketService: SocketService,
        eventsService: EventsService,
        welcomeMessageManager: WelcomeMessageManager,
        broadcaster: EventBroadcaster
    ) {
        self._chatThread = SafeAccessContainer(chatThread)
        self.contactCustomFieldsProvider = contactFieldsProvider
        self.customerCustomFieldsProvider = customerFieldsProvider
        self.socketService = socketService
        self.eventsService = eventsService
        self.welcomeMessageManager = welcomeMessageManager
        self.broadcaster = broadcaster
    }
}

// MARK: - ChatThreadProvider

extension ChatThreadService: ChatThreadProvider {
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/noMoreMessages`` if there aren't any other messages, so additional messages could not be loaded.
    /// - Throws: ``CXoneChatError/invalidOldestDate`` if Thread is missing the timestamp of when the message was created.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/eventTimeout`` if the SDK did not receive a response within the specified time.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
    func loadMoreMessages() async throws {
        LogManager.trace("Loading more messages.")
        
        try socketService.checkForConnection()

        guard chatThread.hasMoreMessagesToLoad else {
            throw CXoneChatError.noMoreMessages
        }
        guard let oldestDate = chatThread.messages.first?.createdAt else {
            throw CXoneChatError.invalidOldestDate
        }
        
        let thread = threadDTO
        let event = try eventsService.create(
            event: .loadMoreMessages,
            with: .loadMoreMessageData(LoadMoreMessagesEventDataDTO(scrollToken: chatThread.scrollToken, thread: thread, oldestMessageDatetime: oldestDate))
        )
        
        let response = try await eventBroadcast.waitFor(
            MoreMessagesLoadedEventDTO.self,
            eventType: .moreMessagesLoaded,
            origin: event,
            socketService: socketService,
            eventsService: eventsService
        )
        
        processMoreMessagesLoaded(response)
    }
    
    /// - Throws: ``CXoneChatError/illegalChatState`` if the chat thread is already closed.
    /// - Throws: ``CXoneChatError/attachmentError`` if the provided attachment was unable to be sent.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if attachments upload `url` has not been set properly or attachment uploaded data object is missing
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the outbound message has no ``OutboundMessage/postback``,
    ///   empty ``OutboundMessage/text``, and empty ``OutboundMessage/attachments``.
    /// - Throws: ``CXoneChatError/invalidFileSize`` if size of the attachment exceeds the allowed size
    /// - Throws: ``CXoneChatError/invalidFileType`` if type of the attachment is not included in the allowed file MIME type
    /// - Throws: ``CXoneChatError/invalidData`` if the conversion from object instance to data failed
    ///     or when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/eventTimeout`` if the SDK did not receive a response within the specified time.
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
    /// - Throws: `URLError.badServerResponse` if the URL Loading system received bad data from the server.
    /// - Throws: `NSError` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    /// - Throws: An error if any value throws an error during encoding.
    @MainActor
    func send(_ message: OutboundMessage) async throws {
        try await send(message: message, parameters: [:])
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
    func updateName(_ name: String) async throws {
        LogManager.trace("Updating the name for a thread")

        try socketService.checkForConnection()

        guard connectionContext.chatMode == .multithread else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        guard chatThread.state != .closed else {
            throw CXoneChatError.illegalThreadState
        }

        // Atomic, so it cannot overwrite a concurrent change to the messages
        _chatThread.mutate { thread in
            thread = thread.copy(name: name)
        }

        if chatThread.state == .ready {
            let data = try eventsService.create(
                .updateThread,
                with: .updateThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: chatThread.id, threadName: name)))
            )

            try await socketService.send(data: data)
        } else {
            LogManager.info("Thread does not contain any messages. Skipping message sending")
        }

        broadcaster.send(.threadUpdated(chatThread))
    }

    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/illegalChatState`` if the chat thread is already closed.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/eventTimeout`` if the SDK did not receive a response within the specified time.
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
    /// - Throws: An error if the backend rejects the archive request.
    func archive() async throws {
        LogManager.trace("Archiving thread")
        
        try socketService.checkForConnection()
        
        guard connectionContext.chatMode == .multithread else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        guard chatThread.state != .closed else {
            throw CXoneChatError.illegalChatState
        }
        
        if chatThread.state.isLoaded {
            LogManager.trace("Thread exists in BE - Archive via socket and wait for response")
            
            let event = try eventsService.create(
                event: .archiveThread,
                with: .archiveThreadData(ThreadEventDataDTO(thread: threadDTO))
            )
            
            try await eventBroadcast.waitFor(
                GenericEventDTO.self,
                eventType: .threadArchived,
                origin: event,
                socketService: socketService,
                eventsService: eventsService
            )
            
            LogManager.trace("Thread Archived: \(chatThread.id)")
        } else {
            LogManager.trace("Thread does not exist in BE")
        }

        // Atomic, so it cannot overwrite a concurrent change to the messages
        _chatThread.mutate { thread in
            thread = thread.copy(state: .closed)
        }

        broadcaster.send(.threadUpdated(chatThread))
    }

    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/illegalChatState`` if the channel is not configured for live chat.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if the `contactId` has not been set properly or it was unable to unwrap it as a required type.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string.
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
    func endContact() async throws {
        LogManager.trace("Sending EndContactEvent")
        
        try socketService.checkForConnection()
        
        guard connectionContext.chatMode == .liveChat else {
            throw CXoneChatError.illegalChatState
        }
        guard chatThread.state != .closed else {
            LogManager.info("Conversation has been already closed -> ignoring this request")
            
            broadcaster.send(.threadUpdated(chatThread))
            return
        }
        guard let contactId = chatThread.contactId else {
            throw CXoneChatError.missingParameter("contactId")
        }
        
        connectionContext.chatState = .closed
        
        let data = try eventsService.create(.endContact, with: .endContact(EndContactEventDataDTO(thread: chatThread.id, contact: contactId)))

        try await socketService.send(data: data)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
    func markRead() async throws {
        LogManager.trace("Marking thread as read")
        
        try socketService.checkForConnection()
        
        guard chatThread.state != .closed else {
            return
        }
        guard ![.pending, .closed].contains(chatThread.state) else {
            LogManager.info("Trying to mark read thread that has been created locally or was archived")
            return
        }
        
        let data = try eventsService.create(
            .messageSeenByCustomer,
            with: .messageSeenByCustomer(ThreadEventDataDTO(thread: threadDTO))
        )
        
        try await socketService.send(data: data)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
    func reportTypingStart(_ didStart: Bool) async throws {
        LogManager.trace("Reporting user start typing")

        try socketService.checkForConnection()

        guard chatThread.state != .closed else {
            throw CXoneChatError.illegalThreadState
        }
        
        let data = try eventsService.create(
            didStart ? .senderTypingStarted : .senderTypingEnded,
            with: .customerTypingData(CustomerTypingEventDataDTO(thread: threadDTO))
        )
        
        try await socketService.send(data: data)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/sendTranscriptFailed`` if the feature is not enabled, provided email is not valid or something went wrong on the BE side.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if contactID is not set properly
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    func sendTranscript(to email: String) async throws {
        LogManager.trace("Sending transcript")
        
        try socketService.checkForConnection()
        
        guard chatThread.state != .pending else {
            throw CXoneChatError.illegalThreadState
        }
        guard connectionContext.channelConfig.settings.isSendTranscriptEnabled else {
            throw CXoneChatError.sendTranscriptFailed
        }
        guard !email.isEmpty, email.isValid(regex: String.emailRegEx) else {
            throw CXoneChatError.sendTranscriptFailed
        }
        guard let consumerContact = chatThread.contactId, !consumerContact.isEmpty else {
            throw CXoneChatError.missingParameter("consumerContact")
        }
        
        let event = try eventsService.create(
            event: .sendTranscript,
            with: .sendTranscriptData(SendTranscriptDataDTO(consumerContact: consumerContact, consumerRecipient: email))
        )
        
        do {
            try await eventBroadcast.waitFor(
                GenericEventDTO.self,
                eventType: .transcriptSent,
                origin: event,
                socketService: socketService,
                eventsService: eventsService
            )
        } catch {
            if let error = error as? OperationError, error.errorCode == .sendingTranscriptFailed {
                throw CXoneChatError.sendTranscriptFailed
            } else {
                throw error
            }
        }
        
        LogManager.trace("Transcript successfully sent")
    }
}

// MARK: - Internal methods

extension ChatThreadService {
    
    /// - Throws: ``CXoneChatError/illegalChatState`` if the chat thread is already closed.
    /// - Throws: ``CXoneChatError/attachmentError`` if the provided attachment was unable to be sent.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if attachments upload `url` has not been set properly or attachment uploaded data object is missing
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the outbound message has no ``OutboundMessage/postback``,
    ///   empty ``OutboundMessage/text``, and empty ``OutboundMessage/attachments``.
    /// - Throws: ``CXoneChatError/invalidFileSize`` if size of the attachment exceeds the allowed size
    /// - Throws: ``CXoneChatError/invalidFileType`` if type of the attachment is not included in the allowed file MIME type
    /// - Throws: ``CXoneChatError/invalidData`` if the conversion from object instance to data failed
    ///     or when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/eventTimeout`` if the SDK did not receive a response within the specified time.
    /// - Throws: ``CXoneChatError/invalidAccessToken`` if the credential needs a refresh but nothing is available to
    ///     perform it — no registered token delegate listener for the implicit flow, or no socket delegate at all.
    /// - Throws: ``CXoneChatError/invalidRefreshToken(_:)`` if the explicit-PKCE credential was expired and the
    ///     refresh grant to renew it was rejected — the app must re-authenticate before it can send again.
    /// - Throws: ``CXoneChatError/transactionTokenRequestFailed(statusCode:)`` if the explicit-PKCE credential was
    ///     expired and renewing it failed for any other reason.
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
    /// - Throws: `URLError.badServerResponse` if the URL Loading system received bad data from the server.
    /// - Throws: `NSError` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    /// - Throws: An error if any value throws an error during encoding.
    @MainActor
    func send(message: OutboundMessage, parameters: [MessageParameter: AnyValue]) async throws { // swiftlint:disable:this function_body_length
        LogManager.trace("Sending a message in the specified chat thread.")

        guard chatThread.state != .closed else {
            throw CXoneChatError.illegalChatState
        }
        // Check if sending attachments is enabled
        guard message.attachments.isEmpty || connectionContext.channelConfig.settings.fileRestrictions.isAttachmentsEnabled else {
            throw CXoneChatError.attachmentError
        }
        guard message.postback != nil || !message.text.isEmpty || !message.attachments.isEmpty else {
            throw CXoneChatError.invalidParameter("attempt to send a message with no postback, text, or attachments")
        }

        try socketService.checkForConnection()

        // Ensure the credential (implicit JWT or explicit transaction token) is fresh BEFORE it is embedded
        // into the outbound payload below.
        try await refreshConnectionTokenIfNeeded()

        let contactFields = contactCustomFieldsService?.contactFields[chatThread.id]?.convertValueToIdentifier(
            with: connectionContext.channelConfig.prechatSurvey?.customFields
        )
        let customerFields = customerCustomFieldsService?.customerFields.convertValueToIdentifier(
            with: connectionContext.channelConfig.prechatSurvey?.customFields
        )
        
        // Don't send the welcome message for specific messages
        if parameters[.isBeginLiveChatConversation] == nil && parameters[.isUnsupportedMessageTypeAnswer] == nil {
            try await sendWelcomeMessageIfNeeded()
        }
        
        let messageData = SendMessageEventDataDTO(
            thread: threadDTO,
            contentType: .text(MessagePayloadDTO(text: message.text, postback: message.postback, parameters: parameters)),
            idOnExternalPlatform: LowercaseUUID().uuidString,
            customer: CustomerCustomFieldsDataDTO(customFields: customerFields ?? []),
            contact: ContactCustomFieldsDataDTO(customFields: contactFields ?? []),
            attachments: try await message.attachments.map(with: connectionContext),
            deviceFingerprint: DeviceFingerprintDTO(deviceToken: connectionContext.deviceToken),
            token: connectionContext.effectiveAccessToken
        )
        
        // Ignore the message if it contains specific parameter
        let isIgnoredMessage = parameters.hasOneOf(.isBeginLiveChatConversation, .isUnsupportedMessageTypeAnswer, .isInactivityPopupAnswer)
        
        let newMessage: Message? = !isIgnoredMessage ? {
            let mappedMessage = MessageMapper.map(
                from: messageData,
                payload: MessagePayload(text: message.text, postback: message.postback),
                authorUser: chatThread.assignedAgent,
                customer: connectionContext.customer.map(CustomerIdentityMapper.map)
            )

            // Atomic, like `merge(_:update:)`, so the two cannot overwrite each other's changes
            _chatThread.mutate { thread in
                thread = thread.appending(message: mappedMessage)
            }

            broadcaster.send(.threadUpdated(chatThread))

            return mappedMessage
        }() : nil
        
        do {
            try await eventBroadcast.waitFor(
                GenericEventDTO.self,
                origin: try eventsService.create(event: .sendMessage, with: .sendMessageData(messageData)),
                // The credential was already freshened by `refreshConnectionTokenIfNeeded()` above and embedded
                // into `messageData`; skip the choke-point re-check so a single refresh runs per event.
                checkTokenExpiration: false,
                socketService: socketService,
                eventsService: eventsService
            )
            
            LogManager.trace("Message \(messageData.idOnExternalPlatform) successfully added into thread \(chatThread.id)")
        } catch {
            LogManager.error("Failed to send message: \(error)")

            // Update it only when the message was appended to the thread
            if let newMessage {
                // Create a new Message with failed status since Message is immutable
                let failedMessage = Message(
                    id: newMessage.id,
                    threadId: newMessage.threadId,
                    contentType: newMessage.contentType,
                    createdAt: newMessage.createdAt,
                    attachments: newMessage.attachments,
                    direction: newMessage.direction,
                    agentStatistics: newMessage.agentStatistics,
                    customerStatistics: newMessage.customerStatistics,
                    authorUser: newMessage.authorUser,
                    authorEndUserIdentity: newMessage.authorEndUserIdentity,
                    status: .failed
                )

                // Replace the message by ID to ensure we're updating the correct message
                _chatThread.mutate { thread in
                    thread = thread.replacingMessage(withId: newMessage.id, with: failedMessage)
                }

                broadcaster.send(.threadUpdated(chatThread))
            }

            throw error
        }
    }
    
    /// Adds the welcome message to a new thread. It does not notify the subscribers - the caller broadcasts the thread itself.
    ///
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    func addLocalWelcomeMessage(_ message: String) throws {
        guard let customer = connectionContext.customer else {
            throw CXoneChatError.customerAssociationFailure
        }

        let contactFields = contactCustomFieldsService?.contactFields[chatThread.id] ?? []
        let customerFields = customerCustomFieldsService?.customerFields ?? []
        
        let parsedMessage = welcomeMessageManager.parse(message, contactFields: contactFields, customerFields: customerFields, customer: customer)
        let welcomeMessage = Message(
            id: LowercaseUUID().uuidString,
            threadId: chatThread.id,
            contentType: .text(MessagePayload(text: parsedMessage, postback: nil)),
            createdAt: Date(),
            attachments: [],
            direction: .toClient,
            agentStatistics: nil,
            customerStatistics: nil,
            authorUser: nil,
            authorEndUserIdentity: CustomerIdentityMapper.map(customer),
            status: .sent
        )

        // Checked in the same atomic step as the insert
        let isWelcomeMessageAdded = _chatThread.mutate { thread -> Bool in
            // A thread existing on the backend or one that already has messages starts with the backend's history instead
            guard thread.state == .pending, thread.messages.isEmpty else {
                return false
            }

            thread = thread.merged(with: [welcomeMessage])

            _localWelcomeMessage.mutate { localWelcomeMessage in
                localWelcomeMessage = .notSent(messageId: welcomeMessage.id)
            }

            return true
        }

        // Logged outside the thread's lock - the integrator's log writer may read the thread
        if !isWelcomeMessageAdded {
            LogManager.warning("Welcome message not added - the thread is not a new empty thread")
        }
    }

    /// Merges messages received from the backend into ``chatThread``.
    ///
    /// Use it, or ``applyRecoveredThread(_:recoveredMessages:)``, for every backend message that can be the backend's copy
    /// of the welcome message: only these two recognize the copy, so it replaces the local one - the copy has a different ID,
    /// so otherwise the thread would show the welcome message twice. Once replaced, every write to ``chatThread`` keeps it that way.
    ///
    /// The removal of the local copy, the merge and the optional `update` happen in one atomic step,
    /// so a concurrent change to the thread cannot be overwritten and no reader sees the thread between them.
    ///
    /// - Parameters:
    ///   - messages: The messages received from the backend.
    ///   - update: Further changes applied to the thread in the same step. It runs while the thread is locked,
    ///     so it must not read ``chatThread`` or log - the integrator's log writer runs synchronously and may read the thread,
    ///     and the lock is not recursive.
    /// - Returns: The merged messages, mapped to their public model.
    @discardableResult
    func merge(_ messages: [MessageDTO], update: (@Sendable (ChatThread) -> ChatThread)? = nil) -> [Message] {
        let mappedMessages = messages.compactMap(MessageMapper.map)

        replaceThread(ifReplacingLocalWelcomeMessageWith: backendWelcomeMessage(in: messages, mappedMessages: mappedMessages)) { thread in
            // Not merged when empty - merging re-sorts the messages, which an empty page must not do
            let mergedThread = mappedMessages.isEmpty ? thread : thread.merged(with: mappedMessages)

            return update?(mergedThread) ?? mergedThread
        }

        return mappedMessages
    }

    /// Applies the recovered state to ``chatThread``, removing the local welcome message if the backend's copy of it
    /// is among the recovered messages - see ``merge(_:update:)``.
    ///
    /// The recovered thread is built before the atomic step, because building it maps messages,
    /// and mapping can log - a log writer reading the thread must not run while the thread is locked.
    ///
    /// - Parameters:
    ///   - recoveredThread: The thread built from the recovery event.
    ///   - recoveredMessages: The messages received in the recovery event.
    func applyRecoveredThread(_ recoveredThread: ChatThread, recoveredMessages: [MessageDTO]) {
        let backendWelcomeMessage = backendWelcomeMessage(in: recoveredMessages, mappedMessages: recoveredThread.messages)

        replaceThread(ifReplacingLocalWelcomeMessageWith: backendWelcomeMessage) { _ in
            recoveredThread
        }
    }

    /// Replaces ``chatThread`` with its state from the backend and discards the local welcome message, in one atomic step.
    ///
    /// A thread listed by the backend already exists there, so its welcome message, if any, was already sent.
    func replaceWithBackendThread(_ backendThread: ChatThread) {
        _chatThread.mutate { thread in
            thread = backendThread

            _localWelcomeMessage.mutate { localWelcomeMessage in
                // The ID is kept, so a write built from a snapshot taken before the replacement cannot bring the local copy back.
                // A stored backend copy is dropped too: the backend thread starts without history, and re-adding the welcome
                // message would make it the oldest message, so loading older messages would skip the history in between.
                localWelcomeMessage = localWelcomeMessage.map { localWelcomeMessage in
                    .discarded(messageId: localWelcomeMessage.messageId)
                }
            }
        }
    }

    /// Some messages should not appear into the chat history because of specific reason,
    /// e.g. Begin live chat conversation = Live chat thread is created with hard coded message
    /// that we don't want to present to the user
    ///
    /// The backend's copy of the welcome message is never ignored - it replaces the local copy,
    /// see ``merge(_:update:)``.
    func shouldIgnoreMessage(_ message: MessageDTO) -> Bool {
        switch message.contentType {
        case .inactivityPopup:
            LogManager.trace("Ignoring message – content is inactivity popup")
            
            return true
        case .satisfactionSurvey:
            LogManager.trace("Ignoring message – content is satisfaction survey")
            
            return true
        case .text(let payload):
            if payload.parameters.contains(.isBeginLiveChatConversation, withValue: .bool(true)) {
                LogManager.trace("Ignoring message – content is begin live conversation")
                
                return true
            } else if payload.parameters.contains(.isUnsupportedMessageTypeAnswer, withValue: .bool(true)) {
                LogManager.trace("Ignoring message - content is unsupported message type answer")
                
                return true
            } else if payload.parameters.contains(.isInactivityPopupAnswer, withValue: .bool(true)) {
                LogManager.trace("Ignoring message - content is inactivity popup answer")
                
                return true
            } else {
                return false
            }
        default:
            return false
        }
    }
    
    /// - Throws: ``CXoneChatError/illegalChatState`` if the chat thread is already closed.
    /// - Throws: ``CXoneChatError/attachmentError`` if the provided attachment was unable to be sent.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if attachments upload `url` has not been set properly or attachment uploaded data object is missing
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the outbound message has no ``OutboundMessage/postback``,
    ///   empty ``OutboundMessage/text``, and empty ``OutboundMessage/attachments``.
    /// - Throws: ``CXoneChatError/invalidFileSize`` if size of the attachment exceeds the allowed size
    /// - Throws: ``CXoneChatError/invalidFileType`` if type of the attachment is not included in the allowed file MIME type
    /// - Throws: ``CXoneChatError/invalidData`` if the conversion from object instance to data failed
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
    /// - Throws: `URLError.badServerResponse` if the URL Loading system received bad data from the server.
    /// - Throws: `NSError` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    /// - Throws: An error if any value throws an error during encoding.
    func sendBeginLiveChatConversation() async throws {
        LogManager.trace("Sending begin conversation content to create a live chat thread.")
        
        try await send(
            message: OutboundMessage(text: ChatThreadService.beginLiveChatConversationMessage),
            parameters: [.isBeginLiveChatConversation: .bool(true)]
        )
    }
    
    func sendUnsupportedMessageTypeAnswer(fallbackText: String?) async throws {
        LogManager.trace("Sending hidden message to an agent about unsupported message received from the backend")
        
        let format = fallbackText?.isEmpty == true ? "%@" : "%@: %@"
        let text = String(format: format, ChatThreadService.unsupportedMessageTypeAnswerMessage, fallbackText ?? "")
        
        try await send(
            message: OutboundMessage(text: text),
            parameters: [.isUnsupportedMessageTypeAnswer: .bool(true)]
        )
    }
}

// MARK: - EventReceiver

extension ChatThreadService: EventReceiver {
    
    func processMoreMessagesLoaded(_ event: MoreMessagesLoadedEventDTO) {
        LogManager.trace("More messages loaded for thread: \(chatThread.id)")
            
        let messages = event.postback.data.messages.filter { message in
            !shouldIgnoreMessage(message)
        }

        // An empty page means there are no older messages
        let scrollToken = event.postback.data.messages.isEmpty ? "" : event.postback.data.scrollToken

        merge(messages) { thread in
            thread.copy(scrollToken: scrollToken)
        }

        broadcaster.send(.threadUpdated(chatThread))
    }

    /// - Throws: ``CXoneChatError/invalidData`` if the message content type is not `.inactivityPopup`.
    func processInactivityPopup(_ message: MessageDTO) throws {
        LogManager.trace("Processing inactivity popup message for thread: \(chatThread.id)")
        
        let inactivityPopup = try InactivityPopupMapper.map(from: message)

        broadcaster.send(.proactiveActionReceived(.inactivityPopup(inactivityPopup)))
    }

    /// - Throws: ``CXoneChatError/invalidData`` if the message content type is not `.satisfactionSurvey`.
    func processSatisfactionSurvey(_ message: MessageDTO) throws {
        LogManager.trace("Processing satisfaction survey message for thread: \(chatThread.id)")

        let satisfactionSurvey = try SatisfactionSurveyMapper.map(from: message, threadId: chatThread.id)

        broadcaster.send(.proactiveActionReceived(.satisfactionSurvey(satisfactionSurvey)))
    }
}

// MARK: - Private methods

private extension ChatThreadService {

    /// Changes the thread in one atomic step, then removes the local welcome message if `backendWelcomeMessage` is given
    /// or the backend's copy has replaced it before.
    ///
    /// `transform` runs inside the thread's lock, so it must not log - a log writer reading the thread would deadlock.
    ///
    /// - Parameter backendWelcomeMessage: The backend's copy of the welcome message among the written messages, if any.
    ///   Mapped by the caller before the thread's lock is taken - mapping can log.
    func replaceThread(ifReplacingLocalWelcomeMessageWith backendWelcomeMessage: Message?, transform: @Sendable (ChatThread) -> ChatThread) {
        let isLocalWelcomeMessageRemoved = _chatThread.mutate { thread -> Bool in
            thread = transform(thread)

            // Decided inside the thread's lock, so no other write to the thread can bring the local copy back in between.
            // Marked as replaced in every state - a send that reported an error may still have reached the backend.
            if let backendWelcomeMessage {
                _localWelcomeMessage.mutate { localWelcomeMessage in
                    // Not overwritten once replaced - `reconcilingReplacedLocalWelcomeMessage(in:)` keeps the stored copy current
                    if case .replaced? = localWelcomeMessage {
                        return
                    } else if let messageId = localWelcomeMessage?.messageId {
                        localWelcomeMessage = .replaced(messageId: messageId, backendWelcomeMessage: backendWelcomeMessage)
                    }
                }
            }

            // Applied after `transform`, because a recovered thread built from an earlier snapshot can still contain it
            let messageCount = thread.messages.count
            thread = reconcilingReplacedLocalWelcomeMessage(in: thread)

            return thread.messages.count != messageCount
        }

        // Logged outside the thread's lock, see above
        if isLocalWelcomeMessageRemoved {
            LogManager.trace("Replaced the local welcome message with the one from the backend")
        }
    }

    /// The reference to the current thread attached to outbound events.
    var threadDTO: ThreadDTO {
        ThreadDTO(idOnExternalPlatform: chatThread.id, threadName: chatThread.name)
    }

    /// Refreshes an expiring credential — an implicit-flow connection token or an explicit-flow OAuth access
    /// token — before it is embedded into an outbound payload.
    ///
    /// No-op when no credential is near expiry. Routes through the socket delegate's single-flighted
    /// `refreshToken()`, which already branches on ``ConnectionContext/authenticationType`` (implicit vs.
    /// explicit PKCE), so this helper owns only the "is a refresh due?" trigger, not the refresh itself.
    /// Throws ``CXoneChatError/invalidAccessToken`` when the implicit token is expiring but no token delegate
    /// listener is registered to refresh it, or when no socket delegate is available at all.
    func refreshConnectionTokenIfNeeded() async throws {
        guard connectionContext.needsProactiveTokenRefresh else {
            return
        }

        if connectionContext.isImplicitConnectionTokenExpiring {
            guard connectionContext.tokenDelegateListener != nil else {
                LogManager.warning("Implicit OAuth connection token is expiring but no token delegate listener is registered")

                throw CXoneChatError.invalidAccessToken
            }
        }

        guard let socketDelegate = socketService.delegate else {
            LogManager.warning("The credential is expiring but the socket delegate is unavailable to refresh it")

            throw CXoneChatError.invalidAccessToken
        }

        if connectionContext.isImplicitConnectionTokenExpiring {
            LogManager.trace("Implicit OAuth: refreshing an expiring connection token before sending")
        } else {
            LogManager.trace("Explicit PKCE: refreshing an expired access token before sending")
        }

        try await socketDelegate.refreshToken()
    }

    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
    @MainActor
    func sendWelcomeMessageIfNeeded() async throws {
        // Wait for a welcome message send started by a concurrent `send(_:)`, so the customer's message cannot overtake it.
        // The send leaves the `.sending` state before it finishes; if it failed, the welcome message can be sent below again.
        while case .sending(_, let welcomeMessageSend) = _localWelcomeMessage.content {
            _ = await welcomeMessageSend.result
        }

        // Checked and claimed in one step inside the thread's lock, so a backend message merged meanwhile cannot slip
        // in front of the welcome message, and a concurrent `send(_:)` waits for this send instead of starting its own.
        // The task cannot start before it is stored - both run on the main actor.
        let welcomeMessageSend = _chatThread.mutate { thread -> Task<Void, any Error>? in
            guard thread.messages.count == 1,
                  let welcomeMessage = thread.messages.first,
                  case .text(let message) = welcomeMessage.contentType
            else {
                return nil
            }

            return _localWelcomeMessage.mutate { localWelcomeMessage -> Task<Void, any Error>? in
                guard case .notSent(welcomeMessage.id) = localWelcomeMessage else {
                    return nil
                }

                // Weak, so the stored task does not keep a dropped service alive before it starts;
                // once running, it holds the service until the send returns
                let welcomeMessageSend = Task { @MainActor [weak self] in
                    guard let self else {
                        return
                    }

                    do {
                        try await sendWelcomeMessage(message.text)

                        finishWelcomeMessageSend(messageId: welcomeMessage.id, didSend: true)
                    } catch {
                        // Lets a later `send(_:)` send it again - with the same ID, see `welcomeMessageOutboundId`
                        finishWelcomeMessageSend(messageId: welcomeMessage.id, didSend: false)

                        throw error
                    }
                }

                localWelcomeMessage = .sending(messageId: welcomeMessage.id, task: welcomeMessageSend)

                return welcomeMessageSend
            }
        }

        do {
            // Not cancelled together with this `send(_:)` - a concurrent `send(_:)` may be waiting for it
            try await welcomeMessageSend?.value
        } catch {
            switch _localWelcomeMessage.content {
            case .replaced?, .discarded?, nil:
                // The welcome message is known to be on the backend - its copy replaced the local one, or the thread
                // was replaced with its backend state - so the customer's message is sent as usual
                break
            default:
                // Not known to be on the backend - a later `send(_:)` sends it again, possibly one waiting right now
                throw error
            }
        }
    }

    /// The backend's copy of the welcome message among `messages`, taken from `mappedMessages` that were already mapped from them.
    func backendWelcomeMessage(in messages: [MessageDTO], mappedMessages: [Message]) -> Message? {
        guard let welcomeMessage = messages.first(where: \.isWelcomeMessage) else {
            return nil
        }

        return mappedMessages.first { message in
            message.id == welcomeMessage.idOnExternalPlatform
        }
    }

    /// Replaces the local welcome message in `thread` with the backend's copy, once the backend's copy has replaced it.
    ///
    /// Besides removing the local copy, it re-adds the stored backend copy when `thread` lacks it,
    /// and stores the thread's newer version of the backend copy when `thread` has one.
    /// Once the thread was replaced with its backend state (`.discarded`), it only removes the local copy.
    ///
    /// Applied to every write to the thread, so one built from an earlier snapshot cannot bring the local copy back.
    /// It also puts the backend's copy back when such a snapshot does not have it, so the welcome message does not disappear.
    /// Called inside the thread's lock, so it must not log.
    func reconcilingReplacedLocalWelcomeMessage(in thread: ChatThread) -> ChatThread {
        switch _localWelcomeMessage.content {
        case .replaced(let messageId, let backendWelcomeMessage):
            return reconcilingReplacedLocalWelcomeMessage(in: thread, messageId: messageId, backendWelcomeMessage: backendWelcomeMessage)
        case .discarded(let messageId):
            let messages = thread.messages.filter { message in
                message.id != messageId
            }

            return messages.count == thread.messages.count ? thread : thread.copy(messages: messages)
        default:
            return thread
        }
    }

    /// Removes the local copy `messageId` from `thread` and keeps `backendWelcomeMessage` in it - see ``reconcilingReplacedLocalWelcomeMessage(in:)``.
    func reconcilingReplacedLocalWelcomeMessage(in thread: ChatThread, messageId: String, backendWelcomeMessage: Message) -> ChatThread {
        let messages = thread.messages.filter { message in
            message.id != messageId
        }

        let currentBackendWelcomeMessage = messages.first { message in
            message.id == backendWelcomeMessage.id
        }

        if let currentBackendWelcomeMessage {
            // The thread's version is the latest one (seen, read) - kept for a later write that lacks the copy
            if currentBackendWelcomeMessage != backendWelcomeMessage {
                _localWelcomeMessage.mutate { localWelcomeMessage in
                    localWelcomeMessage = .replaced(messageId: messageId, backendWelcomeMessage: currentBackendWelcomeMessage)
                }
            }

            return messages.count == thread.messages.count ? thread : thread.copy(messages: messages)
        } else {
            return thread.copy(messages: messages).merged(with: [backendWelcomeMessage])
        }
    }

    /// Leaves the `.sending` state of the welcome message `messageId` - unless the backend's copy has meanwhile replaced
    /// the local one, or the thread was replaced with its backend state.
    func finishWelcomeMessageSend(messageId: String, didSend: Bool) {
        _localWelcomeMessage.mutate { localWelcomeMessage in
            if case .sending(messageId, _) = localWelcomeMessage {
                localWelcomeMessage = didSend ? .sent(messageId: messageId) : .notSent(messageId: messageId)
            }
        }
    }

    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
    @MainActor
    func sendWelcomeMessage(_ text: String) async throws {
        LogManager.trace("Sending an outbound message.")

        try socketService.checkForConnection()

        // Ensure the credential (implicit JWT or explicit transaction token) is fresh BEFORE it is embedded
        // into the outbound payload below.
        try await refreshConnectionTokenIfNeeded()

        let customFields = contactCustomFieldsService?.contactFields[chatThread.id]?.convertValueToIdentifier(
            with: connectionContext.channelConfig.prechatSurvey?.customFields
        )

        let eventData = EventDataType.sendOutboundMessageData(
            SendOutboundMessageEventDataDTO(
                thread: threadDTO,
                contentType: .text(MessagePayloadDTO(text: text, postback: nil, parameters: [MessageParameter.isWelcomeMessage: .bool(true)])),
                idOnExternalPlatform: welcomeMessageOutboundId,
                contactCustomFields: customFields ?? [],
                attachments: [],
                deviceFingerprint: DeviceFingerprintDTO(deviceToken: connectionContext.deviceToken),
                token: connectionContext.effectiveAccessToken
            )
        )
        
        let data = try eventsService.create(.sendOutbound, with: eventData)

        // Subscribed before sending, so the backend's copy cannot arrive before the SDK listens for it.
        // Cancelled on every exit, which also ends the subscription.
        let backendWelcomeMessage = waitForBackendWelcomeMessage(in: eventBroadcast.makeStream(), threadId: chatThread.id)
        defer {
            backendWelcomeMessage.cancel()
        }

        // The credential was already freshened by `refreshConnectionTokenIfNeeded()` above and embedded into
        // `eventData`; skip the choke-point re-check so a single refresh runs per event.
        try await socketService.send(data: data, shouldCheck: false)

        // The backend handles the welcome message and the customer's message independently, so a customer's message sent
        // right away can be stored first and the thread, sorted by the backend's times, shows it above the welcome message.
        // Once the backend's copy arrives, the welcome message is stored, so the customer's message is stored after it.
        let waitStart = ContinuousClock.now

        let didReceiveBackendWelcomeMessage = await withTaskGroup(of: Bool.self) { group in
            group.addTask {
                await backendWelcomeMessage.value
            }
            group.addTask {
                try? await Task.sleep(seconds: Self.backendWelcomeMessageTimeout)

                return false
            }

            let didReceive = await group.next() ?? false

            // Cancelling the group does not cancel the awaited task, and the group waits for all its tasks before returning
            backendWelcomeMessage.cancel()
            group.cancelAll()

            return didReceive
        }

        // The customer's message is shown only after this wait, so its length is logged to confirm it stays short
        let waitDuration = ContinuousClock.now - waitStart

        if didReceiveBackendWelcomeMessage {
            LogManager.trace("The backend's copy of the welcome message arrived after \(waitDuration)")
        } else {
            // Not blocking the customer's message - it is sent anyway, at the risk of being shown above the welcome message
            LogManager.warning(
                "The backend's copy of the welcome message did not arrive within \(waitDuration) (timeout or connection reset), "
                    + "sending the customer's message anyway"
            )
        }
    }

    /// Starts listening for the backend's copy of the welcome message in thread `threadId`.
    ///
    /// - Returns: A task that returns `true` once the copy arrives, or `false` when the connection resets first.
    func waitForBackendWelcomeMessage(in events: AsyncStream<any ReceivedEvent>, threadId: String) -> Task<Bool, Never> {
        Task {
            for await event in events {
                if event is EventBroadcast.BroadcastInvalidatedEvent {
                    return false
                }

                if let event = event as? MessageCreatedEventDTO,
                   event.data.message.isWelcomeMessage,
                   event.data.thread.idOnExternalPlatform.lowercased() == threadId.lowercased() {
                    return true
                }
            }

            return false
        }
    }
}

// MARK: - LocalWelcomeMessage

private extension ChatThreadService {

    /// The welcome message the SDK added to a new thread itself.
    enum LocalWelcomeMessage: Sendable {

        // MARK: - Cases

        /// Not sent to the backend yet - it is sent before the customer's first message.
        case notSent(messageId: String)
        /// Being sent to the backend. A concurrent `send(_:)` waits for `task` before sending its own message.
        case sending(messageId: String, task: Task<Void, any Error>)
        /// Sent to the backend - waiting for the backend's copy of it to replace the local one.
        case sent(messageId: String)
        /// Replaced with `backendWelcomeMessage`. Every later write has the local copy removed and the backend's copy kept,
        /// so one built from an earlier snapshot neither brings the local copy back nor drops the welcome message.
        case replaced(messageId: String, backendWelcomeMessage: Message)
        /// The thread was replaced with its backend state, which already has the welcome message. Every later write
        /// has the local copy removed, so one built from an earlier snapshot cannot bring it back; it is never sent again.
        case discarded(messageId: String)

        // MARK: - Properties

        var messageId: String {
            switch self {
            case .notSent(let messageId), .sending(let messageId, _), .sent(let messageId), .replaced(let messageId, _), .discarded(let messageId):
                return messageId
            }
        }
    }
}

// MARK: - ContentDescriptor Mapper

private extension [ContentDescriptor] {
    
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if attachments upload `url` has not been set properly or attachment uploaded data object is missing.
    /// - Throws: ``CXoneChatError/attachmentError`` if the provided attachment was unable to be sent.
    /// - Throws: ``CXoneChatError/invalidFileSize`` if size of the attachment exceeds the allowed size
    /// - Throws: ``CXoneChatError/invalidFileType`` if type of the attachment is not included in the allowed file MIME type
    /// - Throws: ``CXoneChatError/invalidData`` if the conversion from object instance to data failed.
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
    /// - Throws: `URLError.badServerResponse` if the URL Loading system received bad data from the server.
    /// - Throws: `NSError` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    /// - Throws: An error if any value throws an error during encoding.
    func map(
        with connectionContext: ConnectionContext,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> [AttachmentDTO] {
        guard !self.isEmpty else {
            return []
        }
        
        let chatURL = connectionContext.environment.chatServerUrl?.channelUrl(brandId: connectionContext.brandId, channelId: connectionContext.channelId)

        guard let url = chatURL / "attachment" else {
            throw CXoneChatError.missingParameter("url")
        }
        
        var request = URLRequest(url: url, method: .post, contentType: "application/json")

        let returned = try await self.asyncMap { attachment in
            let fileRestrictions = connectionContext.channelConfig.settings.fileRestrictions
            request.httpBody = try await attachment.httpBody(fileRestrictions: fileRestrictions)
            
            let (data, response) = try await connectionContext.session.fetch(for: request, file: file, line: line)

            guard let response = response as? HTTPURLResponse, response.isSuccess else {
                throw CXoneChatError.serverError
            }
            
            if let decoded: AttachmentUploadFailResponseDTO = try? data.decode() {
                if decoded.allowedFileSize < Double(fileRestrictions.allowedFileSize) {
                    throw CXoneChatError.invalidFileSize
                } else {
                    throw CXoneChatError.invalidFileType
                }
            }
            
            guard let decoded: AttachmentUploadSuccessResponseDTO = try data.decode() else {
                throw CXoneChatError.invalidData
            }
            
            return AttachmentDTO(
                url: decoded.fileUrl,
                friendlyName: attachment.friendlyName,
                mimeType: attachment.mimeType,
                fileName: attachment.fileName
            )
        }
        
        guard returned.count >= self.count else {
            throw CXoneChatError.attachmentError
        }
        
        return returned
    }
}

// MARK: - Helpers

private extension ContentDescriptorSource {
    
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    func fetch() async throws -> Data {
        switch self {
        case .bytes(let data):
            return data
        case .url(let url):
            if url.isStoredInDocuments() {
                return try Data(contentsOf: url)
            } else {
                return try await url.readSecureData()
            }
        }
    }
}

private extension ContentDescriptor {

    static let megabyte: Int32 = 1024 * 1024
    static let encoder = JSONEncoder()
    
    /// - Throws: ``CXoneChatError/invalidFileSize`` if size of the attachment exceeds the allowed size
    /// - Throws: ``CXoneChatError/invalidFileType`` if type of the attachment is not included in the allowed file MIME type
    /// - Throws: `EncodingError.invalidValue(_:_:)` if the given value is invalid in the current context for this format.
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    /// - Throws: An error if any value throws an error during encoding.
    func httpBody(fileRestrictions: FileRestrictionsDTO) async throws -> Data {
        let fileData = try await self.data.fetch()
        
        // File type validation
        guard fileData.count <= (fileRestrictions.allowedFileSize * Self.megabyte) else {
            throw CXoneChatError.invalidFileSize
        }
        
        // Validate File type
        guard try mimeType.isTypeValid(allowedTypes: fileRestrictions.allowedFileTypes.map(\.mimeType)) else {
            throw CXoneChatError.invalidFileType
        }
        
        return try Self.encoder.encode([
            "content": fileData.base64EncodedString(),
            "fileName": self.fileName,
            "mimeType": self.mimeType
        ])
    }
}

private extension String {
    
    /// - Throws: ``CXoneChatError/attachmentError`` if the MIME type of the attachment could not be resolved.
    func isTypeValid(allowedTypes: [String]) throws -> Bool {
        let allowedMimeTypes = allowedTypes.compactMap(Self.resolve)
        
        guard let fileMimeType = Self.resolve(for: self) else {
            throw CXoneChatError.attachmentError
        }
        
        return allowedMimeTypes.contains(fileMimeType) || allowedMimeTypes.contains { $0.isSupertype(of: fileMimeType) }
    }
    
    static func resolve(for mimeType: String) -> UTType? {
        guard mimeType.contains("*") else {
            return UTType(mimeType: mimeType)
        }
        
        switch mimeType {
        case "video/*":
            return .movie
        case "image/*":
            return .image
        default:
            guard let contentType = mimeType.split(separator: "/").first else {
                return nil
            }
            
            return UTType("public.\(contentType)")
        }
    }
}

private extension URL {

    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    func readSecureData() async throws -> Data {
        try accessSecurelyScopedResource { url in
            try Data(contentsOf: url)
        }
    }

    func isStoredInDocuments() -> Bool {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        return absoluteString.starts(with: documentsURL.absoluteString)
    }
}

private extension [CustomFieldDTO] {
    
    /// Replaces the value of the custom field with the identifier value.
    ///
    /// This method replaces gender "Male" for its value identifier "gender-male".
    /// This is necessary because the server expects the value identifier.
    mutating func convertValueToIdentifier(with prechatDefinitions: [PreChatSurveyCustomFieldDTO]?) -> [CustomFieldDTO] {
        compactMap { customField in
            let definition = prechatDefinitions?.first { prechatField in
                prechatField.type.isOptionValue(customField.value)
            }
            
            return CustomFieldDTO(
                ident: customField.ident,
                value: definition?.type.getValueIdentifier(for: customField.value) ?? customField.value,
                updatedAt: customField.updatedAt
            )
        }
    }
}
