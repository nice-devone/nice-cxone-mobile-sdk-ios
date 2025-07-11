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
import Foundation
import UniformTypeIdentifiers

class ChatThreadService {
    
    // MARK: - Properties
    
    static let beginLiveChatConversationMessage = "__Begin Live Chat Conversation__"
    
    let socketService: SocketService
    let eventsService: EventsService
    
    let delegate: CXoneChatDelegate
    
    private let contactCustomFieldsProvider: ContactCustomFieldsProvider
    private let customerCustomFieldsProvider: CustomerCustomFieldsProvider
    private let welcomeMessageManager: WelcomeMessageManager
    
    private var parsedWelcomeMessage: String?
    
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
    
    var chatThread: ChatThread
    
    var events: AnyPublisher<any ReceivedEvent, Never> {
        socketService.events
    }
    var cancellables: [AnyCancellable] {
        get { socketService.cancellables }
        set { socketService.cancellables = newValue }
    }
    
    // MARK: - Init
    
    init(
        chatThread: ChatThread,
        contactFieldsProvider: ContactCustomFieldsProvider,
        customerFieldsProvider: CustomerCustomFieldsProvider,
        socketService: SocketService,
        eventsService: EventsService,
        welcomeMessageManager: WelcomeMessageManager,
        delegate: CXoneChatDelegate
    ) {
        self.chatThread = chatThread
        self.contactCustomFieldsProvider = contactFieldsProvider
        self.customerCustomFieldsProvider = customerFieldsProvider
        self.socketService = socketService
        self.eventsService = eventsService
        self.welcomeMessageManager = welcomeMessageManager
        self.delegate = delegate
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
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.``
    func loadMoreMessages() async throws {
        LogManager.trace("Loading more messages.")
        
        try socketService.checkForConnection()

        guard chatThread.hasMoreMessagesToLoad else {
            throw CXoneChatError.noMoreMessages
        }
        guard let oldestDate = chatThread.messages.first?.createdAt else {
            throw CXoneChatError.invalidOldestDate
        }
        
        let thread = ThreadDTO(idOnExternalPlatform: chatThread.id, threadName: chatThread.name)
        let event = try eventsService.create(
            event: .loadMoreMessages,
            with: .loadMoreMessageData(LoadMoreMessagesEventDataDTO(scrollToken: chatThread.scrollToken, thread: thread, oldestMessageDatetime: oldestDate))
        )
        
        let response = try await events.sink(
            type: .moreMessagesLoaded,
            as: MoreMessagesLoadedEventDTO.self,
            origin: event,
            socketService: socketService,
            eventsService: eventsService,
            cancellables: &cancellables
        )
        
        processMoreMessagesLoaded(response)
    }
    
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
    /// - Throws: ``CXoneChatError/eventTimeout`` if the SDK did not receive a response within the specified time.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    /// - Throws: An error if any value throws an error during encoding.
    func send(_ message: OutboundMessage) async throws { // swiftlint:disable:this function_body_length
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

        let contactFields = contactCustomFieldsService?.contactFields[chatThread.id]?.convertValueToIdentifier(
            with: connectionContext.channelConfig.prechatSurvey?.customFields
        )
        let customerFields = customerCustomFieldsService?.customerFields.convertValueToIdentifier(
            with: connectionContext.channelConfig.prechatSurvey?.customFields
        )
        
        if message.text != Self.beginLiveChatConversationMessage {
            try await sendWelcomeMessageIfNeeded()
        }
        
        let messageData = SendMessageEventDataDTO(
            thread: ThreadDTO(idOnExternalPlatform: chatThread.id, threadName: chatThread.name),
            contentType: .text(MessagePayloadDTO(text: message.text, postback: message.postback)),
            idOnExternalPlatform: UUID.provide(),
            customer: CustomerCustomFieldsDataDTO(customFields: customerFields ?? []),
            contact: ContactCustomFieldsDataDTO(customFields: contactFields ?? []),
            attachments: try await message.attachments.map(with: connectionContext),
            deviceFingerprint: DeviceFingerprintDTO(deviceToken: connectionContext.deviceToken),
            token: socketService.accessToken.map(\.token)
        )
        
        let newMessage: Message? = message.text != Self.beginLiveChatConversationMessage ? {
            chatThread.messages.append(
                MessageMapper.map(
                    from: messageData,
                    payload: MessagePayload(text: message.text, postback: message.postback),
                    authorUser: chatThread.assignedAgent,
                    customer: connectionContext.customer.map(CustomerIdentityMapper.map)
                )
            )
            
            delegate.onThreadUpdated(chatThread)
            
            return chatThread.messages.last
        }() : nil
        
        do {
            try await events.sink(
                dataType: GenericEventDTO.self,
                origin: try eventsService.create(event: .sendMessage, with: .sendMessageData(messageData)),
                socketService: socketService,
                eventsService: eventsService,
                cancellables: &cancellables
            )
            
            LogManager.trace("Message \(messageData.idOnExternalPlatform) sucessfully added into thread \(chatThread.id)")
        } catch {
            LogManager.error("Failed to send message: \(error)")
            
            // Update it only when the message was appended to the thread
            if var newMessage {
                newMessage.status = .failed
                
                chatThread.messages.removeLast()
                chatThread.messages.append(newMessage)
                
                delegate.onThreadUpdated(chatThread)
            }
            
            throw error
        }
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func updateName(_ name: String) async throws {
        LogManager.trace("Updating the name for a thread")

        try socketService.checkForConnection()

        guard connectionContext.channelConfig.settings.hasMultipleThreadsPerEndUser else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        guard chatThread.state != .closed else {
            throw CXoneChatError.illegalThreadState
        }
        
        chatThread.name = name
        
        if chatThread.state == .ready {
            let data = try eventsService.create(
                .updateThread,
                with: .updateThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: chatThread.id, threadName: name)))
            )
            
            try await socketService.send(data: data)
        } else {
            LogManager.info("Thread does not contain any messages. Skipping message sending")
        }

        delegate.onThreadUpdated(chatThread)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/eventTimeout`` if the SDK did not receive a response within the specified time.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``OperationError`` if there is any operaton error received from the BE.
    func archive() async throws {
        LogManager.trace("Archiving thread")
        
        try socketService.checkForConnection()
        
        guard connectionContext.channelConfig.settings.hasMultipleThreadsPerEndUser else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        guard chatThread.state != .closed else {
            throw CXoneChatError.illegalChatState
        }
        
        if chatThread.state.isLoaded {
            LogManager.trace("Thread exists in BE - Archive via socket and wait for response")
            
            let event = try eventsService.create(
                event: .archiveThread,
                with: .archiveThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: chatThread.id, threadName: chatThread.name)))
            )
            
            try await events.sink(
                type: .threadArchived,
                as: GenericEventDTO.self,
                origin: event,
                socketService: socketService,
                eventsService: eventsService,
                cancellables: &cancellables
            )
            
            LogManager.trace("Thread Archived: \(chatThread.id)")
        } else {
            LogManager.trace("Thread does not exist in BE")
        }
        
        chatThread.state = .closed
        
        delegate.onThreadUpdated(chatThread)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if the `contactId` has not been set properly or it was unable to unwrap it as a required type.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func endContact() async throws {
        LogManager.trace("Sending EndContactEvent")
        
        try socketService.checkForConnection()
        
        guard connectionContext.chatMode == .liveChat else {
            throw CXoneChatError.illegalChatState
        }
        guard chatThread.state != .closed else {
            LogManager.info("Conversation has been already closed -> ignoring this request")
            
            delegate.onThreadUpdated(chatThread)
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
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
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
            with: .messageSeenByCustomer(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: chatThread.id, threadName: chatThread.name)))
        )
        
        try await socketService.send(data: data)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func reportTypingStart(_ didStart: Bool) async throws {
        LogManager.trace("Reporting user start typing")

        try socketService.checkForConnection()

        guard chatThread.state != .closed else {
            throw CXoneChatError.illegalThreadState
        }
        
        let data = try eventsService.create(
            didStart ? .senderTypingStarted : .senderTypingEnded,
            with: .customerTypingData(CustomerTypingEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: chatThread.id, threadName: chatThread.name)))
        )
        
        try await socketService.send(data: data)
    }
}

// MARK: - Internal methods

extension ChatThreadService {
    
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the provided ID for the thread was invalid, so the action could not be performed.
    func handleWelcomeMessage(_ message: String) throws {
        guard chatThread.state == .pending else {
            // No available thread for handling welcome message or
            // no need to handle welcome message for thread that exists on the BE side -> first message should be the welcome message
            return
        }
        guard chatThread.messages.isEmpty else {
            // Thread already contains some messages -> no need to append welcome message because it has been already added
            return
        }
        
        chatThread.merge(messages: [try getParsedWelcomeMessage(message)])
        
        delegate.onThreadUpdated(chatThread)
    }
    
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    func getParsedWelcomeMessage(_ welcomeMessage: String) throws -> Message {
        guard let customer = connectionContext.customer else {
            throw CXoneChatError.customerAssociationFailure
        }

        let contactFields = contactCustomFieldsService?.contactFields[chatThread.id] ?? []
        let customerFields = customerCustomFieldsService?.customerFields ?? []
        
        let parsedMessage = welcomeMessageManager.parse(welcomeMessage, contactFields: contactFields, customerFields: customerFields, customer: customer)
        self.parsedWelcomeMessage = parsedMessage
        
        return Message(
            id: UUID.provide(),
            threadId: chatThread.id,
            contentType: .text(MessagePayload(text: parsedMessage, postback: nil)),
            createdAt: Date.provide(),
            attachments: [],
            direction: .toClient,
            userStatistics: nil,
            authorUser: nil,
            authorEndUserIdentity: CustomerIdentityMapper.map(customer),
            status: .sent
        )
    }
    
    /// Some messages should not appear into the chat history because of specific reason,
    /// e.g. Begin live chat conversation = Live chat thread is created with hard coded message
    /// that we don't want to present to the user
    func shouldIgnoreMessage(_ message: MessageDTO, threadState: ChatThreadState) -> Bool {
        guard case .text(let payload) = message.contentType else {
            return false
        }
        
        if let parsedWelcomeMessage, payload.text == parsedWelcomeMessage {
            LogManager.trace("Ignoring message – content is welcome message")
            
            self.parsedWelcomeMessage = nil
            
            // Ignore the welcome message only if the thread is in `.pending` state
            // (welcome message is appended manually in pending state, it does not yet exist in the chat history)
            return threadState == .pending
        } else if payload.text == Self.beginLiveChatConversationMessage {
            LogManager.trace("Ignoring message – content is begin live conversation")
            
            return true
        }
        
        return false
    }
    
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/attachmentError`` if the provided attachment was unable to be sent.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if attachments upload `url` has not been set properly or attachment uploaded data object is missing
    ///     or  when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the the outbound message has no ``postback``, empty ``text``, and empty ``attachments``.
    /// - Throws: ``CXoneChatError/noSuchFile`` if an attached file could not be found.
    /// - Throws: ``CXoneChatError/invalidFileSize`` if size of the attachment exceeds the allowed size
    /// - Throws: ``CXoneChatError/invalidFileType`` if type of the attachment is not included in the allowed file MIME type
    /// - Throws: ``CXoneChatError/invalidData`` if the conversion from object instance to data failed
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    /// - Throws: An error if any value throws an error during encoding.
    func sendBeginLiveChatConversation() async throws {
        LogManager.trace("Sending begin conversation content to create a live chat thread.")
        
        try await send(OutboundMessage(text: ChatThreadService.beginLiveChatConversationMessage))
    }
}

// MARK: - EventReceiver

extension ChatThreadService: EventReceiver {
    
    func processMoreMessagesLoaded(_ event: MoreMessagesLoadedEventDTO) {
        LogManager.trace("More messages loaded for thread: \(chatThread.id)")
            
        if event.postback.data.messages.isEmpty {
            chatThread.scrollToken.removeAll()
        } else {
            let messages = event.postback.data.messages
                .filter { !shouldIgnoreMessage($0, threadState: chatThread.state) }
                .map(MessageMapper.map)

            chatThread.merge(messages: messages)
            chatThread.scrollToken = event.postback.data.scrollToken
        }
        
        delegate.onThreadUpdated(chatThread)
    }
}

// MARK: - Private methods

private extension ChatThreadService {
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func sendWelcomeMessageIfNeeded() async throws {
        guard let parsedWelcomeMessage,
              chatThread.messages.count == 1,
              case .text(let message) = chatThread.messages.first?.contentType,
              parsedWelcomeMessage == message.text
        else {
            return
        }
        
        LogManager.trace("Sending an outbound message.")

        try socketService.checkForConnection()
        
        let customFields = contactCustomFieldsService?.contactFields[chatThread.id]?.convertValueToIdentifier(
            with: connectionContext.channelConfig.prechatSurvey?.customFields
        )
        
        let eventData = EventDataType.sendOutboundMessageData(
            SendOutboundMessageEventDataDTO(
                thread: ThreadDTO(
                    idOnExternalPlatform: chatThread.id,
                    threadName: chatThread.messages.isEmpty ? nil : chatThread.name
                ),
                contentType: .text(MessagePayloadDTO(text: message.text, postback: nil)),
                idOnExternalPlatform: UUID.provide(),
                contactCustomFields: customFields ?? [],
                attachments: [],
                deviceFingerprint: DeviceFingerprintDTO(deviceToken: connectionContext.deviceToken),
                token: socketService.accessToken.map(\.token)
            )
        )
        
        let data = try eventsService.create(.sendOutbound, with: eventData)
        
        try await socketService.send(data: data)
    }
}

// MARK: - ContentDescriptor Mapper

private extension [ContentDescriptor] {
    
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if attachments upload `url` has not been set properly or attachment uploaded data object is missing.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/attachmentError`` if the provided attachment was unable to be sent.
    /// - Throws: ``CXoneChatError/noSuchFile`` if an attached file could not be found.
    /// - Throws: ``CXoneChatError/invalidFileSize`` if size of the attachment exceeds the allowed size
    /// - Throws: ``CXoneChatError/invalidFileType`` if type of the attachment is not included in the allowed file MIME type
    /// - Throws: ``CXoneChatError/invalidData`` if the conversion from object instance to data failed.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
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

            guard let response = response as? HTTPURLResponse, (200 ... 299) ~= response.statusCode else {
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
    
    /// - Throws: ``CXoneChatError/noSuchFile`` if an attached file could not be found.
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    func fetch() async throws -> Data {
        switch self {
        case .bytes(let data):
            return data
        case .url(let url):
            if url.isStoredInDocuments() {
                return try Data(contentsOf: url)
            }
            
            return try await url.readSecureData()
        }
    }
}

private extension ContentDescriptor {

    static let megabyte: Int32 = 1024 * 1024
    
    /// - Throws: ``CXoneChatError/noSuchFile`` if an attached file could not be found.
    /// - Throws: ``CXoneChatError/invalidFileSize`` if size of the attachment exceeds the allowed size
    /// - Throws: ``CXoneChatError/invalidFileType`` if type of the attachment is not included in the allowed file MIME type
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
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
        
        return try JSONEncoder().encode([
            "content": fileData.base64EncodedString(),
            "fileName": self.fileName,
            "mimeType": self.mimeType
        ])
    }
}

private extension String {
    
    /// - Throws: ``CXoneChatError/noSuchFile`` if the provided attachment was unable to be sent.
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

    /// - Throws: ``CXoneChatError/noSuchFile`` if an attached file could not be found.
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
    
    func channelUrl(brandId: Int, channelId: String) -> URL? {
        self / "1.0" / "brand" / brandId / "channel" / channelId
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
