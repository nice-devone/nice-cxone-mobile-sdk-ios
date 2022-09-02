import Foundation

@available(iOS 13.0, *)
extension CXOneChat: CXOneChatDelegate {

    func saveAccessToken(_ decode: TokenRefreshedEvent?) {
        socketService.accessToken = decode?.postback.data.accessToken
    }
    
    func notifyThreadArchivedEvent() {
        onThreadArchive?()
    }
    
    func processMoreMessagesEvent(_ decode: MoreMessagesLoadedEvent?) {
        addMessages(messages: decode?.postback.data.messages ?? [], scrollToken: decode?.postback.data.scrollToken ?? "")
    }
    
    func processCustomerReconnectEvent() {
        do {
            try setVisitor()
            try reportVisit()
            onConnect?() // Check this it is ok to notify connection even when error happens.
        } catch {
            onError?(CXOneChatError.notConnected)
        }
    }
    
    func notifyAgentTypingStartedEvent(_ data: AgentTypingEvent) {
        onAgentTypingStart?(data.data.thread.idOnExternalPlatform)
    }
    
    func notifyAgentTypingEndEvent(_ data: AgentTypingEvent) {
        onAgentTypingEnd?(data.data.thread.idOnExternalPlatform)
    }
    
    func processMessageCreatedEvent(_ messageData: Data) {
        let message = String(data: messageData, encoding: .utf8) ?? ""
        if let error: ServerError = decodeData(messageData), error.message.isEmpty == false {
            didReceiveError(error)
        } else if message.contains("CUSTOM") {
            guard let dict = try? JSONSerialization.jsonObject(with: messageData) as? [String: Any] else {return}
            let data = dict["data"] as! [String: Any]
            let message = data["message"] as! [String: Any]
            let content = message["messageContent"] as! [String: Any]
            let payload = content["payload"] as! [String: Any]
            let elements = payload["elements"] as! [Any]
            onCustomPluginMessage?(elements)
        } else if let decoded: MessageCreatedEvent = decodeData(messageData) {
            contactId = decoded.data.case.id
            didReceiveMessage(message: decoded)
        }
    }
    
    func processThreadRecoverEvent(_ decode: ThreadRecoveredEvent?) {
        contactId = decode?.postback.data.consumerContact.id
        guard let decoded = decode else {return}
        let index = threads.firstIndex(where: {
            $0.idOnExternalPlatform == decoded.postback.data.thread.idOnExternalPlatform
        })
        if index == nil {
            let thread = ChatThread(id: decoded.postback.data.thread.id, idOnExternalPlatform: decoded.postback.data.thread.idOnExternalPlatform, threadName: decode?.postback.data.thread.threadName ,threadAgent: decoded.postback.data.ownerAssignee, scrollToken: decoded.postback.data.messagesScrollToken)
            threads.append(thread)
        }
        threadRecovered(decoded)
    }
    
    func processMessageReadChangeEvent(_ decoded: MessageReadByAgentEvent?) {
        guard let decoded = decoded else { return }
        guard let readThread = threads.first(where: {
            $0.idOnExternalPlatform == decoded.data.message.threadIdOnExternalPlatform
        }) else { return }
        guard let readThreadIndex = threads.firstIndex(where: {
            $0.idOnExternalPlatform == decoded.data.message.threadIdOnExternalPlatform
        }) else { return }
        guard let messageIndex = readThread.messages.firstIndex(where: {
            $0.idOnExternalPlatform == decoded.data.message.idOnExternalPlatform
        }) else { return }
        self.threads[readThreadIndex].messages[messageIndex] = decoded.data.message
        didReceiveMessageWasRead(decoded.data.message.threadIdOnExternalPlatform)
    }
    
    func processThreadLastMessage(_ lastMessage: Message) {
        do {
            try appendMessageToThread(message: lastMessage)
            let updatedThread = threads.first(where: {
                $0.idOnExternalPlatform == lastMessage.threadIdOnExternalPlatform
            })!
            onThreadInfoLoad?(updatedThread)
        } catch {
            didReceiveError(error)
        }
    }
    
    func processThreadAgent(_ lastMessage: Message, _ agent: Agent) {
        let threadIdOnExternalPlatform = lastMessage.threadIdOnExternalPlatform
        setThreadAgent(agent: agent, threadIdOnExternalPlatform: threadIdOnExternalPlatform)
    }
    
    func processInboxAssigneeChangeEvent(_ decoded: ContactInboxAssigneeChangedEvent?) {
        guard let decoded = decoded else { return }
        let agent = decoded.data.inboxAssignee
        assigneeDidChange(decoded.data.case.threadIdOnExternalPlatform, agent: agent)
    }
    
    func processThreadListFetchedEvent(event: GenericEvent) {
        let threads = event.postback?.data?.threads?.map({
            ChatThread(id: $0.id,
                       idOnExternalPlatform: $0.idOnExternalPlatform,threadName: $0.threadName,
                       messages: [], canAddMoreMessages: $0.canAddMoreMessages)
        }) ?? []
        self.threads = threads
        onThreadsLoad?(threads)
    }
    
    func processCustomerAuthorizedEvent(_ messageData: Data) {
        let decode: CustomerAuthorizedEvent? = decodeData(messageData)
        if channelConfig?.isAuthorizationEnabled ?? false {
            guard let token = decode?.postback.data.accessToken else {
                onError?(CXOneChatError.missingAccessToken)
                return
            }
            guard let customerIdentity = decode?.postback.data.consumerIdentity else {
                onError?(CXOneChatError.missingCustomerId)
                return
            }
            self.socketService.accessToken = token
            self.customer = Customer(id: customerIdentity.idOnExternalPlatform, firstName: customerIdentity.firstName ?? "", lastName: customerIdentity.lastName ?? "")
        }
        processCustomerReconnectEvent()
    }
    
    func processProactiveAction(decode: ProactiveActionEvent?, data: Data) {
        if decode?.data.proactiveAction.action.actionType == .welcomeMessage {
            if let messageData = decode?.data.proactiveAction.action.data?.content.bodyText {                UserDefaults.standard.set(messageData, forKey: "welcomeMessage")
                onWelcomeMessageReceived?()
            }
        } else if decode?.data.proactiveAction.action.actionType == .customPopupBox {
            guard let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {return}
            let data = dict["data"] as! [String: Any]
            let proactiveAction = data["proactiveAction"] as! [String: Any]
            let action = proactiveAction["action"] as! [String: Any]
            let actionData = action["data"] as! [String: Any]
            let content = actionData["content"] as! [String: Any]
            let variables = content["variables"] as! [String: Any]
            let actionId = action["actionId"] as! String
            let id =  UUID(uuidString: actionId) ?? UUID()
            if !variables.isEmpty {
                onProactivePopupAction?(variables, id)
            }
        }
    }
    
    /// Handles a message received from the WebSocket.
    /// - Parameters:
    ///   - message: The message text that was received from the WebSocket.
    func handleMessage(message: String) {
        let messageData: Data = Data(message.utf8)
        // Decode generic event
        let event: GenericEvent? = decodeData( Data(message.utf8))
        guard let event = event else { return }
        
        // Generic event is an error
        if let error = event.error {
            didReceiveError(error)
        }

        let usePostBack: Bool = event.eventType == nil ? true : false

        switch usePostBack ? event.postback?.eventType : event.eventType {
        case .senderTypingStarted:
            let data: AgentTypingEvent? = decodeData(messageData)
            guard let data = data else { return }
            if data.data.user != nil {
                notifyAgentTypingStartedEvent(data)
            }
        case .senderTypingEnded:
            let data: AgentTypingEvent? = decodeData(messageData)
            guard let data = data else { return }
            if data.data.user != nil {
                notifyAgentTypingEndEvent(data)
            }
        case .messageCreated:
            processMessageCreatedEvent(messageData)
        case .threadRecovered:
            let decode: ThreadRecoveredEvent? = decodeData(messageData)
            processThreadRecoverEvent(decode)
        case .messageReadChanged:
            let decoded: MessageReadByAgentEvent? = decodeData(messageData)
            processMessageReadChangeEvent(decoded)
        case .contactInboxAssigneeChanged:
            let decoded: ContactInboxAssigneeChangedEvent? = decodeData(messageData)
            processInboxAssigneeChangeEvent(decoded)
        case .threadListFetched:
            processThreadListFetchedEvent(event: event)
        case .customerAuthorized:
            processCustomerAuthorizedEvent(messageData)
        case .customerReconnected:
            processCustomerReconnectEvent()
        case .moreMessagesLoaded:
            let decode: MoreMessagesLoadedEvent? = decodeData(messageData)
            processMoreMessagesEvent(decode)
        case .threadArchived:
            notifyThreadArchivedEvent()
        case .tokenRefreshed:
            let decode: TokenRefreshedEvent? = decodeData(messageData)
            saveAccessToken(decode)
        case .threadMetadataLoaded:
            let decode: ThreadMetadataLoadedEvent? = decodeData(messageData)
            guard let lastMessage = decode?.postback.data.lastMessage else {return}
            processThreadLastMessage(lastMessage)
            guard let agent = decode?.postback.data.ownerAssignee else {return}
            processThreadAgent(lastMessage, agent)
        case .threadUpdated:
            onThreadUpdate?()
        case .fireProactiveAction:
            let decode: ProactiveActionEvent? = decodeData(messageData)
            processProactiveAction(decode: decode, data: messageData)
        default:
            break
        }
    }
    
    func didOpenConnection() {
        guard let brandId = brandId else {return}
        guard let visitorId = visitorId else {return}
        guard let destinationId = destinationId else {return}
        guard let channelId = channelId else {return}
        let payload = StoreVisitorEventsPayload(eventType: .storeVisitorEvent,
                                               brand: Brand(id: brandId),
                                               visitor: VisitorIdentifier(id: LowerCaseUUID(uuid: visitorId)),
                                               destination: Destination(id: LowerCaseUUID(uuid: destinationId)),
                                               data: .visitorEvent(
                                                VisitorsEvents(
                                                    visitorEvents: [
                                                        VisitorEvent(id: LowerCaseUUID(uuid: UUID()),
                                                                     type: .visitorVisit,
                                                                     createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                                     data: nil
                                                                    )]) ), channel: ChannelIdentifier(id: channelId))
        let event = StoreVisitorEvents(action: .chatWindowEvent, eventId: UUID(), payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = self.getStringFromData(data)
        socketService.send(message: message)
    }

    func assigneeDidChange(_ threadIdOnExternalPlatform: UUID, agent: Agent) {
        if let index = self.threads.firstIndex(where: {$0.idOnExternalPlatform == threadIdOnExternalPlatform}) {
            threads[index].threadAgent = agent
            onAgentChange?(agent, threadIdOnExternalPlatform)
        }
    }
    
    func didReceiveMessageWasRead(_ threadId: UUID) {
        onAgentReadMessage?(threadId)
    }

    func didCloseConnection() {
        onUnexpectedDisconnect?()
    }
    
    func didReceiveMessage(message: MessageCreatedEvent) {
        insertMessage(message: message.data.message)
    }
    
    func insertMessage(message: Message) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let convoIndex = self.threads.firstIndex(where: {$0.idOnExternalPlatform == message.threadIdOnExternalPlatform}) {
                self.threads[convoIndex].messages.append(message)
                self.onNewMessage?(message)
            }
        }
    }
    
    func addMessages(messages: [Message], scrollToken: String) {
        if messages.isEmpty {
            onLoadMoreMessages?([])
            return
        }
        var sortedMessages = messages
        sortedMessages.sort(by: {
            $0.createdAt < $1.createdAt
        })
        if let threadIndex = self.threads.firstIndex(where: {$0.idOnExternalPlatform == messages.first!.threadIdOnExternalPlatform}) {
            threads[threadIndex].messages.insert(contentsOf: sortedMessages, at: 0)
            threads[threadIndex].scrollToken = scrollToken
        }
        onLoadMoreMessages?(sortedMessages)
    }
    
    public func threadRecovered(_ threadEvent: ThreadRecoveredEvent) {
        let sortedMessages = threadEvent.postback.data.messages.sorted(by: {$0.createdAt < $1.createdAt})
        guard let threadIndex = threads.firstIndex(where: {
            $0.idOnExternalPlatform == threadEvent.postback.data.thread.idOnExternalPlatform
        }) else { return }

        // Add new messages
        let threadMessagesBefore = threads[threadIndex].messages.count
        for message in sortedMessages {
            addMessageFromThread(thread: threadEvent, message: message)
        }
        let newMessagesAdded = threads[threadIndex].messages.count > threadMessagesBefore
        
        // Sort the added messages
        let messages = threads[threadIndex].messages
        threads[threadIndex].messages = messages.sorted(by: { $0.createdAt < $1.createdAt })
        threads[threadIndex].threadName = threadEvent.postback.data.thread.threadName
        // Get the scroll token, if new messages are added
        if newMessagesAdded {
            threads[threadIndex].scrollToken = threadEvent.postback.data.messagesScrollToken
        }
        onThreadLoad?(threads[threadIndex])
    }
    
    /// handle error in the socket and notifify the implementer
    /// - Parameter error: an Error ocurred, 
    func didReceiveError(_ error: Error) {
        if let error = error as? OperationError, error.errorCode == .recoveringThreadFailed {
            onThreadLoadFail?()
        } else if let error = error as? OperationError, error.errorCode == .customerReconnectFailed {
            do {
                try self.refreshToken()
            } catch {
                onError?(error)
            }
        } else if let error = error as? OperationError, error.errorCode == .tokenRefreshFailed {
            onTokenRefreshFailed?()
        } else {
            onError?(error)
        }
    }
    
    /// handle the success of upload an attachment and create a message event with the attachments and text in case provided
    /// - Parameter message: the event for the message
    func didUploadAttachments(_ message: Event) {
        guard let data = getDataFrom(message) else {return}
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    func addMessageFromThread(thread: ThreadRecoveredEvent, message: Message) {
        if let index = threads.firstIndex(where: {$0.idOnExternalPlatform == thread.postback.data.thread.idOnExternalPlatform}) {
            if threads[index].messages.contains(where: {
                $0.idOnExternalPlatform == message.idOnExternalPlatform
            }) == false {
                threads[index].messages.append(message)
            }
        }
    }
    
    func loadThreadData() {
        if channelConfig?.settings.hasMultipleThreadsPerEndUser ?? false {
            do {
                try loadThreads()
            } catch {
                print(error.localizedDescription)
            }
        } else {
            do {
                try self.loadThread()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func appendMessageToThread(message: Message) throws {
        guard let index = threads.firstIndex(where: {
            $0.idOnExternalPlatform == message.threadIdOnExternalPlatform
        }) else { throw CXOneChatError.invalidThread }
        threads[index].messages.append(message)
    }
    
    func refreshToken() throws {
        let customer = try getCustomerIdentity(with: true)
        guard let token = socketService.accessToken?.token else {
            onTokenRefreshFailed?()
            throw CXOneChatError.missingAccessToken }
        var auth = customer
        auth.firstName = nil
        auth.lastName = nil
        let eventData = RefreshTokenPayloadData(accessToken: AccessTokenPayload(token: token))
        
        let event = try createEvent(eventType: .refreshToken, eventData: EventData.refreshTokenPayload(eventData))
        guard let data = getDataFrom(event) else {return}
        let string = getStringFromData(data)
        socketService.send(message: string, shouldCheck: false)
    }
    
    fileprivate func getFullName(name: String) -> String {
        let set =  NSOrderedSet(array: name.components(separatedBy: " "))
        let array = set.array as! [String]
        let fullName = array.joined(separator: " ")
        return fullName
    }
    
    func setThreadAgent(agent: Agent, threadIdOnExternalPlatform: UUID) {
        guard let index = threads.firstIndex(where: {
            $0.idOnExternalPlatform == threadIdOnExternalPlatform
        }) else {return}
        threads[index].threadAgent = agent
    }

    /// Decodes the data to be used.
    ///
    /// - Returns: The decoded data.
    internal func decodeData<T>(_ data: Data) -> T? where T: Codable {
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            if let anotherError = try? JSONDecoder().decode(ServerError.self, from: data) {
                self.didReceiveError(anotherError)
            }
            self.didReceiveError(error)
            return nil
        }
    }
}
