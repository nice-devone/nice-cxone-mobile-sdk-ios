import Foundation


class ChatThreadsService: ChatThreadsProvider {
    
    // MARK: - Properties
    
    var messages: MessagesProvider
    var customFields: ContactCustomFieldsProvider
    
    var threads = [ChatThread]()
    
    weak var delegate: CXoneChatDelegate?
    
    let customerFieldsProvider: CustomerCustomFieldsProvider
    var socketService: SocketService
    let eventsService: EventsService
    
    var onWelcomeMessageReceived: () -> Void = { }
    
    var connectionContext: ConnectionContext { socketService.connectionContext }
    
    
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
    
    func get() -> [ChatThread] { threads }
    
    func create() throws -> UUID {
        LogManager.trace("Creates a new thread by sending an initial message to the thread.")

        try socketService.checkForConnection()

        guard connectionContext.channelConfig.settings.hasMultipleThreadsPerEndUser || threads.isEmpty else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        
        let id = UUID()
        let thread = ChatThread(_id: "\(connectionContext.channelId)_\(id.uuidString)", id: id)
        threads.append(thread)

        try handleWelcomeMessageIfNeeded(for: ChatThreadMapper.map(thread))

        return thread.id
    }
    
    func load() throws {
        LogManager.trace("Loading all of the threads for the current customer.")

        try socketService.checkForConnection()

        guard connectionContext.channelConfig.settings.hasMultipleThreadsPerEndUser || threads.isEmpty else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        
        let data = try eventsService.create(.fetchThreadList)
        
        socketService.send(message: data.utf8string)
    }
    
    func load(with id: UUID?) throws {
        LogManager.trace("Loading the a thread for the customer and gets messages.")

        try socketService.checkForConnection()

        let eventData = try id.map { id -> EventDataType in
            guard let threadId = threads.getId(of: id) else {
                throw CXoneChatError.invalidThread
            }
            
            return .loadThreadData(.init(thread: .init(id: threadId, idOnExternalPlatform: id, threadName: nil)))
        }
        let data = try eventsService.create(.recoverThread, with: eventData)
        
        socketService.send(message: data.utf8string)
    }
    
    func loadInfo(for thread: ChatThread) throws {
        LogManager.trace("Loads information about the thread.")

        try socketService.checkForConnection()

        let data = try eventsService.create(
            .loadThreadMetadata,
            with: .archiveThreadData(.init(thread: .init(id: thread._id, idOnExternalPlatform: thread.id, threadName: nil)))
        )
        
        socketService.send(message: data.utf8string)
    }
    
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
                with: .updateThreadData(.init(thread: .init(id: nil, idOnExternalPlatform: id, threadName: name)))
            )
            
            socketService.send(message: data.utf8string)
        } else {
            LogManager.info("Thread does not contain any messages. Skipping message sending.")
        }

        if let index = threads.index(of: id), threads[index].messages.isEmpty {
            delegate?.onThreadUpdate()
        }
    }
    
    func archive(_ thread: ChatThread) throws {
        LogManager.trace("Archiving thread.")
        
        guard connectionContext.channelConfig.settings.hasMultipleThreadsPerEndUser else {
            throw CXoneChatError.unsupportedChannelConfig
        }
        guard let index = threads.index(of: thread.id) else {
            throw CXoneChatError.invalidThread
        }
        let data = try eventsService.create(
            .archiveThread,
            with: .archiveThreadData(.init(thread: .init(id: thread._id, idOnExternalPlatform: thread.id, threadName: thread.name)))
        )
                            
        socketService.send(message: data.utf8string)
        
        threads[index].canAddMoreMessages = false
    }
    
    func markRead(_ thread: ChatThread) throws {
        LogManager.trace("Marking thread as read.")
        
        let data = try eventsService.create(
            .messageSeenByCustomer,
            with: .archiveThreadData(.init(thread: .init(id: thread._id, idOnExternalPlatform: thread.id, threadName: thread.name)))
        )
        
        socketService.send(message: data.utf8string)
    }
    
    func reportTypingStart(_ didStart: Bool, in thread: ChatThread) throws {
        LogManager.trace("Reporting user start typing.")

        try socketService.checkForConnection()

        let data = try eventsService.create(
            didStart ? .senderTypingStarted : .senderTypingEnded,
            with: .customerTypingData(
                .init(thread: .init(id: thread._id, idOnExternalPlatform: thread.id, threadName: thread.name))
            )
        )
        
        socketService.send(message: data.utf8string)
    }
    
    
    // MARK: - Internal Methods
    
    func setThreadAgent(agent: AgentDTO, idOnExternalPlatform: UUID) throws {
        LogManager.trace("Setting thread agent.")
        
        guard let index = threads.index(of: idOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        
        threads[index].assignedAgent = AgentMapper.map(agent)
    }
    
    func appendMessageToThread(_ message: MessageDTO) throws {
        LogManager.trace("Appending message to the thread.")
        guard let index = threads.index(of: message.idOnExternalPlatform) else {
            throw CXoneChatError.invalidThread
        }
        
        threads[index].messages.append(MessageMapper.map(message))
    }
}


// MARK: - Private methods

private extension ChatThreadsService {
    
    func handleWelcomeMessageIfNeeded(for thread: ChatThreadDTO) throws {
        if let welcomeMessage = UserDefaults.standard.string(forKey: "welcomeMessage") {
            LogManager.trace("Handling welcome message.")
            
            guard let customer = connectionContext.customer else {
                throw CXoneChatError.missingParameter("customer")
            }

            do {
                let parsedMessage = WelcomeMessageManager.parse(
                    welcomeMessage,
                    contactFields: customFields.get(for: thread.idOnExternalPlatform),
                    customerFields: customerFieldsProvider.get(),
                    customer: customer
                )

                try sendOutboundMessage(parsedMessage, for: thread)
            } catch {
                throw error
            }
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
                    self.delegate?.onError(CXoneChatError.missingParameter("customer"))
                    return
                }

                do {
                    let parsedMessage = WelcomeMessageManager.parse(
                        welcomeMessage,
                        contactFields: self.customFields.get(for: thread.idOnExternalPlatform),
                        customerFields: self.customerFieldsProvider.get(),
                        customer: customer
                    )

                    try self.sendOutboundMessage(parsedMessage, for: thread)
                } catch {
                    self.delegate?.onError(error)
                }
            }
        }
    }
    
    func sendOutboundMessage(_ message: String, for thread: ChatThreadDTO) throws {
        LogManager.trace("Sending an outbound message.")

        try socketService.checkForConnection()

        let customFields = (customFields as? ContactCustomFieldsService)?.contactFields[thread.idOnExternalPlatform] ?? []
        let eventData = EventDataType.sendOutboundMessageData(
            .init(
                thread: .init(
                    id: thread.messages.isEmpty ? nil : thread.id,
                    idOnExternalPlatform: thread.idOnExternalPlatform,
                    threadName: thread.messages.isEmpty ? nil : thread.threadName
                ),
                contentType: .text(message),
                idOnExternalPlatform: UUID(),
                consumerContact: .init(customFields: customFields),
                attachments: [],
                browserFingerprint: .init(deviceToken: connectionContext.deviceToken),
                token: socketService.accessToken.map(\.token)
            )
        )
        
        let data = try eventsService.create(.sendOutbound, with: eventData)
        
        socketService.send(message: data.utf8string)
    }
}
