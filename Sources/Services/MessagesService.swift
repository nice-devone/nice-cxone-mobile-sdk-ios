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

import Foundation
import UniformTypeIdentifiers

class MessagesService: MessagesProvider {
    
    // MARK: - Properties
    
    static let beginLiveChatConversationMessage = "__Begin Live Chat Conversation__"
    
    let socketService: SocketService
    let eventsService: EventsService
    
    let delegate: CXoneChatDelegate

    private let contactFieldsProvider: ContactCustomFieldsProvider
    private let customerFieldsProvider: CustomerCustomFieldsProvider
    private let welcomeMessageManager: WelcomeMessageManager
    
    private var parsedWelcomeMessage: String?
    
    private var connectionContext: ConnectionContext {
        socketService.connectionContext
    }
    
    // MARK: - Init
    
    init(
        contactFieldsProvider: ContactCustomFieldsProvider,
        customerFieldsProvider: CustomerCustomFieldsProvider,
        socketService: SocketService,
        eventsService: EventsService,
        welcomeMessageManager: WelcomeMessageManager,
        delegate: CXoneChatDelegate
    ) {
        self.contactFieldsProvider = contactFieldsProvider
        self.customerFieldsProvider = customerFieldsProvider
        self.socketService = socketService
        self.eventsService = eventsService
        self.welcomeMessageManager = welcomeMessageManager
        self.delegate = delegate
    }
    
    // MARK: - Implementation
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/noMoreMessages`` if there aren't any other messages, so additional messages could not be loaded.
    /// - Throws: ``CXoneChatError/invalidOldestDate`` if Thread is missing the timestamp of when the message was created.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.``
    func loadMore(for chatThread: ChatThread) throws {
        LogManager.trace("Loading more messages.")

        try socketService.checkForConnection()

        guard chatThread.hasMoreMessagesToLoad else {
            throw CXoneChatError.noMoreMessages
        }
        guard let oldestDate = chatThread.messages.first?.createdAt else {
            throw CXoneChatError.invalidOldestDate
        }

        connectionContext.activeThread = chatThread
        
        let thread = ThreadDTO(idOnExternalPlatform: chatThread.id, threadName: chatThread.name)
        let data = try eventsService.create(
            .loadMoreMessages,
            with: .loadMoreMessageData(LoadMoreMessagesEventDataDTO(scrollToken: chatThread.scrollToken, thread: thread, oldestMessageDatetime: oldestDate))
        )
        
        try socketService.send(data: data)
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
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided thread was invalid, so the action could not be performed.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    /// - Throws: An error if any value throws an error during encoding.
    func send(_ message: OutboundMessage, for chatThread: ChatThread) async throws {
        LogManager.trace("Sending a message in the specified chat thread.")

        guard let threadIndex = connectionContext.threads.index(of: chatThread.id) else {
            throw CXoneChatError.invalidThread
        }
        guard chatThread.state != .closed else {
            throw CXoneChatError.illegalChatState
        }
        
        // Check if sending attachmnets is enabled
        guard message.attachments.isEmpty || connectionContext.channelConfig.settings.fileRestrictions.isAttachmentsEnabled else {
            throw CXoneChatError.attachmentError
        }
        guard message.postback != nil || !message.text.isEmpty || !message.attachments.isEmpty else {
            throw CXoneChatError.invalidParameter("attempt to send a message with no postback, text, or attachments")
        }

        try socketService.checkForConnection()

        let contactFields = (contactFieldsProvider as? ContactCustomFieldsService)?.contactFields[chatThread.id]?.convertValueToIdentifier(
            with: connectionContext.channelConfig.prechatSurvey?.customFields
        )
        let customerFields = (customerFieldsProvider as? CustomerCustomFieldsService)?.customerFields.convertValueToIdentifier(
            with: connectionContext.channelConfig.prechatSurvey?.customFields
        )
        
        try sendWelcomeMessageIfNeeded(for: chatThread)
        
        let mappedAttachments = try await message.attachments.map(with: connectionContext)
        
        let messageId = UUID.provide()
        
        let eventData = EventDataType.sendMessageData(
            SendMessageEventDataDTO(
                thread: ThreadDTO(idOnExternalPlatform: chatThread.id, threadName: chatThread.name),
                contentType: .text(MessagePayloadDTO(text: message.text, postback: message.postback)),
                idOnExternalPlatform: messageId,
                customer: CustomerCustomFieldsDataDTO(customFields: customerFields ?? []),
                contact: ContactCustomFieldsDataDTO(customFields: contactFields ?? []),
                attachments: mappedAttachments,
                deviceFingerprint: DeviceFingerprintDTO(deviceToken: connectionContext.deviceToken),
                token: socketService.accessToken.map(\.token)
            )
        )
        
        if message.text != Self.beginLiveChatConversationMessage {
            let message = Message(
                id: messageId,
                threadId: chatThread.id,
                contentType: .text(MessagePayload(text: message.text, postback: message.postback)),
                createdAt: Date.provide(),
                attachments: mappedAttachments.map(AttachmentMapper.map),
                direction: .toAgent,
                userStatistics: nil,
                authorUser: chatThread.assignedAgent,
                authorEndUserIdentity: connectionContext.customer.map(CustomerIdentityMapper.map)
            )
            
            connectionContext.threads[threadIndex].messages.append(message)
            
            delegate.onThreadUpdated(connectionContext.threads[threadIndex])
        }
        
        let data = try eventsService.create(.sendMessage, with: eventData)
        
        try socketService.send(data: data)
    }
}

// MARK: - Internal methods

extension MessagesService {
    
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    func getParsedWelcomeMessage(_ welcomeMessage: String, for thread: ChatThread) throws -> Message {
        guard let customer = connectionContext.customer else {
            throw CXoneChatError.customerAssociationFailure
        }

        let contactFields = (contactFieldsProvider as? ContactCustomFieldsService)?.contactFields[thread.id] ?? []
        let customerFields = (customerFieldsProvider as? CustomerCustomFieldsService)?.customerFields ?? []
        
        let parsedMessage = welcomeMessageManager.parse(welcomeMessage, contactFields: contactFields, customerFields: customerFields, customer: customer)
        self.parsedWelcomeMessage = parsedMessage
        
        return Message(
            id: UUID.provide(),
            threadId: thread.id,
            contentType: .text(MessagePayload(text: parsedMessage, postback: nil)),
            createdAt: Date.provide(),
            attachments: [],
            direction: .toClient,
            userStatistics: nil,
            authorUser: nil,
            authorEndUserIdentity: CustomerIdentityMapper.map(customer)
        )
    }
    
    /// Some messages should not appear into the chat history because of specific reason,
    /// e.g. Begin live chat conversation = Live chat thread is created with hard coded message
    /// that we don't want to present to the user
    func shouldIgnoreMessage(_ message: MessageDTO) -> Bool {
        guard case .text(let payload) = message.contentType else {
            return false
        }
        
        if let parsedWelcomeMessage, payload.text == parsedWelcomeMessage {
            LogManager.trace("Ignoring message – content is welcome message")
            
            self.parsedWelcomeMessage = nil
            
            return true
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
    func sendBeginLiveChatConversation(for thread: ChatThread) async throws {
        LogManager.trace("Sending begin conversation content to create a live chat thread.")
        
        try await send(OutboundMessage(text: MessagesService.beginLiveChatConversationMessage), for: thread)
    }
}

// MARK: - Private methods

private extension MessagesService {
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidData`` when the Data object cannot be successfully converted to a valid UTF-8 string
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func sendWelcomeMessageIfNeeded(for thread: ChatThread) throws {
        guard let parsedWelcomeMessage, thread.messages.count == 1 else {
            return
        }
        
        LogManager.trace("Sending an outbound message.")

        try socketService.checkForConnection()
        
        let customFields = (contactFieldsProvider as? ContactCustomFieldsService)?.contactFields[thread.id]?.convertValueToIdentifier(
            with: connectionContext.channelConfig.prechatSurvey?.customFields
        )
        
        let eventData = EventDataType.sendOutboundMessageData(
            SendOutboundMessageEventDataDTO(
                thread: ThreadDTO(
                    idOnExternalPlatform: thread.id,
                    threadName: thread.messages.isEmpty ? nil : thread.name
                ),
                contentType: .text(MessagePayloadDTO(text: parsedWelcomeMessage, postback: nil)),
                idOnExternalPlatform: UUID.provide(),
                contactCustomFields: customFields ?? [],
                attachments: [],
                deviceFingerprint: DeviceFingerprintDTO(deviceToken: connectionContext.deviceToken),
                token: socketService.accessToken.map(\.token)
            )
        )
        
        let data = try eventsService.create(.sendOutbound, with: eventData)
        
        try socketService.send(data: data)
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
        fun: StaticString = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> [AttachmentDTO] {
        let chatURL = connectionContext.environment.chatServerUrl?.channelUrl(brandId: connectionContext.brandId, channelId: connectionContext.channelId)

        guard let url = chatURL / "attachment" else {
            throw CXoneChatError.missingParameter("url")
        }
        
        var request = URLRequest(url: url, method: .post, contentType: "application/json")

        let returned = try await self.asyncMap { attachment in
            request.httpBody = try await attachment.httpBody(fileRestrictions: connectionContext.channelConfig.settings.fileRestrictions)
            
            let (data, response) = try await connectionContext.session.fetch(for: request, fun: fun, file: file, line: line)

            guard let response = response as? HTTPURLResponse, (200 ... 299) ~= response.statusCode else {
                throw CXoneChatError.serverError
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
