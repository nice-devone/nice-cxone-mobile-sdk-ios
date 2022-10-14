import Foundation
import KeychainSwift
import UIKit

/// Allows for interacting with chat features of the CXone platform.
@available(macOS 10.15, iOS 13.0, *)
public class CXOneChat {
    
    /// The singleton instance of the CXone chat SDK.
    public static var shared = CXOneChat()

    // MARK: - Callbacks
    
    /// Callback to be called when the connection has successfully been established.
    public var onConnect: (() -> Void)?
    
    /// Callback to be called when the connection unexpectedly drops.
    public var onUnexpectedDisconnect: (() -> Void)?
    
    /// Callback to be called when a thread has been loaded/recovered.
    public var onThreadLoad: ((ChatThread) -> Void)?
    
    /// Callback to be called when loading a thread has failed. This can be used to prompt
    /// the user to create their first thread.
    public var onThreadLoadFail: (() -> Void)?
    
    /// Callback to be called when a thread has been archived.
    public var onThreadArchive: (() -> Void)?
    
    /// Callback to be called when all of the threads for the customer have loaded.
    public var onThreadsLoad: (([ChatThread]) -> Void)?
    
    /// Callback to be called when thread info has loaded.
    public var onThreadInfoLoad: ((ChatThread) -> Void)?
    
    /// Callback to be called when the thread has been updates (thread name changed).
    public var onThreadUpdate: (() -> Void)?
    
    /// Callback to be called when a new page of message has been loaded.
    public var onLoadMoreMessages: (([Message]) -> Void)?
    
    /// Callback to be called when a new message arrives.
    public var onNewMessage: ((Message) -> Void)?
    
    /// Callback to be called when a custom plugin message is received.
    public var onCustomPluginMessage: (([Any]) -> Void)?
    
    /// Callback to be called when the agent for the contact has changed.
    public var onAgentChange: ((Agent, UUID) -> Void)?
    
    /// Callback to be called when the agent has read a message.
    public var onAgentReadMessage: ((UUID) -> Void)?
    
    /// Callback to be called when the agent has started typing.
    public var onAgentTypingStart: ((UUID) -> Void)? // TODO: Combine the two into one callback with T/F like Android?
    
    /// Callback to be called when the agent has stopped typing.
    public var onAgentTypingEnd: ((UUID) -> Void)?
        
    /// Callback to be called when the custom fields are set for a contact.
    public var onContactCustomFieldsSet: (() -> Void)?

    /// Callback to be called when the custom fields are set for a customer.
    public var onCustomerCustomFieldsSet: (() -> Void)?
    
    /// Callback to be called when an error occurs.
    public var onError: ((Error) -> Void)?
    
    /// Callback to be called when refreshing the token has failed.
    public var onTokenRefreshFailed: (() -> Void)?
    
    /// Callback to be called when a welcome message proactive action has been received
    var onWelcomeMessageReceived: (()-> Void)?
    
    /// Callback to be called when a custom popup proactive action is received.
    public var onProactivePopupAction: (([String: Any], UUID) -> Void)?

    
    // MARK: - Properties

    /// The customer currently using the app.
    public var customer: Customer? {
        get {
            if (UserDefaults.standard.bool(forKey: "cxOneHasRun") != true) {
                KeychainSwift().clear()
                UserDefaults.standard.set(true, forKey: "cxOneHasRun")
                return nil
            }
            let customerData = KeychainSwift().getData("customer")
            if let customerData = customerData {
                return try? JSONDecoder().decode(Customer.self, from: customerData)
            } else {
                return nil
            }
        }
        set(customer) {
            let encodedCustomer = try? JSONEncoder().encode(customer)
            guard let encodedCustomer = encodedCustomer else { return }
            KeychainSwift().set(encodedCustomer, forKey: "customer")
        }
    }

    /// The list of all chat threads.
    public internal(set) var threads = [ChatThread]()
    
    /// The current channel configuration for currently connected CXone session.
    public internal(set) var channelConfig: ChannelConfiguration?

    /// Whether the SDK has been successfully connected to CXone yet.
    internal var connected: Bool {
        let isConnected = socketService.connected && environment != nil && channelId != nil && brandId != nil && channelConfig != nil && customer != nil && visitorId != nil && destinationId != nil
        return isConnected
    }

    /// The environment/location to use for CXone.
    private var environment: EnvironmentDetails?
        
    /// The id of the brand for the chat.
    internal var brandId: Int?
    
    /// The id of the channel for the chat.
    internal var channelId: String?
    
    /// The id generated for the destination.
    internal var destinationId: UUID?
    
    /// The unique contact id for the last loaded thread.
    internal var contactId: String? // TODO: Rework this into the ChatThread class to support chatting in two threads simultaneously?
    
    /// The id for the visitor.
    internal var visitorId: UUID? {
        get {
            let visitorId = KeychainSwift().getData("visitorId")
            if let visitorId = visitorId {
                return try? JSONDecoder().decode(UUID.self, from: visitorId)
            } else {
                return nil
            }
        }
        set(visitorId) {
            let encodedVisitorId = try? JSONEncoder().encode(visitorId)
            guard let encodedVisitorId = encodedVisitorId else { return }
            KeychainSwift().set(encodedVisitorId, forKey: "visitorId")
        }
    }

    /// Class for interacting with the WebSocket.
    internal let socketService: SocketService
    
    /// The token of the device for push notifications.
    internal var deviceToken: String?
    
    /// The code used for login with OAuth.
    internal var authorizationCode = ""
    
    /// The code verifier used for OAuth (if PKCE is required).
    internal var codeVerifier = ""
    
    internal var session: URLSession = URLSession.shared
    
    internal init(socketService: SocketService, session: URLSession = URLSession.shared) {
        self.socketService = socketService
        self.session = session
    }
    
    private init() {
        self.socketService = SocketService()
        self.socketService.delegate = self
    }
            
    /// Connects to the CXone service and configures the SDK for use.
    /// - Parameters:
    ///   - environment: The CXone ``Environment`` used to connect. Relates to your location.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    public func connect(environment: Environment, brandId: Int, channelId: String) throws {
        self.environment = environment
        try internalConnect(brandId: brandId, channelId: channelId)
    }
    
    /// Connects to the CXone service and configures the SDK for use.
    /// - Parameters:
    ///   - chatURL: The URL to be used for chat requests (channel config and attachment upload).
    ///   - socketURL: The URL to be used for the WebSocket connection.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    public func connect(chatURL: String, socketURL: String, brandId: Int, channelId: String) throws {
        environment = CustomEnvironment(chatURL: chatURL, socketURL: socketURL)
        try internalConnect(brandId: brandId, channelId: channelId)
    }
    
    /// Disconnects from the CXone service and keeps the customer signed in.
    public func disconnect() {
        socketService.disconnect()
    }
    
    /// Signs the customer out and disconnects from the CXone service.
    public static func signOut() {
        KeychainSwift().clear()
        UserDefaults.standard.removeObject(forKey: "cxOneHasRun")
        shared = CXOneChat()
    }
    
    /// Makes an HTTP request to get the channel configuration details.
    /// - Parameters:
    ///   - environment: The CXone ``Environment`` used to connect. Relates to your location.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    ///   - completion: Completion handler to be called when the request is successful or fails.
    public func getChannelConfiguration(environment: Environment, brandId: Int, channelId: String, completion: @escaping (Result<ChannelConfiguration, Error>) -> Void) throws {
        guard let url = URL(string: "\(environment.chatURL)/1.0/brand/\(brandId)/channel/\(channelId)") else {
            throw CXOneChatError.channelConfigFailure
        }
        try internalGetChannelConfiguration(url: url, completion: completion)
    }
    
    /// Makes an HTTP request to get the channel configuration details.
    /// - Parameters:
    ///   - chatURL: The chat URL for the custom environment.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    ///   - completion: Completion handler to be called when the request is successful or fails.
    public func getChannelConfiguration(chatURL: String, brandId: Int, channelId: String, completion: @escaping (Result<ChannelConfiguration, Error>) -> Void) throws {
        guard let url = URL(string: "\(chatURL)/1.0/brand/\(brandId)/channel/\(channelId)") else {
            throw CXOneChatError.channelConfigFailure
        }
        try internalGetChannelConfiguration(url: url, completion: completion)
    }
    
    /// Sets the auth code from an OAuth provider in order to authorize the customer with authentication code. This code must be provided before ``connect(environment:brandId:channelId:)`` or  ``connect(chatURL:socketURL:brandId:channelId:)``  if the channel is configured to use OAuth.
    /// - Parameter authCode: The authorization code from an OAuth provider. NOTE: This is not an access token. This is the authorization code that one would use to obtain an access token.
    public func setAuthCode(authCode: String) {
        authorizationCode = authCode
    }
    
    /// Sets the code verifier to be used for OAuth if the OAuth provider uses PKCE. This must be passed so that CXone
    /// can retrieve an auth token.
    /// - Parameter codeVerifier: The generated code verifier.
    public func setCodeVerifier(codeVerifier: String) {
        self.codeVerifier = codeVerifier
    }
    
    /// Sets the name to be used for the customer in the chat.
    /// - Parameters:
    ///   - firstName: The first name for the customer.
    ///   - lastName: The last name for the customer.
    public func setCustomerName(firstName: String, lastName: String) {
        customer?.firstName = firstName
        customer?.lastName = lastName
    }
    
    /// Registers a device to be used for push notifications.
    /// - Parameter deviceToken: The unique token for the device to be registered.
    public func registerDeviceToken(deviceToken: Data) throws {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        self.deviceToken = token
    }
    
    /// Pings the CXone chat server to ensure that a connection is established.
    public func ping() {
        socketService.ping()
    }

    
    // MARK: Exposed thread methods
    
    /// Loads all of the threads for the current customer.
    /// - Warning: Should only be used on a channel configured for multiple threads.
    public func loadThreads() throws {
        try checkForConnection()
        if !channelConfig!.settings.hasMultipleThreadsPerEndUser {
            throw CXOneChatError.unsupportedChannelConfig
        }
        let retrieveThread = try createEvent(eventType: .fetchThreadList)
        guard let data = getDataFrom(retrieveThread) else {
            throw CXOneChatError.invalidData
        }
        let messageString = getStringFromData(data)
        socketService.send(message: messageString)
    }
    
    /// Loads the a thread for the customer and gets messages.
    /// - Parameter threadIdOnExternalPlatform: The id of the thread to load. Optional, if omitted, it will attempt to load the customer's active thread. If there is no active thread, this returns an error.
    public func loadThread(threadIdOnExternalPlatform: UUID? = nil) throws {
        try checkForConnection()
        var eventData: EventData? = nil
        if let idOnExternalPlatform = threadIdOnExternalPlatform {
            let threadId = try getThreadId(threadIdOnExternalPlatform: idOnExternalPlatform)
            eventData = EventData.loadThreadData(ThreadEventData(thread: Thread(id: threadId, idOnExternalPlatform: idOnExternalPlatform)))
        }
        let retrieveThread = try createEvent(eventType: .recoverThread, eventData: eventData)
        guard let data = getDataFrom(retrieveThread) else { throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    /// Loads information about the thread. This will provide the most recent message for the thread.
    /// - Parameter threadIdOnExternalPlatform: The unique id of the thread to load.
    public func loadThreadInfo(threadIdOnExternalPlatform: UUID) throws {
        try checkForConnection()
        let threadId = try getThreadId(threadIdOnExternalPlatform: threadIdOnExternalPlatform)
        let eventData = EventData.archiveThreadData(ThreadEventData(thread: Thread(id: threadId, idOnExternalPlatform: threadIdOnExternalPlatform)))
        let retrieveThread = try createEvent(eventType: EventType.loadThreadMetadata, eventData: eventData)
        guard let data = getDataFrom(retrieveThread) else { throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    /// Creates a new thread by sending an initial message to the thread.
    /// - Warning: If attempted on a channel that only supports a single thread, this will fail once a thread is already created.
    /// - Returns: The threadIdOnExternalPlatform of the newly created thread.
    public func createThread() throws -> UUID {
        try checkForConnection()
        if !channelConfig!.settings.hasMultipleThreadsPerEndUser && !self.threads.isEmpty {
            throw CXOneChatError.unsupportedChannelConfig
        }
        let id = UUID()
        threads.append(ChatThread(id: "\(channelId!)_\(id.uuidString)", idOnExternalPlatform: id, messages: []))
        if let welcomeMessage = UserDefaults.standard.string(forKey: "welcomeMessage") {
            do {
                try sendOutboundMessage(message: welcomeMessage, threadIdOnExternalPlatform: id)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            onWelcomeMessageReceived = { [weak self] in
                guard let welcomeMessage = UserDefaults.standard.string(forKey: "welcomeMessage") else { return }
                do {
                    try self?.sendOutboundMessage(message: welcomeMessage, threadIdOnExternalPlatform: id)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        return id
    }
    
    
    /// Updates the name for a thread.
    /// - Parameters:
    ///   - threadName: The new name for the thread.
    ///   - threadIdOnExternalPlatform: The unique id of the thread to update.
    /// - Warning: Should only be used on a channel configured for multiple threads.
    public func updateThreadName(threadName: String, threadIdOnExternalPlatform: UUID) throws {
        try checkForConnection()
        if !channelConfig!.settings.hasMultipleThreadsPerEndUser {
            throw CXOneChatError.unsupportedChannelConfig
        }
        guard let index = threads.firstIndex(where: {
            $0.idOnExternalPlatform == threadIdOnExternalPlatform
        }) else { throw CXOneChatError.invalidThread }
        threads[index].threadName = threadName
        if threads[index].messages.isEmpty {
            onThreadUpdate?()
        } else {
            
            let event = try createEvent(eventType: .updateThread, eventData: EventData.updateThreadData(ThreadEventData(thread: Thread(id: nil, idOnExternalPlatform: threadIdOnExternalPlatform, threadName: threadName))))
            
            guard let data = getDataFrom(event) else {
                throw CXOneChatError.invalidData
            }
            let string = getStringFromData(data)
            socketService.send(message: string)
        }
    }

    /// Archives a thread from the list of all threads.
    /// - parameter threadIdOnExternalPlatform: The id of the thread to archive.
    /// - Warning: Should only be used on a channel configured for multiple threads.
    public func archiveThread(threadIdOnExternalPlatform: UUID) throws {
        try checkForConnection()
        if !channelConfig!.settings.hasMultipleThreadsPerEndUser {
            throw CXOneChatError.unsupportedChannelConfig
        }
        guard let index = threads.firstIndex(where: {
            $0.idOnExternalPlatform == threadIdOnExternalPlatform
        }) else { throw CXOneChatError.invalidThread }
        let threadId = try getThreadId(threadIdOnExternalPlatform: threadIdOnExternalPlatform)
        let thread = Thread(id: threadId, idOnExternalPlatform: threadIdOnExternalPlatform)
        let event = try createEvent(eventType: .archiveThread, eventData: EventData.archiveThreadData(ThreadEventData(thread: thread)))
        guard let data = getDataFrom(event) else { throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string)
        threads[index].canAddMoreMessages = false
    }
    
    /// Reports that the most recent message of the specified thread was read by the customer.
    /// - Parameter threadIdOnExternalPlatform: The unique id of the thread.
    public func markThreadAsRead(threadIdOnExternalPlatform: UUID) throws {
        try checkForConnection()
        guard let index = threads.firstIndex(where: {
            $0.idOnExternalPlatform == threadIdOnExternalPlatform
        }) else { throw CXOneChatError.invalidThread }
        let threadIdString = threads[index].id
//        let id = try getCustomerIdentity(with: false)
        let thread = Thread(id: threadIdString, idOnExternalPlatform: threadIdOnExternalPlatform)
        let event = try createEvent(eventType: .messageSeenByCustomer, eventData: EventData.archiveThreadData(ThreadEventData(thread: thread)))
        
        guard let data = getDataFrom(event) else {  throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    /// Reports that the customer has started typing in the specified chat thread.
    /// - parameter threadIdOnExternalPlatform: The id of the thread where typing was started.
    public func reportTypingStart(threadIdOnExternalPlatform: UUID) throws {
        try checkForConnection()
        let threadId = try getThreadId(threadIdOnExternalPlatform: threadIdOnExternalPlatform)
        let eventData = EventData.customerTypingData(CustomerTypingEventData(thread: Thread(id: threadId, idOnExternalPlatform: threadIdOnExternalPlatform)))
        let event = try createEvent(eventType: .senderTypingStarted, eventData: eventData)
        guard let data = getDataFrom(event) else { throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    /// Reports that the customer has stopped typing in the specified chat thread thread.
    /// - parameter threadIdOnExternalPlatform: The id of the thread where typing was started.
    public func reportTypingEnd(threadIdOnExternalPlatform: UUID) throws {
        try checkForConnection()
        let threadId = try getThreadId(threadIdOnExternalPlatform: threadIdOnExternalPlatform)
        let eventData = EventData.customerTypingData(CustomerTypingEventData(thread: Thread(id: threadId, idOnExternalPlatform: threadIdOnExternalPlatform)))
        let event = try createEvent(eventType: .senderTypingEnded, eventData: eventData)
        guard let data = getDataFrom(event) else { throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string)
    }

    // MARK: Exposed message methods
    
    /// Loads additional messages in the specified thread.
    /// - parameter threadIdOnExternalPlatform: The id of the thread for which to load more messages.
    public func loadMoreMessages(threadIdOnExternalPlatform: UUID) throws {
        try checkForConnection()
        let threadId = try getThreadId(threadIdOnExternalPlatform: threadIdOnExternalPlatform)
        guard let chatThread = threads.first(where: {
            $0.idOnExternalPlatform == threadIdOnExternalPlatform
        }) else { throw CXOneChatError.invalidThread }
        if chatThread.hasMoreMessagesToLoad == false {
            throw CXOneChatError.noMoreMessages
        }
        let oldestDate = chatThread.messages.first?.createdAt
        guard let oldestDate = oldestDate else { throw CXOneChatError.invalidOldestDate }
        let thread = Thread(id: threadId, idOnExternalPlatform: chatThread.idOnExternalPlatform, threadName: chatThread.threadName)
        let event = try createEvent(eventType: .loadMoreMessages, eventData: EventData.loadMoreMessageData(LoadMoreMessagesEventData(scrollToken: chatThread.scrollToken, thread: thread, oldestMessageDatetime: oldestDate)))
        
        guard let data = getDataFrom(event) else {  throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    /// Sends a message in the specified chat thread through CXone chat.
    /// - Parameters:
    ///   - message: The message text to send.
    ///   - threadIdOnExternalPlatform: The id of the thread in which the message is to be sent.
    public func sendMessage(message: String, threadIdOnExternalPlatform: UUID) throws {
        try checkForConnection()
        let accessTokenPayload = AccessTokenPayload(token: socketService.accessToken?.token)
        let index = threads.firstIndex(where: {
            $0.idOnExternalPlatform == threadIdOnExternalPlatform
        })
        var threadName: String?
        if let index = index {
            threadName = threads[index].messages.isEmpty ? nil : threads[index].threadName
        }
        let thread = Thread(idOnExternalPlatform: threadIdOnExternalPlatform, threadName: threadName)
        let messagePayload = MessagePayload(text: message, elements: [])
        let messageContent = MessageContent(type: MessageContentType.text, payload: messagePayload)
        let browserFingerprint = BrowserFingerprint()
        let customFields = CustomFieldsData(customFields: [])
        let eventData = EventData.sendMessageData(SendMessageEventData(thread: thread, messageContent: messageContent, idOnExternalPlatform: UUID(), consumer: customFields, consumerContact: customFields, attachments: [], browserFingerprint: browserFingerprint, accessToken: accessTokenPayload))
        let event = try createEvent(eventType: .sendMessage, eventData: eventData)
        guard let data = getDataFrom(event) else { throw CXOneChatError.invalidData}
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    func sendOutboundMessage(message: String, threadIdOnExternalPlatform: UUID) throws {
        try checkForConnection()
        let accessTokenPayload = AccessTokenPayload(token: socketService.accessToken?.token)
        let index = threads.firstIndex(where: {
            $0.idOnExternalPlatform == threadIdOnExternalPlatform
        })
        var threadName: String?
        if let index = index {
            threadName = threads[index].messages.isEmpty ? nil : threads[index].threadName
        }
        let thread = Thread(idOnExternalPlatform: threadIdOnExternalPlatform, threadName: threadName)
        let messagePayload = MessagePayload(text: message, elements: [])
        let messageContent = MessageContent(type: MessageContentType.text, payload: messagePayload)
        let browserFingerprint = BrowserFingerprint()
        let customFields = CustomFieldsData(customFields: [])
        let eventData = EventData.sendOutboundMessageData(SendOutboundMessageEventData(thread: thread, messageContent: messageContent, idOnExternalPlatform: UUID(), consumerContact: customFields, attachments: [], browserFingerprint: browserFingerprint, accessToken: accessTokenPayload))
        let event = try createEvent(eventType: .sendOutbound, eventData: eventData)
        guard let data = getDataFrom(event) else { throw CXOneChatError.invalidData}
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    /// Sends a message with attachments in the current thread through CXone chat.
    /// - Parameters:
    ///   - message: The message text to send along with the attachments (optional).
    ///   - threadIdOnExternalPlatform: The id of the thread in which the message and attachments are to be sent.
    ///   - attachments: The attachments to send.
    public func sendMessageWithAttachments(message: String = "", at threadIdOnExternalPlatform: UUID, with attachments: [AttachmentUpload]) async throws {
        try await uploadAttachments(message: message, attachments: attachments, at: threadIdOnExternalPlatform)
    }
    
    // MARK: Exposed custom field methods

    /// Sets custom fields to be saved on a contact (specific thread).
    /// - Parameters:
    ///     - customFields: The custom fields to be saved.
    ///     - threadIdOnExternalPlatform: The id of the thread for the custom fields.
    public func setContactCustomFields(customFields: [CustomField], threadIdOnExternalPlatform: UUID) throws {
        try checkForConnection()
        
        let threadId = try getThreadId(threadIdOnExternalPlatform: threadIdOnExternalPlatform)
        // FIXME: Get the contactId from the list of threads somehow? So we don't have to store the id like we are now
        guard let contactId = contactId else {
            throw CXOneChatError.missingContactId
        }
        let contact = ContactIdentifier(id: contactId)
        let thread = Thread(id: threadId, idOnExternalPlatform: threadIdOnExternalPlatform)
        let eventData = EventData.setContactCustomFieldsData(SetContactCustomFieldsEventData(thread: thread, customFields: customFields, consumerContact: contact))
        let event = try createEvent(eventType: .setCustomerContactCustomFields, eventData: eventData)
        guard let encoded = getDataFrom(event) else { throw CXOneChatError.invalidData }
        let string = getStringFromData(encoded)
        socketService.send(message: string)
    }
    
    /// Sets custom fields to be saved for a customer (persists across all threads involving the customer).
    /// - Parameters
    ///     - customFields: The custom fields to be saved.
    public func setCustomerCustomFields(customFields: [CustomField]) throws {
        try checkForConnection()
        let eventData = EventData.setCustomerCustomFieldData(CustomFieldsData(customFields: customFields))
        let event = try createEvent(eventType: .setCustomerCustomFields, eventData: eventData)
        guard let data = getDataFrom(event) else { throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    // MARK: - Exposed Analytics Methods
    
    
    /// Reports to CXone that a some page/screen in the app has been viewed by the visitor.
    /// - Parameters:
    ///   - title: The title or description of the page that was viewed.
    ///   - uri: A URI uniquely identifying the page. This can be any unique identifier.
    public func reportPageView(title: String, uri: String) throws {
        try checkForConnection()
        let payload = StoreVisitorEventsPayload(eventType: .storeVisitorEvents,
                                               brand: Brand(id: brandId!),
                                               visitor: VisitorIdentifier(id: LowerCaseUUID(uuid: visitorId!)),
                                               destination: Destination(id: LowerCaseUUID(uuid: destinationId!)),
                                               data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                                VisitorEvent(id: LowerCaseUUID(uuid: UUID()),
                                                             type: .pageView,
                                                             createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                             data: .pageViewData(PageViewData(url: uri,
                                                                                              title: title )))])),
                                               channel: ChannelIdentifier(id: channelId ?? ""))
        let event = StoreVisitorEvents(action: .chatWindowEvent, eventId: UUID(), payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    /// Reports to CXone that the chat window/view has been opened by the visitor.
    public func reportChatWindowOpen() throws {
        try checkForConnection()
        let payload = StoreVisitorEventsPayload(eventType: .storeVisitorEvents,
                                               brand: Brand(id: brandId!),
                                               visitor: VisitorIdentifier(id: LowerCaseUUID(uuid: visitorId!)),
                                               destination: Destination(id: LowerCaseUUID(uuid: destinationId!)),
                                               data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                                VisitorEvent(id: LowerCaseUUID(uuid: UUID()),
                                                             type: .chatWindowOpened,
                                                             createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                             data: nil)])),
                                               channel: ChannelIdentifier(id: channelId ?? ""))
        let event = StoreVisitorEvents(action: .chatWindowEvent, eventId: UUID(), payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    
    /// Reports to CXone that the visitor has visited the app.
    public func reportVisit() throws {
        try checkForConnection()
        let payload = StoreVisitorEventsPayload(eventType: .storeVisitorEvents,
                                               brand: Brand(id: brandId!),
                                               visitor: VisitorIdentifier(id: LowerCaseUUID(uuid: visitorId!)),
                                               destination: Destination(id: LowerCaseUUID(uuid: destinationId!)),
                                               data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                                VisitorEvent(id: LowerCaseUUID(uuid: UUID()),
                                                             type: .visitorVisit,
                                                             createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                             data: nil)])),
                                               channel: ChannelIdentifier(id: channelId ?? ""))
        let event = StoreVisitorEvents(action: .chatWindowEvent, eventId: UUID(), payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message, shouldCheck: false)
    }
    
    
    /// Reports to CXone that a conversion has occurred.
    /// - Parameters:
    ///   - conversionType: The type of conversion. Can be any value.
    ///   - conversionValue: The value associated with the conversion (for example, unit amount). Can be any number.
    public func reportConversion(conversionType: String, conversionValue: Double) throws {
        try checkForConnection()
        let payload = StoreVisitorEventsPayload(eventType: .storeVisitorEvents,
                                               brand: Brand(id: brandId!),
                                               visitor: VisitorIdentifier(id: LowerCaseUUID(uuid: visitorId!)),
                                               destination: Destination(id: LowerCaseUUID(uuid: destinationId!)),
                                               data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                                VisitorEvent(id: LowerCaseUUID(uuid: UUID()),
                                                             type: .conversion,
                                                             createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                             data: .conversionData(ConversionData(conversionType: conversionType,
                                                                                                  conversionValue: conversionValue,
                                                                                                  conversionTimeWithMilliseconds: Date().iso8601withFractionalSeconds)))])),
                                               channel: ChannelIdentifier(id: channelId ?? ""))
        let event = StoreVisitorEvents(action: .chatWindowEvent, eventId: UUID(), payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    
    /// Reports to CXone that some event occurred with the visitor. This can be used to report any custom event that may not be covered by
    /// other existing methods.
    /// - Parameters:
    ///   - data: Any data associated with the event.
    public func reportCustomVisitorEvent(data: VisitorEventData) throws {
        try checkForConnection()
        let payload = StoreVisitorEventsPayload(eventType: .storeVisitorEvents,
                                      brand: Brand(id: brandId!),
                                               visitor: VisitorIdentifier(id: LowerCaseUUID(uuid: visitorId!)),
                                               destination: Destination(id: LowerCaseUUID(uuid: destinationId!)),
                                      data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                        VisitorEvent(id: LowerCaseUUID(uuid: UUID()),
                                                     type: .custom,
                                                     createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                     data: data)])),
                                               channel: ChannelIdentifier(id: channelId ?? ""))
        let event = StoreVisitorEvents(action: .chatWindowEvent, eventId: UUID(), payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    /// Reports to CXone that a proactive action was displayed to the visitor.
    /// - Parameter data: The proactive action that was displayed.
    public func reportProactiveActionDisplay(data: ProactiveActionDetails) throws {
        try checkForConnection()
        let payload = StoreVisitorEventsPayload(eventType: .storeVisitorEvents,
                                      brand: Brand(id: brandId!),
                                               visitor: VisitorIdentifier(id: LowerCaseUUID(uuid: visitorId!)),
                                               destination: Destination(id: LowerCaseUUID(uuid: destinationId!)),
                                      data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                        VisitorEvent(id: LowerCaseUUID(uuid: UUID()),
                                                     type: .proactiveActionDisplayed,
                                                     createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                     data: .proactiveActionData(data))])),
                                               channel: ChannelIdentifier(id: channelId ?? ""))
        let event = StoreVisitorEvents(action: .chatWindowEvent, eventId: UUID(), payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    
    /// Reports to CXone that a proactive action was clicked or acted upon by the visitor.
    /// - Parameter data: The proactive action that was clicked.
    public func reportProactiveActionClick(data: ProactiveActionDetails) throws {
        try checkForConnection()
        let payload = StoreVisitorEventsPayload(eventType: .storeVisitorEvents,
                                               brand: Brand(id: brandId!),
                                               visitor: VisitorIdentifier(id: LowerCaseUUID(uuid: visitorId!)),
                                               destination: Destination(id: LowerCaseUUID(uuid: destinationId!)),
                                               data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                                VisitorEvent(id: LowerCaseUUID(uuid: UUID()),
                                                             type: .proactiveActionClicked,
                                                             createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                             data: .proactiveActionData(data))])),
                                               channel: ChannelIdentifier(id: channelId ?? ""))
        let event = StoreVisitorEvents(action: .chatWindowEvent, eventId: UUID(), payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    /// Reports to CXone that a proactive action was successful and lead to a conversion.
    /// - Parameter data: The proactive action that was successful.
    public func reportProactiveActionSuccess(data: ProactiveActionDetails) throws {
        try checkForConnection()
        let payload = StoreVisitorEventsPayload(eventType: .storeVisitorEvents,
                                               brand: Brand(id: brandId!),
                                               visitor: VisitorIdentifier(id: LowerCaseUUID(uuid: visitorId!)),
                                               destination: Destination(id: LowerCaseUUID(uuid: destinationId!)),
                                               data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                                VisitorEvent(id: LowerCaseUUID(uuid: UUID()),
                                                             type: .proactiveActionSuccess,
                                                             createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                             data: .proactiveActionData(data))])),
                                               channel: ChannelIdentifier(id: channelId ?? ""))
        let event = StoreVisitorEvents(action: .chatWindowEvent, eventId: UUID(), payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    /// Reports to CXone that a proactive action failed to lead to a conversion.
    /// - Parameter data: The proactive action that failed.
    public func reportProactiveActionFail(data: ProactiveActionDetails) throws {
        try checkForConnection()
        let payload = StoreVisitorEventsPayload(eventType: .storeVisitorEvents,
                                               brand: Brand(id: brandId!),
                                               visitor: VisitorIdentifier(id: LowerCaseUUID(uuid: visitorId!)),
                                               destination: Destination(id: LowerCaseUUID(uuid: destinationId!)),
                                               data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                                VisitorEvent(id: LowerCaseUUID(uuid: UUID()),
                                                             type: .proactiveActionFailed,
                                                             createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                             data: .proactiveActionData(data))])),
                                               channel: ChannelIdentifier(id: channelId ?? ""))
        let event = StoreVisitorEvents(action: .chatWindowEvent, eventId: UUID(), payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    
    /// Manually executes a trigger that was defined in CXone. This can be used to test that proactive actions are displaying.
    /// - Parameter triggerId: The id of the trigger to manually execute.
    public func executeTrigger(triggerId: UUID) throws {
        try checkForConnection()
        let payload = ExecuteTriggerEventPayload(eventType: .executeTrigger,
                                        brand: Brand(id: brandId!),
                                        channel: ChannelIdentifier(id: channelId!),
                                                 consumerIdentity: CustomerIdentity(idOnExternalPlatform: customer!.id),
                                                 destination: Destination(id: LowerCaseUUID(uuid: destinationId!)),
                                                 visitor: VisitorIdentifier(id: LowerCaseUUID(uuid: visitorId!)),
                                        data: TriggerData(trigger: Trigger(id: LowerCaseUUID(uuid: triggerId))))
        let event = ExecuteTriggerEvent(action: .chatWindowEvent, eventId: UUID(), payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }

    // MARK: Other methods
    
    /// Shared logic for both connect methods.
    /// - Parameters:
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.

    private func internalConnect(brandId: Int, channelId: String) throws {
        self.brandId = brandId
        self.channelId = channelId
        if socketService.delegate == nil {
            socketService.delegate = self
        }
        // Connect the WebSocket
        do {
            try connectToSocket()
        } catch {
            throw CXOneChatError.webSocketConnectionFailure
        }
        
        // Get the channel configuration
        try getChannelConfiguration(chatURL: environment!.chatURL, brandId: brandId, channelId: channelId, completion: { result in
            switch result {
            case .success(let config):
                self.channelConfig = config
                self.generateDestinationId()
                self.generateVisitor()
                do {
                    try self.checkForAuthorization()
                } catch {
                    self.onError?(error)
                }
            case .failure(let error):
                self.onError?(error)
            }
        })
    }
    
    /// Shared logic for both getChannelConfiguration methods.
    /// - Parameters:
    ///   - url: The URL to use to get the channel configuration.
    ///   - completion: The completion handler to be called when the request is successful or fails.
    private func internalGetChannelConfiguration(url: URL, completion: @escaping (Result<ChannelConfiguration, Error>) -> Void) throws {
        let task = session.dataTask(with: url, completionHandler: { data, _, error in
            if let data = data {
                do {
                    let config = try JSONDecoder().decode(ChannelConfiguration.self, from: data)
                    completion(.success(config))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        })
        task.resume()
    }
    
    internal func setVisitor() throws {
        try checkForConnection()
        guard let brandId = brandId else { return }
        guard let visitorId = visitorId else { return }
        guard let destinationId = destinationId else { return }
        let customer = customer != nil ? CustomerIdentity(idOnExternalPlatform: customer!.id) : nil
        let payload =  StoreVisitorEventsPayload(eventType: .storeVisitor,
                                                brand: Brand(id: brandId),
                                                visitor: VisitorIdentifier(id: LowerCaseUUID(uuid: visitorId)),
                                                destination: Destination(id: LowerCaseUUID(uuid: destinationId)),
                                                data: .storeVisitorPayload(
                                                    Visitor(customerIdentity: customer,
                                                            browserFingerprint:
                                                                BrowserFingerprint(deviceToken: self.deviceToken ?? ""),
                                                            journey: nil,
                                                            customVariables: nil)),
                                                channel: ChannelIdentifier(id: channelId ?? ""))
        let event = StoreVisitorEvents(action: .chatWindowEvent, eventId: UUID(), payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message, shouldCheck: false)
    }

    // MARK: - Socket Authorization
    /// Authorizes a new customer to communicate through the WebSocket.
    private func authorizeCustomer() throws {
        try checkForConnection()
        let eventData = EventData.authorizeCustomerData(AuthorizeCustomerEventData(authorization: AuthorizeCustomerOAuth(authorizationCode: authorizationCode, codeVerifier: codeVerifier)))
        let event = try createEvent(eventType: .authorizeCustomer, eventData: eventData)
        guard let data = getDataFrom(event) else {  throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string,shouldCheck: false)
    }
    
    /// Reconnects a returning customer to communicate through the WebSocket.
    private func reconnectCustomer() throws {
        if (socketService.accessToken == nil) {
            throw CXOneChatError.missingAccessToken
        }
        let eventData = EventData.reconnectCustomerData(ReconnectCustomerEventData(accessToken: Token(token: socketService.accessToken?.token))!)
        let event = try createEvent(eventType: .reconnectCustomer, eventData: eventData)
        guard let data = getDataFrom(event) else { throw CXOneChatError.invalidData }
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    //MARK: - NetworkRequests
    /// Uploads attachments to the channel.
    /// - Parameters:
    ///   - message: The message text to send.
    ///   - attachments: an array or `Data`, `String`, `String` where the Data type is the attachment converted to Data,
    ///    second String is the file name and the third string is the mimeType to send to the server.
    ///   - threadIdOnExternalPlatform: The id of the thread for which to upload the attachments.
    private func uploadAttachments(message: String, attachments: [AttachmentUpload], at threadIdOnExternalPlatform: UUID) async throws {
        var index: Int = 0
        var attachment = [Attachment]()
        for try imageData in attachments {
//            let imageData = image.jpegData(compressionQuality: 0.7)
            let strBase64 = imageData.attachmentData.base64EncodedString()
                let url = URL(string: "\(environment!.chatURL)/1.0/brand/\(brandId!)/channel/\(channelId!)/attachment")!
                var request = URLRequest(url: url)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                let body: [String: String] = [
                    "content": strBase64,
                    "fileName": imageData.fileName,
                    "mimeType": imageData.mimeType
                ]
                request.httpBody = try! JSONEncoder().encode(body)
                            
            let ( data, response) = try await session.data(for: request)
            guard let response = response as? HTTPURLResponse else { return }
            guard (200 ... 299) ~= response.statusCode else { return }
            let decoded: AttachmentUploadSuccessResponse? = self.decodeData(data)
            guard let decoded = decoded else { return }
            attachment.append(Attachment(url: decoded.fileUrl, friendlyName: "fileUpload.ext", mimeType: "image/jpeg", fileName: "fileupload.jpg"))
            index += 1
        }
        if index >= attachments.count {
            guard let threadIndex = threads.firstIndex(where: {
                $0.idOnExternalPlatform == threadIdOnExternalPlatform
            }) else {return}
            var thread = Thread(idOnExternalPlatform: threadIdOnExternalPlatform)
            if threads[threadIndex].messages.isEmpty {
                thread.threadName = threads[threadIndex].threadName
            }
            let eventData = EventData.sendMessageData(SendMessageEventData(thread: thread, messageContent: MessageContent(type: .text, payload: MessagePayload(text: message, elements: [])), idOnExternalPlatform: UUID(), consumer: CustomFieldsData(customFields: []), consumerContact: CustomFieldsData(customFields: []), attachments: attachment ,browserFingerprint: BrowserFingerprint(), accessToken: AccessTokenPayload(token: socketService.accessToken?.token)))
            let event = try createEvent(eventType: .sendMessage, eventData: eventData)
            guard let data = getDataFrom(event) else { throw CXOneChatError.invalidData}
            let string = getStringFromData(data)
            socketService.send(message: string)
        }
    }
    
    fileprivate func checkForAuthorization() throws {
        if customer == nil {
            customer = Customer(id: UUID().uuidString, firstName: "", lastName: "")
            try authorizeCustomer()
        } else if channelConfig!.isAuthorizationEnabled {
            try reconnectCustomer()
        } else {
            try authorizeCustomer()
        }
    }
    
    fileprivate func generateVisitor() {
        if visitorId == nil {
            visitorId = UUID()
        }
    }
    
    private func generateDestinationId() {
        destinationId = UUID()
    }
    
    /// Connects to the WebSocket using the SocketService.
    internal func connectToSocket() throws {
        let brandItem = URLQueryItem(name: "brand", value: brandId!.description)
        let channelItem = URLQueryItem(name: "channelId", value: channelId)
        let customerIdItem = URLQueryItem(name: "customerId", value: customer?.id) // Customer isn't created at this point?
        let vQItem = URLQueryItem(name: "v", value: "4.74")
        let eioQItem = URLQueryItem(name: "EIO", value: "3")
        let transportQItem = URLQueryItem(name: "transport", value: "polling")
        let tQItem = URLQueryItem(name: "t", value: "NlrXzTa")
        let socketEndpoint = SocketEndpoint(environment: environment!, queryItems: [brandItem, channelItem, customerIdItem, vQItem, eioQItem, transportQItem, tQItem], method: .get)
        let request = try socketEndpoint.urlRequest()

        socketService.connect(socketURL: request)
        socketService.delegate = self
    }
    
    internal func getStringFromData(_ encoded: Data) -> String {
        let returnString =  String(data: encoded, encoding: .utf8) ?? ""
        return returnString
    }
    
    internal func getDataFrom<T: Encodable>(_ userToConnect: T) -> Data? {
        do {
            let encoded = try JSONEncoder().encode(userToConnect)
            return encoded
        } catch {
            self.didReceiveError(error)
            return nil
        }
    }
    
    /// Throws an error if the SDK is not connected to CXone yet.
    private func checkForConnection() throws {
        if !connected {
            disconnect()
            throw CXOneChatError.notConnected
        }
    }
    
    internal func getCustomerIdentity(with name: Bool = false) throws -> CustomerIdentity {
        var customerIdentity: CustomerIdentity
        guard let customer = customer else {
            throw CXOneChatError.invalidCustomerId
        }
        if !name {
            customerIdentity = CustomerIdentity(idOnExternalPlatform: customer.id)
        } else {
            customerIdentity = CustomerIdentity(idOnExternalPlatform: customer.id, firstName: customer.firstName, lastName: customer.lastName)
        }
        return customerIdentity
    }
    
    internal func createEvent(eventType: EventType, eventData: EventData? = nil) throws -> Event {
        let getIdentityWithName = eventType == EventType.sendMessage
        let customerIdentity = try getCustomerIdentity(with: getIdentityWithName)
        
        var event = Event(brandId: brandId!, channelId: channelId!, customerIdentity: customerIdentity, eventType: eventType, data: eventData)
        if eventType == .reconnectCustomer {
            event.payload.visitor = VisitorIdentifier(id: LowerCaseUUID(uuid: visitorId!))
        }
        return event
    }
    
    private func getThreadId(threadIdOnExternalPlatform: UUID) throws -> String {
        guard let threadId: String = threads.first(where: {
            $0.idOnExternalPlatform == threadIdOnExternalPlatform
        })?.id else {  throw CXOneChatError.invalidThread }
        return threadId
    }
}
