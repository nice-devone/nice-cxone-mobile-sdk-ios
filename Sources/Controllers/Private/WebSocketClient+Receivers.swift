//
//  File.swift
//  
//
//  Created by Customer Dynamics Development on 10/26/21.
//

import Foundation
import MessageKit // TODO: Move this out of the SDK

@available(iOS 13.0, *)
extension CXOneChat: CXOneChatDelegate {
    func configurationLoaded(config: ChannelConfiguration) {
        onChannelConfigLoad?(config)
        loadThreadDataClosure?()
    }
    
    func threadArchived() {
        onThreadArchive?()
    }
    
	func remoteCustomFieldsWereSet() {
        onCustomerCustomFieldsSet?()
    }

    func remoteContactFieldsWereSet() {
        onContactCustomFieldsSet?()
    }
    
    func assigneeDidChange(_ thread: String, customer: Customer) {
        if let index = self.threads.firstIndex(where: {$0.id == thread}) {
            threads[index].threadAgent = customer
            onAgentChange?()
        }
    }
    
    func didReceiveMessageWasRead(_ thread: String) {
        onAgentReadMessage?(thread)
    }
    
    func didSendMessageWasRead(_ thread: ThreadCodable) {}
    
    public func getInitialsFromSender(sender: SenderType) -> String {
        let customer = Customer(senderId: "", displayName: sender.displayName)
        guard let first = customer.firstName.first else {return ""}
        guard let last = customer.familyName.first else {return "\(first)"}
        let inital = "\(first)\(last)"
        return inital
    }
    
    public func getAvatarFor(sender: SenderType) -> Avatar {
        let initials = getInitialsFromSender(sender: sender)
        switch sender.senderId {
        case "000000":
            return Avatar(image: nil, initials: "SS")
        default:
            return Avatar(image: nil, initials: initials)
        }
    }
    
    public func didOpenConnection() {
        guard let brandId = brandId else {return}
        guard let visitorId = visitorId else {return}
        guard let destinationId = destinationId else {return}
        guard let channelId = channelId else {return}
        let payload = StoreVisitorEventPayload(eventType: .storeVisitorEvent,
                                      brand: Brand(id: brandId),
                                      visitor: Visitor(id: visitorId.uuidString),
                                      destination: Destination(id: destinationId.uuidString),
                                      data: .visitorEvent(
                                        VisitorsEvents(
                                            visitorEvents: [
                                                VisitorEvent(id: UUID().uuidString,
                                                             brandId: brandId,
                                                             type: .visitorVisit,
                                                             visitorId: visitorId.uuidString,
                                                             destinationId: destinationId.uuidString,
                                                             channelId: channelId,
                                                             createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                             data: nil)]) ))
        let event = StoreVisitorEvent(action: "chatWindowEvent", eventId: UUID().uuidString, payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = self.getStringFromData(data)
        socketService.send(message: message)
    }
    
    public func didCloseConnection() {
        // TODO: - Notify via closure to consumer contection closed or loosed 
    }
    
    public func didReceiveMessage(_ message: MessagePostSuccess) {
        let attachments: [AttachmentSuccess] = message.data.message.attachments
        for attachment in attachments {
            let message = Message(attachment: attachment,
                                  threadId: message.data.thread.idOnExternalPlatform,
                                  message: message)
            insertMessage(message)
        }
        if !message.data.message.messageContent.payload.text.isEmpty || message.data.message.messageContent.type == EventMessageType.plugin.rawValue {
            insertMessage(Message(message: message))
        }else {
            let mess = Message(message: message)
            let index = threads.firstIndex(where: {
                $0.idOnExternalPlatform == mess.threadId
            })
            if index == nil {
                let thread: ThreadObject = ThreadObject(id: message.data.case.threadId, idOnExternalPlatform: mess.threadId, messages: [], threadAgent: mess.user)
                threads.append(thread)
                onThreadCreate?()
            }
        }
    }
    
    func insertMessage(_ message: Message) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let convoIndex = self.threads.firstIndex(where: {$0.idOnExternalPlatform == message.threadId}) {
                self.threads[convoIndex].messages.append(message)
                if message.threadId == self.getCurrentThread()?.idOnExternalPlatform {
                    self.onMessageAddedToChatView?(message)
                }else {
                    self.onMessageAddedToOtherThread?(message)
                }
            }
        }
    }
    
    func addMessages(messages: [MessagePostback]) {
        var messagesArray: [Message] = []
        for message in messages {
            var newMessage: Message
            if !message.attachments.isEmpty {
                for attachment in message.attachments {
                    newMessage = Message(attachment: attachment, threadId: threadIdOnExternalPlatform ?? UUID(), message: message)
                    messagesArray.append(newMessage)
                }
                if !message.messageContent.payload.text.isEmpty {
                    newMessage = Message(threadId: threadIdOnExternalPlatform ?? UUID(), message: message)
                    messagesArray.append(newMessage)
                }
            }else {
                newMessage = Message(threadId: threadIdOnExternalPlatform ?? UUID(), message: message)
                messagesArray.append(newMessage)
            }
        }
        messagesArray.sort(by: {
            $0.sentDate < $1.sentDate
        })
        if let convoIndex = self.threads.firstIndex(where: {$0.idOnExternalPlatform == threadIdOnExternalPlatform ?? UUID()}) {
            threads[convoIndex].messages.insert(contentsOf: messagesArray, at: 0)
        }
        
        onLoadMoreMessages?()
    }
    
    public func didReceiveData(_ message: Data) {
        onData?(message)
    }
    
    public func didReceiveThread(_ thread: RetrievePostSuccess) {
        let threadFinal = thread.postback.data.messages.sorted(by: {$0.createdAt < $1.createdAt})
        for message in threadFinal {
            addMessageFromThread(thread: thread, message: message)
        }
        let index = threads.firstIndex(where: {
            $0.idOnExternalPlatform == thread.postback.data.thread.idOnExternalPlatform
        })
        if let index = index {
            let messages = threads[index].messages
            threads[index].messages = messages.sorted(by: { $0.sentDate < $1.sentDate })
        }

        onThreadCreate?()
    }
    
    public func didReceiveError(_ error: Error) {
        if let error = error as? OperationError, error.errorCode == "RecoveringThreadFailed" || error.errorCode == "RecoveringLivechatFailed" {
            onLoadThreadFail?()
        }else if let error = error as? OperationError, error.errorCode == "ConsumerReconnectionFailed"{
            self.refreshToken()
        } else if let error = error as? OperationError, error.errorCode == "TokenRefreshingFailed" {
            onTokenRefreshFailed?()
        } else {
            onError?(error)
        }
    }
    
    public func didSendMessage(_ message: Event) {}
    
    public func didReceiveThreads(_ threads: [ThreadObject]) {
        self.threads = threads
        onLoadThreads?(threads)
    }
    
    public func clientTypingDidStart() {
        onAgentTypingStart?()
    }
    
    public func clientTypingDidEnd() {
        onAgentTypingEnd?()
    }
    
    public func didSendPing() {}
    
    public func didUploadAttachments(_ message: Event) {
        guard let data = getDataFrom(message) else {return}
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    public func imageDidUpload(_ url: String, _ error: Bool?) {
    }
    
    func addMessageFromThread(thread: RetrievePostSuccess, message: MessagePostback) {
        if let index = threads.firstIndex(where: {$0.idOnExternalPlatform == thread.postback.data.thread.idOnExternalPlatform}) {
            for attachment in message.attachments {
                let message = Message.init(attachment: attachment,
                                           threadId: thread.postback.data.thread.idOnExternalPlatform,
                                           message: message)
                threads[index].messages.append(message)
                onMessageAddedToThread?(message)
            }
            if !message.messageContent.payload.text.isEmpty || message.messageContent.type == EventMessageType.plugin.rawValue {
                let message = Message.init(thread: thread.postback.data.thread, message: message)
                if threads[index].messages.contains(where: {
                    $0.messageId.contains(message.messageId)
                }) == false {
                    threads[index].messages.append(message)
                }
                onMessageAddedToThread?(message)
            }
        }
    }
    
    func loadThreadData() {
        if getChannelConfiguration()?.settings.hasMultipleThreadsPerEndUser == true {
            do {
                try loadThreads()
            }catch {
                print(error.localizedDescription)
            }
        } else {
            do {
                try self.loadThread()
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func remoteClientAuthorized() {
        if getChannelConfiguration() != nil {
            loadThreadData()
        }else {
            loadThreadDataClosure = { [weak self] in
                self?.loadThreadData()
            }
        }
        onCustomerAuthorize?()
    }
    
    func addlastMessageToThread(message: LastMessage) throws {
        guard let index = threads.firstIndex(where: {
            $0.id == message.postId ?? ""
        })else { throw CXOneChatError.invalidThread }
        let postid = message.postId ?? ""
        let threadIdOnExternalString = postid.components(separatedBy: "_").last ?? ""
        guard let messageIdString = message.idOnExternalPlatform else {throw CXOneChatError.invalidMessageId}
        guard let messageId = UUID(uuidString: messageIdString.uppercased()) else { throw CXOneChatError.invalidMessageId }
        guard let idOnExternalPlataform = UUID(uuidString: threadIdOnExternalString) else {throw CXOneChatError.invalidThread }
        let messageModel = Message(messageType: .text, plugin: message.messageContent?.payload.elements ?? [], text: message.messageContent?.payload.text ?? "", user: Customer(senderId: message.endUser?.id ?? "", displayName: message.endUser?.name ?? ""), messageId: messageId, date: message.createdAt?.iso8601withFractionalSeconds ?? Date(), threadId:  idOnExternalPlataform, isRead: message.isRead ?? false)
        threads[index].messages.append(messageModel)
        onThreadInfoLoad?()
    }
    
    func refreshToken() {
        guard let brandId = brandId else {return}
        guard let channel = channelId else {return}
        guard let customer = getIdentity(with: true) else {return}
        guard let token = socketService.accessToken?.token else {
            onTokenRefreshFailed?()
            return}
        var auth = customer
        auth.firstName = nil
        auth.lastName = nil
        let refresh = EventFactory.shared.refreshTokenEvent(brandId: brandId, channel: channel, customer: auth, token: token)
        guard let data = getDataFrom(refresh) else {return}
        let string = getStringFromData(data)
        socketService.send(message: string, shouldCheck: false)
    }
    
    fileprivate func getFullName(name: String) -> String {
        let set =  NSOrderedSet(array: name.components(separatedBy: " "))
        let array = set.array as! [String]
        let fullname = array.joined(separator: " ")
        return fullname
    }
    
    /// Handles a message received from the WebSocket.
    ///
    /// - Parameters:
    ///   - event: The `GenericPost` that was decoded.
    ///   - message: The message text that was received from the WebSocket.
    func handleMessage(message: String) {
        let event: GenericPost? = decodeData( Data(message.utf8))
        guard let event = event else {
            return
        }
        if let error = event.error {
            didReceiveError(error)
        }
        
        let messageData: Data = Data(message.utf8)
        let usePostBack: Bool = event.eventType == nil ? true : false
        switch usePostBack ? event.postback?.eventType : event.eventType {
        case .senderTypingEnded:
            let data: AgentTypingEnded? = self.decodeData(messageData)
            guard data != nil else { return }
            onAgentTypingEnd?()
        case .senderTypingStarted:
            let data: AgentTypingStarted? = decodeData(messageData)
            guard let data = data else { return }
            if data.data.thread.idOnExternalPlatform == threadIdOnExternalPlatform {
                onAgentTypingStart?()
            }            
        case .messageCreated:
            if let error: ServerError = decodeData(messageData), error.message.isEmpty == false {
                didReceiveError(error)
            }else if message.contains("variables") {
                didReceiveData(messageData)
            } else if let decoded: MessagePostSuccess = decodeData(messageData){
                if let id = decoded.data.case.id {
                    contactId = id
                }
                if threadIdOnExternalPlatform == nil {
                    let index = threads.firstIndex(where: {
                        $0.idOnExternalPlatform == decoded.data.thread.idOnExternalPlatform
                    })
                    if let index = index {
                        setCurrentThread(idOnExternalPlatform: threads[index].idOnExternalPlatform)
                    }
                }
                didReceiveMessage(decoded)
            }
        case .threadRecovered, .livechatRecovered:
            let decode: RetrievePostSuccess? = decodeData(messageData)
            contactId = decode?.postback.data.consumerContact.caseId
            guard let decoded = decode else {return}            
            let index = threads.firstIndex(where: {
                $0.idOnExternalPlatform == decoded.postback.data.thread.idOnExternalPlatform
            })
            if index == nil {
                let name = decoded.postback.data.thread.author.name
                let fullName = getFullName(name: name)
                let thread = ThreadObject(id: decoded.postback.data.thread.id, idOnExternalPlatform: decoded.postback.data.thread.idOnExternalPlatform, threadAgent: Customer(senderId: "", displayName: fullName))
                threads.append(thread)
            }
            if threadIdOnExternalPlatform == nil, let idOnExternalPlataform = decode?.postback.data.thread.idOnExternalPlatform {
                setCurrentThread(idOnExternalPlatform:  idOnExternalPlataform )
            }
            scrollToken = decoded.postback.data.messagesScrollToken
            didReceiveThread(decoded)
        case .messageReadChanged:
            let decoded: MessageReadEventByAgent? = decodeData(messageData)
            guard let decoded = decoded else { return }
            didReceiveMessageWasRead(decoded.data.message.threadId)
        case .contactInboxAssigneeChanged:
            let decoded: ContactInboxAssigneeChanged? = decodeData(messageData)
            guard let decoded = decoded else {    return  }
            let customer = Customer(senderId: decoded.data.inboxAssignee.incontactId,
                                    displayName: decoded.data.inboxAssignee.firstName + " " + decoded.data.inboxAssignee.surname)
            assigneeDidChange(decoded.data.case.threadId, customer: customer)
        case .threadListFetched:
            let threads = event.postback?.data?.threads?.map({
                ThreadObject(id: $0.id ?? "",
                             idOnExternalPlatform: UUID(uuidString: $0.idOnExternalPlatform ?? "") ?? UUID(),
                             messages: [],
                             threadAgent: Customer(senderId: UUID().uuidString, displayName: "" ), canAddMoreMessages: $0.canAddMoreMessages ?? true)
            })
            self.didReceiveThreads(threads ?? [])
        case .customerAuthorized:
            if !authorizationCode.isEmpty && !self.codeVerifier.isEmpty {
                let decode: AuthAuthorizeConsumerSuccess? = decodeData(messageData)
                if  let token = decode?.postback.data.accessToken {
                    socketService.accessToken = token
                    let formatter =  PersonNameComponentsFormatter()
                    if let id = decode?.postback.data.consumerIdentity.idOnExternalPlatform, id.count == 64 {
                        guard let name = decode?.postback.data.consumerIdentity.firstName else {return}
                        guard let person = formatter.personNameComponents(from: name) else { return }
                        customer = Customer(senderId: id, displayName: formatter.string(from: person))
                    }else {
                        var person = PersonNameComponents()
                        person.givenName = decode?.postback.data.consumerIdentity.firstName ?? ""
                        person.familyName = decode?.postback.data.consumerIdentity.lastName ?? ""
                        customer = Customer(senderId: decode?.postback.data.consumerIdentity.idOnExternalPlatform ?? "" , displayName: formatter.string(from: person))
                    }
                }
            } else {
                let decode: AuthorizeConsumerSuccess? = decodeData(messageData)
                if let token = decode?.postback.data.accessToken {
                    socketService.accessToken = token
                }
            }
            setVisitor()
            remoteClientAuthorized()
        case .consumerReconnected:
            setVisitor()
            remoteClientAuthorized()
        case .moreMessagesLoaded:
            let decode: LoadMoreMessagesResponse? = decodeData(messageData)
            scrollToken = decode?.postback.data.scrollToken ?? ""
            addMessages(messages: decode?.postback.data.messages ?? [])
                                           // user: user)
        case .threadArchived:
            self.threadArchived()
        case .tokenRefreshed:
            let decode: TokenRefreshed? = decodeData(messageData)
            socketService.accessToken = decode?.postback.data.accessToken
            
        case .threadMetadataLoaded:
            let decode: LoadMetadatPost? = decodeData(messageData)
            guard let lastMessage = decode?.postback?.data?.lastMessage else {return}
            do {
                try addlastMessageToThread(message: lastMessage)
            }catch {
                didReceiveError(error)
            }
            guard let owner = decode?.postback?.data?.ownerAssignee else {return}
            guard let postId = lastMessage.postId else {return}
            setThreadAgent(owner: owner, postId: postId)
        default:
            break
        }
    }
    
    func setThreadAgent(owner: OwnerAssignee,postId: String) {
        guard let index = threads.firstIndex(where: {
            $0.id == postId
        }) else {return}
        threads[index].threadAgent = Customer(senderId: "", displayName: owner.fullName)
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
