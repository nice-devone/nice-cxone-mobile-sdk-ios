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

class MessagesService: MessagesProvider {
    
    // MARK: - Properties
    
    let socketService: SocketService
    let eventsService: EventsService
    
    weak var delegate: CXoneChatDelegate?
    
    private let contactFieldsProvider: ContactCustomFieldsProvider
    private let customerFieldsProvider: CustomerCustomFieldsProvider
    
    private var parsedWelcomeMessage: String?
    
    private var connectionContext: ConnectionContext {
        get { socketService.connectionContext }
        set { socketService.connectionContext = newValue }
    }
    
    // MARK: - Init
    
    init(
        contactFieldsProvider: ContactCustomFieldsProvider,
        customerFieldsProvider: CustomerCustomFieldsProvider,
        socketService: SocketService,
        eventsService: EventsService
    ) {
        self.contactFieldsProvider = contactFieldsProvider
        self.customerFieldsProvider = customerFieldsProvider
        self.socketService = socketService
        self.eventsService = eventsService
    }
    
    // MARK: - Implementation
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/noMoreMessages`` if there aren't any other messages, so additional messages could not be loaded.
    /// - Throws: ``CXoneChatError/invalidOldestDate`` if Thread is missing the timestamp of when the message was created.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
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
        
        socketService.send(message: data.utf8string)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if attachments upload `url` has not been set properly or attachment uploaded data object is missing.
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    /// - Throws: ``CXoneChatError/attachmentError`` if the provided attachment was unable to be sent.
    /// - Throws: ``CXoneChatError/invalidParameter(_:)`` if the the outbound message has no ``postback``, empty ``text``, and empty ``attachments``.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    @discardableResult
    func send(_ message: OutboundMessage, for chatThread: ChatThread) async throws -> Message {
        LogManager.trace("Sending a message in the specified chat thread.")

        guard message.postback != nil || !message.text.isEmpty || !message.attachments.isEmpty else {
            throw CXoneChatError.invalidParameter("attempt to send a message with no postback, text, or attachments")
        }

        try socketService.checkForConnection()

        let contactFields = (contactFieldsProvider as? ContactCustomFieldsService)?.contactFields[chatThread.id]?
            .compactMap { field -> CustomFieldDTO? in
                guard let value = field.value, !value.isEmpty else {
                    return nil
                }
                
                return CustomFieldDTO(ident: field.ident, value: value, updatedAt: field.updatedAt)
            } ?? []
        let customerFields = (customerFieldsProvider as? CustomerCustomFieldsService)?.customerFields
            .compactMap { field -> CustomFieldDTO? in
                guard let value = field.value, !value.isEmpty else {
                    return nil
                }
                
                return CustomFieldDTO(ident: field.ident, value: value, updatedAt: field.updatedAt)
            } ?? []
        
        try sendWelcomeMessageIfNeeded(for: chatThread)
        
        let mappedAttachments = try await message.attachments.map(with: connectionContext)
        
        let eventData = EventDataType.sendMessageData(
            SendMessageEventDataDTO(
                thread: ThreadDTO(idOnExternalPlatform: chatThread.id, threadName: chatThread.name),
                contentType: .text(MessagePayloadDTO(text: message.text, postback: message.postback)),
                idOnExternalPlatform: UUID(),
                customer: CustomerCustomFieldsDataDTO(customFields: customerFields),
                contact: ContactCustomFieldsDataDTO(customFields: contactFields),
                attachments: mappedAttachments,
                deviceFingerprint: DeviceFingerprintDTO(deviceToken: connectionContext.deviceToken),
                token: socketService.accessToken.map(\.token)
            )
        )
        
        let data = try eventsService.create(.sendMessage, with: eventData)
        
        socketService.send(message: data.utf8string)
        
        return Message(
            id: UUID(),
            threadId: chatThread.id,
            contentType: .text(MessagePayload(text: message.text, postback: message.postback)),
            createdAt: Date(),
            attachments: mappedAttachments.map(AttachmentMapper.map),
            direction: .toAgent,
            userStatistics: nil,
            authorUser: chatThread.assignedAgent,
            authorEndUserIdentity: connectionContext.customer.map(CustomerIdentityMapper.map)
        )
    }
}

// MARK: - Internal methods

extension MessagesService {
    
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    func getParsedWelcomeMessage(_ welcomeMessage: String, for thread: ChatThread) throws -> Message {
        guard let customer = connectionContext.customer else {
            throw CXoneChatError.customerAssociationFailure
        }

        let contactFields = (contactFieldsProvider as? ContactCustomFieldsService)?.contactFields[thread.id]?
            .compactMap { field -> CustomFieldDTO? in
                guard let value = field.value, !value.isEmpty else {
                    return nil
                }
                
                return CustomFieldDTO(ident: field.ident, value: value, updatedAt: field.updatedAt)
            } ?? []
        let customerFields = (customerFieldsProvider as? CustomerCustomFieldsService)?.customerFields
            .compactMap { field -> CustomFieldDTO? in
                guard let value = field.value, !value.isEmpty else {
                    return nil
                }
                
                return CustomFieldDTO(ident: field.ident, value: value, updatedAt: field.updatedAt)
            } ?? []
        
        let parsedMessage = WelcomeMessageManager.parse(welcomeMessage, contactFields: contactFields, customerFields: customerFields, customer: customer)
        self.parsedWelcomeMessage = parsedMessage
        
        return Message(
            id: UUID(),
            threadId: thread.id,
            contentType: .text(MessagePayload(text: parsedMessage, postback: nil)),
            createdAt: Date(),
            attachments: [],
            direction: .toClient,
            userStatistics: nil,
            authorUser: nil,
            authorEndUserIdentity: CustomerIdentityMapper.map(customer)
        )
    }
    
    func isMessageContentWelcomeMessage(_ message: MessageDTO) -> Bool {
        guard let parsedWelcomeMessage, case .text(let payload) = message.contentType, payload.text == parsedWelcomeMessage else {
            return false
        }

        self.parsedWelcomeMessage = nil
        
        return true
    }
}

// MARK: - Private methods

private extension MessagesService {
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func sendWelcomeMessageIfNeeded(for thread: ChatThread) throws {
        guard let parsedWelcomeMessage, thread.messages.count == 1 else {
            return
        }
        
        LogManager.trace("Sending an outbound message.")

        try socketService.checkForConnection()

        let customFields = (contactFieldsProvider as? ContactCustomFieldsService)?.contactFields[thread.id]?
            .compactMap { field -> CustomFieldDTO? in
                guard let value = field.value, !value.isEmpty else {
                    return nil
                }
            
                return CustomFieldDTO(ident: field.ident, value: value, updatedAt: field.updatedAt)
            } ?? []
        
        let eventData = EventDataType.sendOutboundMessageData(
            SendOutboundMessageEventDataDTO(
                thread: ThreadDTO(
                    idOnExternalPlatform: thread.id,
                    threadName: thread.messages.isEmpty ? nil : thread.name
                ),
                contentType: .text(MessagePayloadDTO(text: parsedWelcomeMessage, postback: nil)),
                idOnExternalPlatform: UUID(),
                contactCustomFields: customFields,
                attachments: [],
                deviceFingerprint: DeviceFingerprintDTO(deviceToken: connectionContext.deviceToken),
                token: socketService.accessToken.map(\.token)
            )
        )
        
        let data = try eventsService.create(.sendOutbound, with: eventData)
        
        socketService.send(message: data.utf8string)
    }
}

// MARK: - ContentDescriptor Mapper

private extension [ContentDescriptor] {
    
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if attachments upload `url` has not been set properly or attachment uploaded data object is missing.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/attachmentError`` if the provided attachment was unable to be sent.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
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
            request.httpBody = try await JSONEncoder().encode([
                "content": attachment.data.fetch().base64EncodedString(),
                "fileName": attachment.fileName,
                "mimeType": attachment.mimeType
            ])
            
            let (data, response) = try await connectionContext.session.data(for: request, fun: fun, file: file, line: line)

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

private extension URL {

    /// - Throws: ``CXoneChatError/noSuchFile`` if an attached file could not be found.
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    func readSecureData() async throws -> Data {
        do {
            return try Data(contentsOf: self)
        } catch {
            guard startAccessingSecurityScopedResource() else {
                throw CXoneChatError.noSuchFile(absoluteString)
            }
            defer {
                stopAccessingSecurityScopedResource()
            }
            
            return try Data(contentsOf: self)
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
