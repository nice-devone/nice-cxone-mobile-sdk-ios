import Foundation


class ChatThreadsService: ChatThreadsProvider {
    
    // MARK: - Properties
    
    private let customerFieldsProvider: CustomerCustomFieldsProvider
    private var connectionContext: ConnectionContext { socketService.connectionContext }
    
    var socketService: SocketService
    let eventsService: EventsService
    
    var threads = [ChatThread]()
    var onWelcomeMessageReceived: () -> Void = { }
    
    weak var delegate: CXoneChatDelegate?
    
    
    // MARK: - Protocol Properties
    
    var messages: MessagesProvider
    var customFields: ContactCustomFieldsProvider
    
    
    // MARK: - Init
    
    init(
        messagesProvider: MessagesProvider,
        customFieldsProvider: ContactCustomFieldsProvider,
        customerFieldsProvider: CustomerCustomFieldsProvider,
        socketService: SocketService,
        eventsService: EventsService
    ) {
        self.messages = messagesProvider
        self.customFields = customFieldsProvider
        self.customerFieldsProvider = customerFieldsProvider
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
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func create() throws -> UUID {
        try create(with: [:])
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/missingPreChatCustomFields`` if the server requires to fill-up some contact custom fields before initializing chat thread.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func create(with customFields: [String: String]) throws -> UUID {
        LogManager.trace("Creates a new thread by sending an initial message to the thread.")

        try socketService.checkForConnection()

        guard connectionContext.channelConfig.settings.hasMultipleThreadsPerEndUser || threads.isEmpty else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        
        let id = UUID()
        let thread = ChatThread(id: id)
        
        if !customFields.isEmpty, let service = self.customFields as? ContactCustomFieldsService {
            let mappedCustomFields = customFields.map { CustomFieldDTO(ident: $0.key, value: $0.value, updatedAt: Date()) }
            
            service.updateFields(mappedCustomFields, for: thread.id)
        }
        
        guard allCustomFieldsFilled(customFields) else {
            throw CXoneChatError.missingPreChatCustomFields
        }
        
        threads.append(thread)

        try handleWelcomeMessageIfNeeded(for: ChatThreadMapper.map(thread))
        
        return thread.id
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func load() throws {
        LogManager.trace("Loading all of the threads for the current customer.")

        try socketService.checkForConnection()

        guard connectionContext.channelConfig.settings.hasMultipleThreadsPerEndUser || threads.isEmpty else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        
        let data = try eventsService.create(.fetchThreadList)
        
        socketService.send(message: data.utf8string)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func load(with threadId: UUID?) throws {
        LogManager.trace("Loading the a thread for the customer and gets messages.")

        try socketService.checkForConnection()

        let eventData = try threadId.map { threadId -> EventDataType in
            guard let threadId = threads.getId(of: threadId) else {
                throw CXoneChatError.invalidThread
            }
            
            return .loadThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: threadId, threadName: nil)))
        }
        let data = try eventsService.create(.recoverThread, with: eventData)
        
        socketService.send(message: data.utf8string)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func loadInfo(for thread: ChatThread) throws {
        LogManager.trace("Loads information about the thread.")

        try socketService.checkForConnection()

        let data = try eventsService.create(
            .loadThreadMetadata,
            with: .loadThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: thread.id, threadName: nil)))
        )
        
        socketService.send(message: data.utf8string)
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func updateName(_ name: String, for id: UUID) throws {
        LogManager.trace("Updating the name for a thread.")

        try socketService.checkForConnection()

        guard connectionContext.channelConfig.settings.hasMultipleThreadsPerEndUser else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        guard let index = threads.index(of: id) else {
            throw CXoneChatError.invalidThread
        }
        
        threads[index].name = name
        
        if !threads[index].messages.isEmpty {
            let data = try eventsService.create(
                .updateThread,
                with: .updateThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: id, threadName: name)))
            )
            
            socketService.send(message: data.utf8string)
        } else {
            LogManager.info("Thread does not contain any messages. Skipping message sending.")
        }

        if let index = threads.index(of: id), threads[index].messages.isEmpty {
            delegate?.onThreadUpdate()
        }
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func archive(_ thread: ChatThread) throws {
        LogManager.trace("Archiving thread.")
        
        try socketService.checkForConnection()
        
        guard connectionContext.channelConfig.settings.hasMultipleThreadsPerEndUser else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        guard let index = threads.index(of: thread.id) else {
            throw CXoneChatError.invalidThread
        }
        
        let data = try eventsService.create(
            .archiveThread,
            with: .archiveThreadData(ThreadEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: thread.id, threadName: thread.name)))
        )
                            
        socketService.send(message: data.utf8string)
        
        threads[index].canAddMoreMessages = false
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func markRead(_ thread: ChatThread) throws {
        LogManager.trace("Marking thread as read.")
        
        try socketService.checkForConnection()
        
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
        LogManager.trace("Reporting user start typing.")

        try socketService.checkForConnection()

        let data = try eventsService.create(
            didStart ? .senderTypingStarted : .senderTypingEnded,
            with: .customerTypingData(
                CustomerTypingEventDataDTO(thread: ThreadDTO(idOnExternalPlatform: thread.id, threadName: thread.name))
            )
        )
        
        socketService.send(message: data.utf8string)
    }
    
    
    // MARK: - Internal Methods
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func setThreadAgent(agent: AgentDTO, idOnExternalPlatform: UUID) throws {
        LogManager.trace("Setting thread agent.")
        
        guard let index = threads.index(of: idOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        
        threads[index].assignedAgent = AgentMapper.map(agent)
    }
    
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    func appendMessageToThread(_ message: MessageDTO) throws {
        LogManager.trace("Appending message to the thread.")
        
        guard let index = threads.index(of: message.threadIdOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        
        threads[index].messages.append(MessageMapper.map(message))
    }
}


// MARK: - Private methods

private extension ChatThreadsService {
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first. Make sure you call the connect method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func handleWelcomeMessageIfNeeded(for thread: ChatThreadDTO) throws {
        if let welcomeMessage = UserDefaults.standard.string(forKey: "welcomeMessage") {
            LogManager.trace("Handling welcome message.")
            
            guard let customer = connectionContext.customer else {
                throw CXoneChatError.customerAssociationFailure
            }

            let contactFields = customFields.get(for: thread.idOnExternalPlatform).map(CustomFieldTypeMapper.map).toDictionary()
            let customerFields = customerFieldsProvider.get().map(CustomFieldTypeMapper.map).toDictionary()
            
            let parsedMessage = WelcomeMessageManager.parse(
                welcomeMessage,
                contactFields: contactFields,
                customerFields: customerFields,
                customer: customer
            )

            try sendOutboundMessage(parsedMessage, for: thread)
        } else {
            onWelcomeMessageReceived = { [weak self] in
                LogManager.trace("Handling welcome message.")
                
                guard let self = self else {
                    return
                }
                guard let welcomeMessage = UserDefaults.standard.string(forKey: "welcomeMessage") else {
                    self.delegate?.onError(CXoneChatError.missingParameter("welcomeMessage"))
                    return
                }
                guard let customer = self.connectionContext.customer else {
                    self.delegate?.onError(CXoneChatError.customerAssociationFailure)
                    return
                }
 
                let contactFields = self.customFields.get(for: thread.idOnExternalPlatform).map(CustomFieldTypeMapper.map).toDictionary()
                let customerFields = self.customerFieldsProvider.get().map(CustomFieldTypeMapper.map).toDictionary()

                do {
                    let parsedMessage = WelcomeMessageManager.parse(
                        welcomeMessage,
                        contactFields: contactFields,
                        customerFields: customerFields,
                        customer: customer
                    )

                    try self.sendOutboundMessage(parsedMessage, for: thread)
                } catch {
                    self.delegate?.onError(error)
                }
            }
        }
    }
    
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func sendOutboundMessage(_ message: String, for thread: ChatThreadDTO) throws {
        LogManager.trace("Sending an outbound message.")

        try socketService.checkForConnection()

        let customFields = (customFields as? ContactCustomFieldsService)?.contactFields[thread.idOnExternalPlatform]?.compactMap { field -> CustomFieldDTO? in
            guard let value = field.value, !value.isEmpty else {
                return nil
            }
            
            return CustomFieldDTO(ident: field.ident, value: value, updatedAt: field.updatedAt)
        } ?? []
        
        let eventData = EventDataType.sendOutboundMessageData(
            SendOutboundMessageEventDataDTO(
                thread: ThreadDTO(
                    idOnExternalPlatform: thread.idOnExternalPlatform,
                    threadName: thread.messages.isEmpty ? nil : thread.threadName
                ),
                contentType: .text(MessagePayloadDTO(text: message, postback: nil)),
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

extension Array where Element: Hashable {
    
    func difference(from other: [Element]) -> [Element] {
        self.filter { !other.contains($0) }
    }
}
