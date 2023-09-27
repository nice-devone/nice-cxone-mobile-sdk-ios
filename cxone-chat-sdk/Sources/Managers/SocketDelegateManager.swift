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

// swiftlint:disable file_length

import Foundation

// swiftlint:disable:next type_body_length
class SocketDelegateManager: SocketDelegate {
    
    // MARK: - Properties
    
    private lazy var contactCustomFieldsService = threadsService?.customFields as? ContactCustomFieldsService
    
    private let analyticsProvider: AnalyticsProvider
    private var threadsService: ChatThreadsService?
    private var customerFieldsService: CustomerCustomFieldsService?
    private let socketService: SocketService
    private let eventsService: EventsService
    
    weak var delegate: CXoneChatDelegate?
    
    // MARK: - Init
    
    init(
        threads: ChatThreadsProvider,
        customerCustomFields: CustomerCustomFieldsProvider,
        analytics: AnalyticsProvider,
        socketService: SocketService,
        eventsService: EventsService
    ) {
        self.threadsService = threads as? ChatThreadsService
        self.customerFieldsService = customerCustomFields as? CustomerCustomFieldsService
        self.analyticsProvider = analytics
        self.socketService = socketService
        self.eventsService = eventsService
    }
    
    // MARK: - Methods
    
    // swiftlint:disable:next function_body_length
    func handleMessage(message: String) {
        LogManager.trace("Handling a message - \(message.formattedJSON ?? message).")
        
        guard let event: GenericEventDTO = try? Data(message.utf8).decode() else {
            didReceiveError(CXoneChatError.missingParameter("event"))
            return
        }
        
        if let error = event.error {
            didReceiveError(error)
        }
        
        let messageData = Data(message.utf8)
        let eventType = event.eventType == nil ? event.postback?.eventType : event.eventType
        
        switch eventType {
        case .senderTypingStarted:
            if let data: AgentTypingEventDTO = try? messageData.decode(), data.data.user != nil {
                notifyAgentTypingStartedEvent(data)
            }
        case .senderTypingEnded:
            if let data: AgentTypingEventDTO = try? messageData.decode(), data.data.user != nil {
                notifyAgentTypingEndEvent(data)
            }
        case .messageCreated:
            try? processMessageCreatedEvent(messageData)
        case .threadRecovered:
            let decoded: ThreadRecoveredEventDTO? = try? messageData.decode()
            processThreadRecoverEvent(decoded)
        case .messageReadChanged:
            guard let decoded: MessageReadByAgentEventDTO = try? messageData.decode() else {
                didReceiveError(CXoneChatError.missingParameter("messageReadByAgentEvent"))
                return
            }
            
            processMessageReadChangeEvent(decoded)
        case .contactInboxAssigneeChanged:
            guard let decoded: ContactInboxAssigneeChangedEventDTO = try? messageData.decode() else {
                didReceiveError(CXoneChatError.missingParameter("contactInboxAssigneeChangedEvent"))
                return
            }
            
            processInboxAssigneeChangeEvent(decoded)
        case .threadListFetched:
            processThreadListFetchedEvent(event: event)
        case .customerAuthorized:
            processCustomerAuthorizedEvent(messageData)
        case .customerReconnected:
            processCustomerReconnectEvent()
        case .moreMessagesLoaded:
            let decode: MoreMessagesLoadedEventDTO? = try? messageData.decode()
            processMoreMessagesEvent(decode)
        case .threadArchived:
            notifyThreadArchivedEvent()
        case .tokenRefreshed:
            let decode: TokenRefreshedEventDTO? = try? messageData.decode()
            saveAccessToken(decode)
        case .threadMetadataLoaded:
            if let decoded: ThreadMetadataLoadedEventDTO = try? messageData.decode() {
                processThreadLastMessage(decoded.postback.data.lastMessage)
                
                if let agent = decoded.postback.data.ownerAssignee {
                    processThreadAgent(decoded.postback.data.lastMessage, agent)
                }
            }
        case .threadUpdated:
            delegate?.onThreadUpdate()
        case .fireProactiveAction:
            let decode: ProactiveActionEventDTO? = try? messageData.decode()
            processProactiveAction(decode: decode, data: messageData)
        default:
            LogManager.info("Trying to handle unknown message event type - \(String(describing: eventType))")
        }
    }
    
    func didReceiveError(_ error: Error) {
        switch error {
        case _ where (error as? OperationError)?.errorCode == .recoveringThreadFailed:
            delegate?.onError(CXoneChatError.recoveringThreadFailed)
        case _ where (error as? OperationError)?.errorCode == .customerReconnectFailed:
            do {
                try refreshToken()
            } catch {
                delegate?.onError(error)
            }
        case _ where (error as? OperationError)?.errorCode == .tokenRefreshFailed:
            delegate?.onTokenRefreshFailed()
        default:
            delegate?.onError(error)
        }
    }
    
    func didCloseConnection() {
        LogManager.trace("Did close connection.")
        
        delegate?.onUnexpectedDisconnect()
    }
    
    func refreshToken() throws {
        LogManager.trace("Refreshing a token.")
        
        guard let token = socketService.accessToken?.token else {
            delegate?.onTokenRefreshFailed()
            
            throw CXoneChatError.missingAccessToken
        }
        
        let data = try eventsService.create(.refreshToken, with: .refreshTokenPayload(RefreshTokenPayloadDataDTO(token: token)))
        
        socketService.send(message: data.utf8string, shouldCheck: false)
    }
    
    // MARK: - Methods
    
    func saveAccessToken(_ decode: TokenRefreshedEventDTO?) {
        LogManager.trace("Saving a access token.")
        
        socketService.accessToken = decode?.postback.accessToken
    }
    
    func notifyThreadArchivedEvent() {
        LogManager.trace("Thread has been archived.")
        
        delegate?.onThreadArchive()
    }
    
    func processMoreMessagesEvent(_ decode: MoreMessagesLoadedEventDTO?) {
        LogManager.trace("Processing more messages.")
        
        guard let decode = decode else {
            didReceiveError(CXoneChatError.missingParameter("decode"))
            return
        }
        if decode.postback.data.messages.isEmpty {
            delegate?.onLoadMoreMessages([])
        } else {
            addMessages(messages: decode.postback.data.messages, scrollToken: decode.postback.data.scrollToken)
        }
    }
    
    func processCustomerReconnectEvent() {
        LogManager.trace("Processing customer reconnect.")
        
        delegate?.onConnect()
    }
    
    func notifyAgentTypingStartedEvent(_ data: AgentTypingEventDTO) {
        LogManager.trace("Notifying about agent start typing.")
        
        delegate?.onAgentTyping(true, threadId: data.data.thread.idOnExternalPlatform)
    }
    
    func notifyAgentTypingEndEvent(_ data: AgentTypingEventDTO) {
        LogManager.trace("Notifying about agent end typing.")
        
        delegate?.onAgentTyping(false, threadId: data.data.thread.idOnExternalPlatform)
    }
    
    func processMessageCreatedEvent(_ messageData: Data) throws {
        LogManager.trace("Processing message created.")
        
        if let error: ServerError = try? messageData.decode(), !error.message.isEmpty {
            didReceiveError(error)
        } else if messageData.utf8string.contains("CUSTOM") {
            guard let dict = try? JSONSerialization.jsonObject(with: messageData) as? [String: Any] else {
                didReceiveError(CXoneChatError.missingParameter("messageData"))
                return
            }
            
            let data = dict["data"] as? [String: Any]
            let message = data?["message"] as? [String: Any]
            let content = message?["messageContent"] as? [String: Any]
            let payload = content?["payload"] as? [String: Any]
            
            guard let elements = payload?["elements"] as? [Any] else {
                didReceiveError(CXoneChatError.missingParameter("elements"))
                return
            }
            
            delegate?.onCustomPluginMessage(elements)
        } else {
            let decoded: MessageCreatedEventDTO = try messageData.decode()
            socketService.connectionContext.contactId = decoded.data.case.id
            
            didReceiveMessage(message: decoded)
        }
    }
    
    func processThreadRecoverEvent(_ decoded: ThreadRecoveredEventDTO?) {
        LogManager.trace("Processing thread recover.")
        
        socketService.connectionContext.contactId = decoded?.postback.data.consumerContact.id
        
        guard let decoded = decoded else {
            didReceiveError(CXoneChatError.missingParameter("threadRecoveredEvent"))
            return
        }
        
        if let service = contactCustomFieldsService {
            service.updateFields(
                decoded.postback.data.consumerContact.customFields,
                for: decoded.postback.data.thread.idOnExternalPlatform
            )
        }
        if let service = customerFieldsService {
            service.updateFields(decoded.postback.data.customerContactFields)
        }
        
        if threadsService?.threads.index(of: decoded.postback.data.thread.idOnExternalPlatform) == nil {
            threadsService?.threads.append(
                ChatThread(
                    id: decoded.postback.data.thread.idOnExternalPlatform,
                    name: decoded.postback.data.thread.threadName,
                    assignedAgent: decoded.postback.data.inboxAssignee.map(AgentMapper.map),
                    scrollToken: decoded.postback.data.messagesScrollToken
                )
            )
        }
        
        threadRecovered(decoded)
    }
    
    func processMessageReadChangeEvent(_ decoded: MessageReadByAgentEventDTO) {
        LogManager.trace("Processing message read change.")
        
        guard let readThread = threadsService?.threads.getThread(with: decoded.data.message.threadIdOnExternalPlatform) else {
            didReceiveError(CXoneChatError.missingParameter("readThread"))
            return
        }
        guard let readThreadIndex = threadsService?.threads.index(of: readThread.id) else {
            didReceiveError(CXoneChatError.missingParameter("readThreadIndex"))
            return
        }
        guard let messageIndex = readThread.messages.firstIndex(where: { $0.id == decoded.data.message.idOnExternalPlatform }) else {
            didReceiveError(CXoneChatError.missingParameter("messageIndex"))
            return
        }
        
        threadsService?.threads[readThreadIndex].messages[messageIndex] = MessageMapper.map(decoded.data.message)
        
        didReceiveMessageWasRead(decoded.data.message.threadIdOnExternalPlatform)
    }
    
    func processThreadLastMessage(_ lastMessage: MessageDTO) {
        LogManager.trace("processing thread first message.")
        
        do {
            try appendMessageToThread(lastMessage)
            
            guard let updatedThread = threadsService?.threads.getThread(with: lastMessage.threadIdOnExternalPlatform) else {
                didReceiveError(CXoneChatError.missingParameter("updatedThread"))
                return
            }
            
            delegate?.onThreadInfoLoad(updatedThread)
        } catch {
            error.logError()
            didReceiveError(error)
        }
    }
    
    func processThreadAgent(_ lastMessage: MessageDTO, _ agent: AgentDTO) {
        LogManager.trace("Processing thread agent.")
        
        do {
            try setThreadAgent(agent: agent, threadIdOnExternalPlatform: lastMessage.threadIdOnExternalPlatform)
        } catch {
            error.logError()
            didReceiveError(error)
        }
    }
    
    func processInboxAssigneeChangeEvent(_ decoded: ContactInboxAssigneeChangedEventDTO) {
        LogManager.trace("Processing inbox assignee change.")
        
        assigneeDidChange(decoded.data.case.threadIdOnExternalPlatform, agent: decoded.data.inboxAssignee)
    }
    
    func processThreadListFetchedEvent(event: GenericEventDTO) {
        LogManager.trace("Processing thread list fetched.")
        
        let threads: [ChatThread] = event.postback?.threads?.map {
            ChatThread(id: $0.idOnExternalPlatform, name: $0.threadName, canAddMoreMessages: $0.canAddMoreMessages)
        } ?? []
        
        threadsService?.threads = threads
        
        delegate?.onThreadsLoad(threads)
    }
    
    func processCustomerAuthorizedEvent(_ messageData: Data) {
        LogManager.trace("Processing customer authorized.")
        
        if socketService.connectionContext.channelConfig.isAuthorizationEnabled {
            guard let decoded: CustomerAuthorizedEventDTO = try? messageData.decode() else {
                delegate?.onError(CXoneChatError.missingParameter("data"))
                return
            }
            guard let token = decoded.postback.data.accessToken else {
                delegate?.onError(CXoneChatError.missingAccessToken)
                return
            }
            
            socketService.accessToken = token
            
            let firstName = decoded.postback.data.consumerIdentity.firstName?
                .mapNonEmpty { $0 } ?? socketService.connectionContext.customer?.firstName
            let lastName = decoded.postback.data.consumerIdentity.lastName?
                .mapNonEmpty { $0 } ?? socketService.connectionContext.customer?.lastName
            
            socketService.connectionContext.customer = CustomerIdentityDTO(
                idOnExternalPlatform: decoded.postback.data.consumerIdentity.idOnExternalPlatform,
                firstName: firstName,
                lastName: lastName
            )
        }
        
        processCustomerReconnectEvent()
    }
    
    func processProactiveAction(decode: ProactiveActionEventDTO?, data: Data) {
        LogManager.trace("Processing proactive action.")
        
        guard let decode = decode else {
            didReceiveError(CXoneChatError.missingParameter("ProactiveActionEventDTO"))
            return
        }
        
        switch decode.data.actionType {
        case .welcomeMessage:
            LogManager.trace("Processing proactive action of type - welcome message.")
            
            guard let messageData = decode.data.data?.content.bodyText else {
                didReceiveError(CXoneChatError.missingParameter("messageData"))
                return
            }
            
            if let fields = decode.data.data?.customFields {
                customerFieldsService?.updateFields(fields)
            }
            
            UserDefaults.standard.set(messageData, forKey: "welcomeMessage")
            
            threadsService?.onWelcomeMessageReceived()
            delegate?.onWelcomeMessageReceived()
        case .customPopupBox:
            LogManager.trace("Processing proactive action of type - custom popup box.")
            
            guard let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                didReceiveError(CXoneChatError.missingParameter("dictionary"))
                return
            }
            
            let data = dict["data"] as? [String: Any]
            let proactiveAction = data?["proactiveAction"] as? [String: Any]
            let action = proactiveAction?["action"] as? [String: Any]
            let actionData = action?["data"] as? [String: Any]
            let content = actionData?["content"] as? [String: Any]
            let variables = content?["variables"] as? [String: Any]
            
            guard let actionId = action?["actionId"] as? String else {
                didReceiveError(CXoneChatError.missingParameter("actionId"))
                return
            }
            guard let variables, !variables.isEmpty else {
                didReceiveError(CXoneChatError.missingParameter("variables"))
                return
            }
            
            let id = UUID(uuidString: actionId) ?? UUID()
            
            delegate?.onProactivePopupAction(data: variables, actionId: id)
        }
    }
    
    func assigneeDidChange(_ threadIdOnExternalPlatform: UUID, agent: AgentDTO) {
        LogManager.trace("Assignee did change.")
        
        guard let index = threadsService?.threads.index(of: threadIdOnExternalPlatform) else {
            didReceiveError(CXoneChatError.missingParameter("threadIndex"))
            return
        }
        
        let agent = AgentMapper.map(agent)
        threadsService?.threads[index].assignedAgent = agent
        delegate?.onAgentChange(agent, for: threadIdOnExternalPlatform)
    }
    
    func didReceiveMessageWasRead(_ threadIdOnExternalPlatform: UUID) {
        LogManager.trace("Did receive message was read.")
        
        delegate?.onAgentReadMessage(threadId: threadIdOnExternalPlatform)
    }

    func didReceiveMessage(message: MessageCreatedEventDTO) {
        LogManager.trace("Did receive message.")

        let message = MessageMapper.map(message.data.message)
        
        guard let convoIndex = threadsService?.threads.index(of: message.threadId) else {
            didReceiveError(CXoneChatError.missingParameter("threadIndex"))
            return
        }
        
        threadsService?.threads[convoIndex].messages.append(message)
        
        delegate?.onNewMessage(message)
    }
    
    func addMessages(messages: [MessageDTO], scrollToken: String) {
        LogManager.trace("Adding messages.")
        
        guard let firstMessage = messages.first else {
            didReceiveError(CXoneChatError.missingParameter("firstMessage"))
            
            delegate?.onLoadMoreMessages([])
            return
        }
        
        let sortedMessages = messages
            .sorted { $0.createdAt < $1.createdAt }
            .map(MessageMapper.map)
        
        if let threadIndex = threadsService?.threads.index(of: firstMessage.threadIdOnExternalPlatform) {
            threadsService?.threads[threadIndex].messages.insert(contentsOf: sortedMessages, at: 0)
            threadsService?.threads[threadIndex].scrollToken = scrollToken
        }
        
        delegate?.onLoadMoreMessages(sortedMessages)
    }
    
    func threadRecovered(_ threadEvent: ThreadRecoveredEventDTO) {
        LogManager.trace("Processing thread recovered.")
        
        let sortedMessages = threadEvent.postback.data.messages
            .sorted { $0.createdAt < $1.createdAt }
            .map(MessageMapper.map)
        
        guard let threadIndex = threadsService?.threads.index(of: threadEvent.postback.data.thread.idOnExternalPlatform),
              var thread = threadsService?.threads.getThread(with: threadEvent.postback.data.thread.idOnExternalPlatform)
        else {
            didReceiveError(CXoneChatError.missingParameter("threadIndex"))
            return
        }
        guard let messageCount = threadsService?.threads[threadIndex].messages.count else {
            didReceiveError(CXoneChatError.missingParameter("messageCount"))
            return
        }
        
        sortedMessages.forEach { message in
            guard !thread.messages.contains(where: { $0.id == message.id }) else {
                return
            }
            
            thread.messages.append(message)
        }

        thread.messages = thread.messages.sorted { $0.createdAt < $1.createdAt }
        thread.assignedAgent = threadEvent.postback.data.inboxAssignee.map(AgentMapper.map)
        thread.canAddMoreMessages = threadEvent.postback.data.thread.canAddMoreMessages
        thread.contactId = threadEvent.postback.data.consumerContact.id
        thread.name = threadEvent.postback.data.thread.threadName
        
        if thread.messages.count > messageCount {
            thread.scrollToken = threadEvent.postback.data.messagesScrollToken
        }
        
        threadsService?.threads[threadIndex] = thread
        
        delegate?.onThreadLoad(thread)
    }
    
    func didUploadAttachments(_ message: EventDTO) {
        LogManager.trace("Did upload attachments.")
        
        guard let data = try? JSONEncoder().encode(message) else {
            didReceiveError(CXoneChatError.missingParameter("data"))
            return
        }
        
        socketService.send(message: data.utf8string)
    }
    
    func loadThreadData() {
        LogManager.trace("Loading thread data.")
        
        do {
            if socketService.connectionContext.channelConfig.settings.hasMultipleThreadsPerEndUser {
                try threadsService?.load()
            } else {
                try threadsService?.load(with: nil)
            }
        } catch {
            didReceiveError(error)
        }
    }
    
    func appendMessageToThread(_ message: MessageDTO) throws {
        LogManager.trace("Appending a message to the thread.")
        
        try threadsService?.appendMessageToThread(message)
    }
    
    func setThreadAgent(agent: AgentDTO, threadIdOnExternalPlatform: UUID) throws {
        LogManager.trace("Setting a thread agent.")
        
        try threadsService?.setThreadAgent(agent: agent, idOnExternalPlatform: threadIdOnExternalPlatform)
    }
}
