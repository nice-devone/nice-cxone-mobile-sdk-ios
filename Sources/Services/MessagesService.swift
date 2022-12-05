import Foundation


class MessagesService: MessagesProvider {
    
    // MARK: - Properties
    
    let contactFieldsProvider: ContactCustomFieldsProvider
    let customerFieldsProvider: CustomerCustomFieldsProvider
    let socketService: SocketService
    let eventsService: EventsService
    
    var connectionContext: ConnectionContext { socketService.connectionContext }
    
    
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
    
    func loadMore(for chatThread: ChatThread) throws {
        LogManager.trace("Loading more messages.")

        try socketService.checkForConnection()

        guard chatThread.hasMoreMessagesToLoad else {
            throw CXoneChatError.noMoreMessages
        }
        guard let oldestDate = chatThread.messages.first?.createdAt else {
            throw CXoneChatError.invalidOldestDate
        }

        let thread = ThreadDTO(id: chatThread._id, idOnExternalPlatform: chatThread.id, threadName: chatThread.name)
        let data = try eventsService.create(
            .loadMoreMessages,
            with: .loadMoreMessageData(.init(scrollToken: chatThread.scrollToken, thread: thread, oldestMessageDatetime: oldestDate))
        )
        
        socketService.send(message: data.utf8string)
    }
    
    func send(_ message: String, for chatThread: ChatThread) async throws {
        LogManager.trace("Sending a message in the specified chat thread.")

        try socketService.checkForConnection()

        let contactFields = contactFieldsProvider
            .get(for: chatThread.id)
            .map { CustomFieldDTO(ident: $0.key, value: $0.value) }
        let customerFields = customerFieldsProvider
            .get()
            .map { CustomFieldDTO(ident: $0.key, value: $0.value) }
        
        let eventData = EventDataType.sendMessageData(
            .init(
                thread: .init(
                    id: chatThread.messages.isEmpty ? nil : chatThread._id,
                    idOnExternalPlatform: chatThread.id,
                    threadName: chatThread.messages.isEmpty ? nil : chatThread.name
                ),
                messageContent: .init(type: .text, payload: .init(text: message, elements: []), fallbackText: ""),
                idOnExternalPlatform: UUID(),
                customer: .init(customFields: customerFields),
                contact: .init(customFields: contactFields),
                attachments: [],
                browserFingerprint: .init(),
                token: socketService.accessToken.map(\.token)
            )
        )
        
        let data = try eventsService.create(.sendMessage, with: eventData)
        
        socketService.send(message: data.utf8string)
    }
    
    // swiftlint:disable:next function_body_length
    func send(_ message: String, with attachments: [AttachmentUpload], for chatThread: ChatThread) async throws {
        LogManager.trace("Sending a message with attachments.")

        try socketService.checkForConnection()

        let chatURL = connectionContext.environment.chatURL
        let brandId = connectionContext.brandId
        let channelId = connectionContext.channelId
        
        guard let url = URL(string: "\(chatURL)/1.0/brand/\(brandId)/channel/\(channelId)/attachment") else {
            throw CXoneChatError.missingParameter("url")
        }
        
        var request = URLRequest(url: url, method: .post, contentType: "application/json")
        var index = 0
        var attachment = [AttachmentDTO]()
        
        for try imageData in attachments {
            request.httpBody = try JSONEncoder().encode([
                "content": imageData.data.base64EncodedString(),
                "fileName": imageData.fileName,
                "mimeType": imageData.mimeType
            ])
            
            let (data, response) = try await connectionContext.session.data(for: request)
            
            guard let response = response as? HTTPURLResponse, (200 ... 299) ~= response.statusCode else {
                throw CXoneChatError.serverError
            }
            guard let decoded: AttachmentUploadSuccessResponseDTO = try data.decode() else {
                throw CXoneChatError.missingParameter("decodedData")
            }
            
            attachment.append(
                .init(url: decoded.fileUrl, friendlyName: "fileUpload.ext", mimeType: imageData.mimeType, fileName: imageData.fileName)
            )
            index += 1
        }
        
        guard index >= attachments.count else {
            throw CXoneChatError.attachmentError
        }
        
        let contactFields = contactFieldsProvider
            .get(for: chatThread.id)
            .map { CustomFieldDTO(ident: $0.key, value: $0.value) }
        let customerFields = customerFieldsProvider
            .get()
            .map { CustomFieldDTO(ident: $0.key, value: $0.value) }
        
        let eventData = EventDataType.sendMessageData(
            .init(
                thread: .init(
                    id: chatThread.messages.isEmpty ? nil : chatThread._id,
                    idOnExternalPlatform: chatThread.id,
                    threadName: chatThread.messages.isEmpty ? nil : chatThread.name
                ),
                messageContent: .init(type: .text, payload: .init(text: message, elements: []), fallbackText: ""),
                idOnExternalPlatform: UUID(),
                customer: .init(customFields: customerFields),
                contact: .init(customFields: contactFields),
                attachments: attachment,
                browserFingerprint: .init(),
                token: socketService.accessToken.map(\.token)
            )
        )
        
        let data = try eventsService.create(.sendMessage, with: eventData)
        
        socketService.send(message: data.utf8string)
    }
}
