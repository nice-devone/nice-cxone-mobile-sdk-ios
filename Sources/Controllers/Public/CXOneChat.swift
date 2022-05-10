//
//  Created by user.id Dynamics Development on 8/31/21.
//

import Foundation
import KeychainSwift
import AWSPinpoint

/// Allows for interacting with chat features of the CXOne platform.
@available(macOS 10.15, iOS 13.0, *)
public class CXOneChat {
    
    /// The singleton instance of the CXOne chat SDK.
    public static let shared = CXOneChat()
    
    /// The list of all message threads.
    public internal(set) var threads = [ThreadObject]()
    
    /// Whether there are more messages to load in the current thread.
    public var hasMoreMessagesInThread: Bool {
        get {
            return scrollToken.isEmpty == false
        }
    }
    
    // MARK: - Closures
    
    /// Closure to be called when the channel configuration has been loaded.
    public var onChannelConfigLoad: ((ChannelConfiguration) -> Void)?
    
    /// Closure to be called when the customer has been authorized.
    public var onCustomerAuthorize: (() -> Void )?

    /// Closure to be called when a thread has been created.
    public var onThreadCreate: (() -> Void )?
    
    /// Closure to be called when a thread has been archived.
    public var onThreadArchive: (() -> Void )?
    
    /// Closure to be called when loading a thread has failed.
    public var onLoadThreadFail: (() -> Void )?
    
    /// Closure to be called when the threads have loaded.
    public var onLoadThreads: (([ThreadObject]) -> Void)?
    
    /// Closure to be called when thread info has loaded.
    public var onThreadInfoLoad: (() -> Void )?

    /// Closure to be called when the agent for the contact has changed.
    public var onAgentChange: (() -> Void )?
    
    /// Closure to be called when the agent has read a message.
    public var onAgentReadMessage: ((String) -> Void)?
    
    /// Closure to be called when the agent has started typing.
    public var onAgentTypingStart: (() -> Void )?
    
    /// Closure to be called when the agent has stopped typing.
    public var onAgentTypingEnd: (() -> Void )?
    
    /// Closure to be called when a new page of message has been loaded.
    public var onLoadMoreMessages: (() -> Void )?
    
    /// Closure to be called when a message is received in another thread.
    public var onMessageAddedToOtherThread: ((Message) -> Void)?
    
    /// Closure to be called when a message is added to a thread.
    public var onMessageAddedToThread: ((Message) -> Void)?
    
    /// Closure to be called when a message is added to the chat view.
    public var onMessageAddedToChatView: (( Message) -> Void)?
        
    /// Closure to be called when the custom fields are set for a contact.
    public var onContactCustomFieldsSet: (() -> Void )?

    /// Closure to be called when the custom fields are set for a customer.
    public var onCustomerCustomFieldsSet: (() -> Void )?
    
    /// Closure to be called when an error occurs.
    public var onError: ((Error) -> Void )?
    
    /// Closure to be called when data is received.
    public var onData: ((Data) -> Void)?
    
    public var onTokenRefreshFailed: (()->Void)?
    
    // MARK: - Properties
    
    /// The customer currently using the app.
    public var customer: Customer? {
        get {
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
        
    /// The id of the brand for the chat.
    internal var brandId: Int?
    
    /// The id of the channel for the chat.
    internal var channelId: String?
    
    /// The unique id for the current contact.
    internal var contactId: String?
    
    /// Class for interacting with the WebSocket.
    internal let socketService = SocketService()
    
    /// The environment/location to use for the CXOne.
    private var environment: EnvironmentDetails?
    
    /// The channel configuration used to know if it supports multithread and is a livechat.
    private var channelConfig: ChannelConfiguration?
    
    /// Instance for interacting with Amazon Pinpoint.
    private var pinpoint: AWSPinpoint?
    
    /// Options to configure the app upon launch.
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    /// The token of the device for push notifications.
    internal var token: String?
        
    /// The id for the current, active thread.
    internal var threadId: String! {
        return threads.first(where: {
            $0.active == true
        })?.id
    }

    /// The UUID id for the current, active thread.
    internal var threadIdOnExternalPlatform: UUID? {
        return threads.first(where: {
            $0.active == true
        })?.idOnExternalPlatform
    }
    
    /// The id of the thread to archive. Used to check if the user can't delete the thread from the list.
    private var archivedThreadId = ""
    
    /// The code used for login with OAuth.
    var authorizationCode = ""
    
    /// The code verifier used for OAuth (if PKCE is required).
    var codeVerifier = ""
    
    /// The token used to load more messages.
    var scrollToken: String = ""
    
    var visitorId: UUID? {
        get {
            let visititorData = KeychainSwift().getData("visitorId")
            if let visititorData =  visititorData {
                return try? JSONDecoder().decode(UUID.self, from: visititorData)
            } else {
                return nil
            }
        }
        set(visitorId) {
            let encodedCustomer = try? JSONEncoder().encode(visitorId)
            guard let encodedCustomer = encodedCustomer else { return }
            KeychainSwift().set(encodedCustomer, forKey:  "visitorId")
        }
    }
    
    
    var destinationId: UUID?
    
    internal var loadThreadDataClosure: (() -> Void)?
    
    // MARK: Exposed methods
    
    fileprivate func generateVisitor() {
        if visitorId == nil {
            visitorId = UUID()
        }
    }
    
    private func generateDestinationId() {
        destinationId = UUID()
    }
    
    /// Connects to the CXOne service and configures the SDK for use. If chat features are desired, an
    /// additional `connectChat` call is required.
    /// - Parameters:
    ///   - environment: The CXOne environment used to connect. Relates to your location.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    public func connect(environment: Environment, brandId: Int, channelId: String) {
        self.environment = environment
        self.brandId = brandId
        self.channelId = channelId
        generateVisitor()
        generateDestinationId()
        loadChannelConfiguration()
        connectToSocket()
    }
    
    
    /// Connects to the CXOne service and configures the SDK for use. If chat features are desired, an
    /// additional `connectChat` call is required.
    /// - Parameters:
    ///   - chatURL: The URL to be used for chat requests (channel config and attachment upload).
    ///   - socketURL: The URL to be used for the WebSocket connection.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    public func connect(chatURL: String, socketURL: String, brandId: Int, channelId: String) {
        environment = CustomEnvironment(chatURL: chatURL, socketURL: socketURL)
        self.brandId = brandId
        self.channelId = channelId
        generateVisitor()
        generateDestinationId()
        loadChannelConfiguration()
        connectToSocket()
    }
    
    /// Connects the customer and authorizes them to use CXOne chat features. This must be called after `connect()`.
    public func connectChat() throws {
        if socketService.socket == nil {
            throw CXOneChatError.socketNotReady
        }else {
            if authorizationCode.isEmpty  && customer != nil {
                do {
                    try reconnectCustomer()
                }catch {
                    throw(error)
                }
            }else {
                customer = Customer(senderId: UUID().uuidString, displayName: "")
                setVisitor()
                do {
                    try authorizeCustomer()
                }catch {
                    throw(error)
                }
            }
        }
    }
    
    /// Disconnects from the CXOne service.
    public func disconnect() {
        socketService.disconnect()
    }
    
    /// Sets the auth code from an OAuth provider in order to authorize the customer with authentication code. This code must be provided before `connectChat` if the channel is configured to use OAuth.
    /// - Parameter authCode: The authorization code from an OAuth provider. NOTE: This is not an access token. This is the authorization code that one would use to obtain an access token.
    public func setAuthCode(authCode: String) {
        authorizationCode = authCode
    }
    
    
    /// Sets the code verifier to be used for OAuth if the OAuth provider uses PKCE. This must be passed so that CXOne
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
        customer?.displayName = "\(firstName) \(lastName)"
    }
    
    /// Pings the CXOne chat server to ensure that a connection is established.
    public func ping() {
        socketService.ping()
    }
    
    
    // MARK: Exposed thread methods
    
    /// Loads all of the threads for the current customer. Should only be used on a channel configured for multiple threads.
    public func loadThreads() throws {
        guard let brandId = brandId else { throw CXOneChatError.invalidBrandId }
        guard let channelId = channelId else { throw CXOneChatError.invalidChannelId }
        guard let id = getIdentity(with: false) else { throw CXOneChatError.invalidCustomerId }
        let retreiveThread = EventFactory.shared.fetchThreadListEvent(brandId: brandId, channel: channelId, customer: id)
        guard let data = getDataFrom(retreiveThread) else {
            self.onError?(CXOneChatError.invalidData)
            throw CXOneChatError.invalidData
        }
        let messageString = getStringFromData(data)
        socketService.send(message: messageString)
    }
    
    /// Loads the a thread for the customer and gets messages.
    /// - Parameter threadId: The id of the thread to load. Optional, if omitted, it will attempt to load the customer's active thread. If there is no active thread, this returns an error.
    /// no active thread, this will return an error.
    public func loadThread(threadId: UUID? = nil) throws {
        guard let config = channelConfig else {
            throw CXOneChatError.missingChannelConfig
        }

        let eventType = config.isLiveChat ? EventType.recoverLivechat : EventType.recoverThread
        guard let brandId = brandId else { throw CXOneChatError.invalidBrandId }
        guard let channelId = channelId else { throw CXOneChatError.invalidChannelId  }

        guard let id = getIdentity(with: false) else { throw CXOneChatError.invalidCustomerId }
        let retrieveThread = EventFactory.shared.recoverLivechatThreadEvent(brandId: brandId, channelId: channelId, customer: id, eventType: eventType, threadId: threadId)
        guard let data = getDataFrom(retrieveThread) else { throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    /// Loads information about the thread. This will provide the most recent message for the thread.
    /// - Parameter threadId: The unique id of the thread to load.
    /// - Parameter idOnExternalPlatform: ``UUID`` unique id for the thread.
    public func loadThreadInfo(idOnExternalPlatform: UUID) throws {
        guard let threadId: String = threads.first(where: {
            $0.idOnExternalPlatform == idOnExternalPlatform
        })?.id else {  throw CXOneChatError.invalidThread }
        guard let brandId = brandId else {  throw CXOneChatError.invalidBrandId }
        guard let channelId = channelId else {  throw CXOneChatError.invalidChannelId }
        guard let id = getIdentity(with: false) else { throw CXOneChatError.invalidCustomerId }
        let retreiveThread = EventFactory.shared.loadThreadMetadataEvent(id: threadId, idOnExternalPlatform: idOnExternalPlatform, brandId: brandId, channel: channelId, customer: id)
        guard let data = getDataFrom(retreiveThread) else {  throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    /// Creates a new thread by sending an initial message to the thread.
    /// - Parameters:
    ///   - threadName: The name of the new thread.
    ///   - user: the user  information for the new thread bein created .
    public func createThread() throws {
        let id = UUID()
        guard let channelId = channelId else { throw CXOneChatError.invalidChannelId }
        threads.append(ThreadObject(id: "\(channelId)_\(id.uuidString)", idOnExternalPlatform: id, messages: [], threadAgent: Customer(senderId: "", displayName: "") , active: true))
        setCurrentThread(idOnExternalPlatform: id)
    }
    
    /// Updates the name for a thread.
    /// - Parameters:
    ///   - threadName: The new name for the thread.
    ///   - threadId: The unique id of the thread to update. Optional; if not provided, the current thread is assumed.
    public func updateThreadName(threadName: String, threadId: UUID? = nil) throws {
        // TODO: Implement
    }

    /// Archives a thread from the list of all threads.
    /// - parameter threadId: The id of the thread to archive.
    public func archiveThread(threadId: UUID) throws {
        guard let index = threads.firstIndex(where: {
            $0.idOnExternalPlatform == threadId
        }) else {  throw CXOneChatError.invalidThread }
        let threadIdString: String = threads[index].id
        self.archivedThreadId = threadIdString
        if threads[index].messages.count > 0 {            
            guard let brandId = brandId else {  throw CXOneChatError.invalidBrandId }
            guard let channelId = channelId else {  throw CXOneChatError.invalidChannelId }
            guard let id = getIdentity(with: false) else { throw CXOneChatError.invalidCustomerId }
            let thread = CustomFieldThreadCodable(id: threadIdString, idOnExternalPlatform: threadId.uuidString)
            let archiveThread = EventFactory.shared.archiveThreadEvent(brandId: brandId, channel: channelId, customer: id, thread: thread)
            guard let data = getDataFrom(archiveThread) else {  throw CXOneChatError.invalidData }
            let string = getStringFromData(data)
            socketService.send(message: string)
        }else {
            threadArchived()
        }
    }
    
    /// Reports that the most recent message of the specified thread was read by the customer.
    /// - Parameter idOnExternalPlatform: The unique id of the thread.
    public func markThreadAsRead(threadId: UUID) throws {
        guard let index = threads.firstIndex(where: {
            $0.idOnExternalPlatform == threadId
        }) else {  throw CXOneChatError.invalidThread }
        let threadIdString: String = threads[index].id
        guard let brandId = brandId else {  throw CXOneChatError.invalidBrandId }
        guard let channelId = channelId else {  throw CXOneChatError.invalidChannelId }
        guard let id = getIdentity(with: false) else { throw CXOneChatError.invalidCustomerId }
        let thread = CustomFieldThreadCodable(id: threadIdString, idOnExternalPlatform: threadId.uuidString)
        let messageReadByClient = EventFactory.shared.messageSeenByConsumer(brandId: brandId, channel: channelId, thread: thread, customer: id)
        guard let data = getDataFrom(messageReadByClient) else {  throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    /// Reports that the customer has started typing in the current thread.
    public func reportTypingStart() {
        guard let threadId = threadId else { return }
        guard let brandId = brandId else { return }
        guard let channelId = channelId else { return }
        guard let id = getIdentity(with: false) else { return }
        let typingState = EventFactory.shared.senderTypingStartedEvent(brandId: brandId, channel: channelId, threadId: threadId, customer: id)
        guard let encoded = getDataFrom(typingState) else {return}
        let string = getStringFromData(encoded)
        socketService.send(message: string)
    }
    
    /// Reports that the customer has stopped typing in the current thread.
    public func reportTypingEnd() {
        guard let threadId = threadId else { return }
        guard let brandId = brandId else { return }
        guard let channelId = channelId else { return }
        guard let id = getIdentity(with: false) else { return }
        let typingState = EventFactory.shared.senderTypingEndedEvent(brandId: brandId, channel: channelId, threadId: threadId, customer: id)
        guard let encoded = getDataFrom(typingState) else {return}
        let string = getStringFromData(encoded)
        socketService.send(message: string)
    }

    // MARK: Exposed message methods
    
    /// Loads more message in the current thread. By default, each load contains 20 additional messages in the thread.
    public func loadMoreMessages() throws {
        if hasMoreMessagesInThread == false {
            throw CXOneChatError.noMoreMessages
        }
        guard let user = getIdentity(with: false) else { throw CXOneChatError.invalidCustomerId }
        guard let threadId = threadId else {  throw CXOneChatError.invalidThread }
        guard let brandId = brandId else {  throw CXOneChatError.invalidBrandId }
        guard let channelId = channelId else {  throw CXOneChatError.invalidChannelId }
        guard let threadIdOnExternalPlatform = threadIdOnExternalPlatform else {  throw CXOneChatError.invalidThread }
        let oldestDate = threads.first(where: {
            $0.active == true
        })?.messages.first?.sentDate.iso8601withFractionalSeconds
        guard let oldestDate = oldestDate else { throw CXOneChatError.invalidOldestDate }
        let event = EventFactory.shared.loadMoreMessagesEvent(brandId: brandId, channel: channelId, threadId: threadId, threadIdOnExternalPlatform: threadIdOnExternalPlatform, scrollToken: scrollToken, user: user, oldestMessageDatetime: oldestDate)        
        guard let data = getDataFrom(event) else {  throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    /// Sends a message in the current thread through CXOne chat.
    public func sendMessage(message: String) throws {
        guard let customer = getIdentity(with: true) else { throw CXOneChatError.invalidCustomerId }
        guard let channelId = channelId else { throw CXOneChatError.invalidChannelId }
        guard let brandId = brandId else { throw CXOneChatError.invalidBrandId }
        guard let threadIdOnExternalPlatform = threadIdOnExternalPlatform else { throw CXOneChatError.invalidThread }
        let accessTokenPayload = AccessTokenPayload(token: socketService.accessToken?.token)
        let messageEvent = EventFactory.shared.sendMessageEvent(brandId: brandId, channel: channelId, thread: threadIdOnExternalPlatform, message: message, user: customer, accessToken: accessTokenPayload)
        guard let data = getDataFrom(messageEvent) else { throw CXOneChatError.invalidData}
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    /// Sends attachments in the current thread through CXOne chat.
    /// - Parameters:
    ///   - attachments: The images to send as attachments.
    public func sendAttachments(with attachments: [UIImage]) {
        uploadAttachments(images: attachments)
    }
    

    // MARK: Exposed contact methods
    
    /// Ends a contact for a customer.
    public func endContact() {
        // TODO: Implement
    }
    
    
    // MARK: Exposed custom field methods

    /// Sets custom fields to be saved on a contact.
    /// - Parameter customFields: The custom fields to be saved.
    public func setContactCustomFields(customFields: [CustomField]) throws {
        guard let contactId = contactId else {
            onError?(CXOneChatError.missingcontactId)
            throw CXOneChatError.missingcontactId
        }
        guard let threadId = threadId else { throw CXOneChatError.invalidThread }
        guard let threadIdOnExternalPlatform = threadIdOnExternalPlatform else { throw CXOneChatError.invalidThread }
        guard let brandId = brandId else {  throw CXOneChatError.invalidBrandId }
        guard let channelId = channelId else {  throw CXOneChatError.invalidChannelId }
        guard let id = getIdentity(with: false) else { throw CXOneChatError.invalidCustomerId }
        let customFieldPost = EventFactory.shared.setConsumerContactCustomFieldsEvent(brandId: brandId, channel: channelId, caseId: contactId, threadId: threadId, idOnExt: threadIdOnExternalPlatform, customer: id, customFields: customFields)
        
        guard let encoded = getDataFrom(customFieldPost) else {  throw CXOneChatError.invalidData }
        let string = getStringFromData(encoded)
        socketService.send(message: string)
    }
    
    /// Sets custom fields to be saved for a customer.
    /// - Parameter customFields: The custom fields to be saved.
    public func setCustomerCustomFields(customFields: [CustomField]) throws {
        guard let brandId = brandId else {  throw CXOneChatError.invalidBrandId }
        guard let channelId = channelId else {  throw CXOneChatError.invalidChannelId }
        guard let id = getIdentity(with: false) else { throw CXOneChatError.invalidCustomerId }
        let customFieldPost = EventFactory.shared.setCustomerCustomFieldsEvent(brandId: brandId,
                                                                               channelId: channelId,
                                                                               customerId: id,
                                                                               customFields: customFields)
        guard let data = getDataFrom(customFieldPost) else {  throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string)
    }
    
    // MARK: - Exposed Analitics Methods
    
    
    /// Reports to CXOne that a some page/screen in the app has been viewed by the visitor.
    /// - Parameters:
    ///   - title: The title or description of the page that was viewed.
    ///   - uri: A URI uniquely identifying the page. This can be any unique identifier.
    public func reportPageView(title: String, uri: String) {
        guard let brandId = brandId else { return }
        guard let visitorId = visitorId else { return }
        guard let destinationId = destinationId else { return }
        guard let channelId = channelId else { return }
        let payload = StoreVisitorEventPayload(eventType: .storeVisitorEvent,
                                      brand: Brand(id:brandId ),
                                      visitor: Visitor(id: visitorId.uuidString),
                                      destination: Destination(id: destinationId.uuidString),
                                      data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                        VisitorEvent(id: UUID().uuidString,
                                                     brandId: brandId,
                                                     type: .pageView,
                                                     visitorId: visitorId.uuidString,
                                                     destinationId: destinationId.uuidString,
                                                     channelId: channelId,
                                                     createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                     data: .pageViewData(PageViewData(url: uri, title: title )))])))
        let event = StoreVisitorEvent(action: "chatWindowsEvent", eventId: UUID().uuidString, payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    /// Reports to CXOne that the chat window/view has been opened by the visitor.
    public func reportChatWindowOpen() {
        guard let brandId = brandId else { return }
        guard let visitorId = visitorId else { return }
        guard let destinationId = destinationId else { return }
        guard let channelId = channelId else { return }
        let payload = StoreVisitorEventPayload(eventType: .storeVisitorEvent,
                                      brand: Brand(id: brandId),
                                      visitor: Visitor(id: visitorId.uuidString),
                                      destination: Destination(id: destinationId.uuidString),
                                      data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                        VisitorEvent(id: UUID().uuidString,
                                                     brandId: brandId,
                                                     type: .chatWindowOpened,
                                                     visitorId: visitorId.uuidString,
                                                     destinationId: destinationId.uuidString,
                                                     channelId: channelId,
                                                     createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                     data: nil)])))
        let event = StoreVisitorEvent(action: "chatWindowsEvent", eventId: UUID().uuidString, payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    
    /// Reports to CXOne that the visitor has visited the app.
    public func reportVisit() {
        guard let brandId = brandId else { return }
        guard let visitorId = visitorId else { return }
        guard let destinationId = destinationId else { return }
        guard let channelId = channelId else { return }
        let payload = StoreVisitorEventPayload(eventType: .storeVisitorEvent,
                                      brand: Brand(id: brandId),
                                      visitor: Visitor(id: visitorId.uuidString),
                                      destination: Destination(id: destinationId.uuidString),
                                      data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                        VisitorEvent(id: UUID().uuidString,
                                                     brandId: brandId,
                                                     type: .visitorVisit,
                                                     visitorId: visitorId.uuidString,
                                                     destinationId: destinationId.uuidString,
                                                     channelId: channelId,
                                                     createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                     data: nil)])))
        let event = StoreVisitorEvent(action: "chatWindowsEvent", eventId: UUID().uuidString, payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message, shouldCheck: false)
    }
    
    
    /// Reports to CXOne that a conversion has occurred.
    /// - Parameters:
    ///   - conversionType: The type of conversion. Can be any value.
    ///   - conversionValue: The value associated with the conversion (for example, unit amount). Can be any whole number.
    public func reportConversion(conversionType: String, conversionValue: Int ) {
        guard let brandId = brandId else { return }
        guard let visitorId = visitorId else { return }
        guard let destinationId = destinationId else { return }
        guard let channelId = channelId else { return }
        let payload = StoreVisitorEventPayload(eventType: .storeVisitorEvent,
                                      brand: Brand(id: brandId),
                                      visitor: Visitor(id: visitorId.uuidString),
                                      destination: Destination(id: destinationId.uuidString),
                                      data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                        VisitorEvent(id: UUID().uuidString,
                                                     brandId: brandId,
                                                     type: .conversion,
                                                     visitorId: visitorId.uuidString,
                                                     destinationId: destinationId.uuidString,
                                                     channelId: channelId,
                                                     createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                     data: .conversionData(ConversionData(conversionType: conversionType,
                                                                                          conversionValue: conversionValue,
                                                                                          conversionTimeWithMilliseconds: Date().iso8601withFractionalSeconds)))])))
        let event = StoreVisitorEvent(action: "chatWindowsEvent", eventId: UUID().uuidString, payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    
    /// Reports to CXOne that some event occurred with the visitor. This can be used to report any custom event that may not be covered by
    /// other existing methods.
    /// - Parameters:
    ///   - eventType: The type of event that occurred. Can be any string.
    ///   - data: Any data associated with the event.
    public func reportCustomVisitorEvent(eventType: String, data: Any) {
        guard let brandId = brandId else { return }
        guard let visitorId = visitorId else { return }
        guard let destinationId = destinationId else { return }
        guard let channelId = channelId else { return }
        let payload = StoreVisitorEventPayload(eventType: .storeVisitorEvent,
                                      brand: Brand(id: brandId),
                                      visitor: Visitor(id: visitorId.uuidString),
                                      destination: Destination(id: destinationId.uuidString),
                                      data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                        VisitorEvent(id: UUID().uuidString,
                                                     brandId: brandId,
                                                     type: .custom,
                                                     visitorId: visitorId.uuidString,
                                                     destinationId: destinationId.uuidString,
                                                     channelId: channelId,
                                                     createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                     data: nil)])))
        let event = StoreVisitorEvent(action: "chatWindowsEvent", eventId: UUID().uuidString, payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    /// Reports to CXOne that a proactive action was displayed to the visitor.
    /// - Parameter data: The proactive action that was displayed.
    public func reportProactiveActionDisplay(data: ProactiveActionEventData) {
        guard let brandId = brandId else { return }
        guard let visitorId = visitorId else { return }
        guard let destinationId = destinationId else { return }
        guard let channelId = channelId else { return }
        let payload = StoreVisitorEventPayload(eventType: .storeVisitorEvent,
                                      brand: Brand(id: brandId),
                                      visitor: Visitor(id: visitorId.uuidString),
                                      destination: Destination(id: destinationId.uuidString),
                                      data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                        VisitorEvent(id: UUID().uuidString,
                                                     brandId: brandId,
                                                     type: .proactiveActionDisplayed,
                                                     visitorId: visitorId.uuidString,
                                                     destinationId: destinationId.uuidString,
                                                     channelId: channelId,
                                                     createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                     data: .proActiveAction(data))])))
        let event = StoreVisitorEvent(action: "chatWindowsEvent", eventId: UUID().uuidString, payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    
    /// Reports to CXOne that a proactive action was clicked or acted upon by the visitor.
    /// - Parameter data: The proactive action that was clicked.
    public func reportProactiveActionClick(data: ProactiveActionEventData) {
        guard let brandId = brandId else { return }
        guard let visitorId = visitorId else { return }
        guard let destinationId = destinationId else { return }
        guard let channelId = channelId else { return }
        let payload = StoreVisitorEventPayload(eventType: .storeVisitorEvent,
                                      brand: Brand(id: brandId),
                                      visitor: Visitor(id: visitorId.uuidString),
                                      destination: Destination(id: destinationId.uuidString),
                                      data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                        VisitorEvent(id: UUID().uuidString,
                                                     brandId: brandId,
                                                     type: .proactiveActionClicked,
                                                     visitorId: visitorId.uuidString,
                                                     destinationId: destinationId.uuidString,
                                                     channelId: channelId,
                                                     createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                     data: .proActiveAction(data))])))
        let event = StoreVisitorEvent(action: "chatWindowsEvent", eventId: UUID().uuidString, payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    /// Reports to CXOne that a proactive action was successful and lead to a conversion.
    /// - Parameter data: The proactive action that was successful.
    public func reportProactiveActionSuccess(data: ProactiveActionEventData) {
        guard let brandId = brandId else { return }
        guard let visitorId = visitorId else { return }
        guard let destinationId = destinationId else { return }
        guard let channelId = channelId else { return }
        let payload = StoreVisitorEventPayload(eventType: .storeVisitorEvent,
                                      brand: Brand(id: brandId),
                                      visitor: Visitor(id: visitorId.uuidString),
                                      destination: Destination(id: destinationId.uuidString),
                                      data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                        VisitorEvent(id: UUID().uuidString,
                                                     brandId: brandId,
                                                     type: .proactiveActionSuccess,
                                                     visitorId: visitorId.uuidString,
                                                     destinationId: destinationId.uuidString,
                                                     channelId: channelId,
                                                     createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                     data: .proActiveAction(data))])))
        let event = StoreVisitorEvent(action: "chatWindowsEvent", eventId: UUID().uuidString, payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    /// Reports to CXOne that a proactive action failed to lead to a conversion.
    /// - Parameter data: The proactive action that failed.
    public func reportProactiveActionFail(data: ProactiveActionEventData) {
        guard let brandId = brandId else { return }
        guard let visitorId = visitorId else { return }
        guard let destinationId = destinationId else { return }
        guard let channelId = channelId else { return }
        let payload = StoreVisitorEventPayload(eventType: .storeVisitorEvent,
                                      brand: Brand(id: brandId),
                                      visitor: Visitor(id: visitorId.uuidString),
                                      destination: Destination(id: destinationId.uuidString),
                                      data: .visitorEvent(VisitorsEvents(visitorEvents: [
                                        VisitorEvent(id: UUID().uuidString,
                                                     brandId: brandId,
                                                     type: .proactiveActionFailed,
                                                     visitorId: visitorId.uuidString,
                                                     destinationId: destinationId.uuidString,
                                                     channelId: channelId,
                                                     createdAtWithMilliseconds: Date().iso8601withFractionalSeconds,
                                                     data: .proActiveAction(data))])))
        let event = StoreVisitorEvent(action: "chatWindowsEvent", eventId: UUID().uuidString, payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    
    /// Manually executes a trigger that was defined in CXOne. This can be used to test that proactive actions are displaying.
    /// - Parameter triggerId: The id of the trigger to manually execute.
    public func executeTrigger(triggerId: String) {
        guard let brandId = brandId else { return }
        guard let visitorId = visitorId else { return }
        guard let destinationId = destinationId else { return }
        guard let channelId = channelId else { return }
        guard let customer = customer else { return }
        let payload = ExecuteTriggerEventPayload(eventType: .executeTrigger,
                                        brand: Brand(id: brandId),
                                        channel: Channel(id: channelId),
                                                 consumerIdentity: CustomerIdentity(idOnExternalPlatform: customer.id),
                                        destination: Destination(id: destinationId.uuidString),
                                        visitor: Visitor(id: visitorId.uuidString),
                                        data: TriggerData(trigger: Trigger(id: triggerId)))
        let event = ExecuteTriggerEvent(action: "chatWindowsEvent", eventId: UUID().uuidString, payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    // MARK: Other methods
    
    /// Configures Amazon Pinpoint to use push notifications.
    ///
    /// - Parameter deviceToken: The unique token for the device to be registered to enable push notifications.
    private func launchPinpoint(deviceToken: Data) {
        let pinpointConfiguration = AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: launchOptions)
        pinpoint = AWSPinpoint(configuration: pinpointConfiguration)
        pinpoint?.notificationManager
            .interceptDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    /// Sets the launch options for the SDK.
    public func configurePinpoint(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.launchOptions = launchOptions
    }
    
    /// Registers a device to be used for push notifications.
    ///
    /// - Parameter deviceToken: The unique token for the device to be registered.
    public func registerDeviceToken(deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        self.token = token        
        launchPinpoint(deviceToken: deviceToken)
        if (socketService.socket != nil) {
            setVisitor()
        }
    }
    
    internal func setVisitor() {
        guard let brandId = brandId else { return }
        guard let visitorId = visitorId else { return }
        guard let destinationId = destinationId else { return }
        let customer = customer != nil ? CustomerIdentity(idOnExternalPlatform: customer!.id) : nil
        let payload =  StoreVisitorEventPayload(eventType: .storeVisitor,
                                       brand: Brand(id: brandId),
                                       visitor: Visitor(id: visitorId.uuidString),
                                       destination: Destination(id: destinationId.uuidString),
                                       data: .storeVisitorPayload(
                                        StoreVisitorPayload(customerIdentity: customer,
                                                            browserFingerprint:
                                                                BrowserFingerprint(browser: "",
                                                                                   browserVersion: "",
                                                                                   country: "",
                                                                                   ip: "",
                                                                                   language: "",
                                                                                   location: "",
                                                                                   deviceToken: self.token ?? ""),
                                                            journey: nil,
                                                            customVariables: nil)))
        let event = StoreVisitorEvent(action: "chatWindowEvent", eventId: UUID().uuidString, payload: payload)
        guard let data = getDataFrom(event) else {return}
        let message = getStringFromData(data)
        socketService.send(message: message, shouldCheck: false)
    }
    
    /// get channel configuration
    public func getChannelConfiguration() -> ChannelConfiguration? {
        return channelConfig
    }
    
    /// Get the current active thread
    ///
    /// - Returns: the idOnExternalPlatform of the current active thread
    public func getCurrentThread() -> ThreadObject? {
        return threads.first(where: {
            $0.active == true
        })
    }
    
    /// set the active thread id
    ///
    ///  - Parameters  threadId:  the id of the active current thread  id on External Platform UUID type.
    ///  use this function to save the current thread id and track in case needed.
    public func setCurrentThread(idOnExternalPlatform: UUID) {
        for i in 0..<threads.count {
            if threads[i].idOnExternalPlatform == idOnExternalPlatform {
                threads[i].active = true
            }else {
                threads[i].active = false
            }
        }
    }

    
    /// After calling the  ``archiveThread(threadId:)``   function and get notified the succes answer fromthe delegate ``archivedThread()``  call this method  to delete the thread from the threads list and then remove the cell from tableView.
    ///
    /// - Parameter index:  the index of the archivedThread to remove.
    ///
    ///  this fucntion check for  ``archivedThreadId``to check is valid delte operation, is not a valid id no deltation is made, if the thread id is valid the id is set to empty string
    public func delete(at index: Int) {
        if archivedThreadId == threads[index].id {
            threads.remove(at: index)
            archivedThreadId = ""
        }
    }

    // MARK: - Socket Authorization
    /// Authorizes a new customer to communicate through the WebSocket.
    func authorizeCustomer() throws {
        if customer == nil {
            self.customer = Customer(senderId: UUID().uuidString, displayName: "")
        }
        guard let customer = getIdentity(with: false) else { throw CXOneChatError.invalidCustomerId }
        guard let brandId = brandId else {  throw CXOneChatError.invalidBrandId }
        guard let channelId = channelId else {  throw CXOneChatError.invalidChannelId }
        let userToConnect = EventFactory.shared.authorizeConsumerEvent(brandId: brandId, channel: channelId, authCode: authorizationCode, user: customer, codeVerifier: codeVerifier)
        guard let data = getDataFrom(userToConnect) else {  throw CXOneChatError.invalidData }
        let string = getStringFromData(data)
        socketService.send(message: string,shouldCheck: false)
    }
    
    /// Reconnects a returning customer to communicate through the WebSocket.
    func reconnectCustomer() throws {
        guard let customer = getIdentity(with: false) else { throw CXOneChatError.invalidCustomerId }
        guard let brandId = brandId else {  throw CXOneChatError.invalidBrandId }
        guard let channelId = channelId else { throw CXOneChatError.invalidChannelId }
        guard let visitorId = visitorId else { throw CXOneChatError.invalidVisitor }
        let event = EventFactory.shared.reconnectConsumerEvent(brandId: brandId, channel: channelId, user: customer, visitor: visitorId.uuidString, token: socketService.accessToken?.token)
        guard let data = getDataFrom(event) else { throw CXOneChatError.invalidData }
        let message = getStringFromData(data)
        socketService.send(message: message)
    }
    
    //MARK: - NetworkRequests
    /// Uploads attachments to the channel.
    /// - Parameters:
    ///   - images: The images to upload to the server.
    private func uploadAttachments(images: [UIImage]) {
        var index: Int = 0
        var attachments = [Attachment]()
        guard let channel = channelId else {return}
        for image in images {
            let imageData = image.jpegData(compressionQuality: 0.7)
            if let strBase64 = imageData?.base64EncodedString() {
                let url = URL(string: "\(environment!.chatURL)/1.0/brand/\(brandId!)/channel/\(channel)/attachment")!
                var request = URLRequest(url: url)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                let body: [String: String] = [
                    "content": strBase64,
                    "fileName": "example.png",
                    "mimeType": "image/png"
                ]
                request.httpBody = try! JSONEncoder().encode(body)
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, let response = response as? HTTPURLResponse,  error == nil else { return }
                    guard (200 ... 299) ~= response.statusCode else { return }
                    let decoded: ImageUploadSuccess? = self.decodeData(data)
                    guard let decoded = decoded else { return }
                    attachments.append(Attachment(url: decoded.fileUrl, friendlyName: UUID().uuidString + ".png"))
                    index += 1
                    if index >= images.count {
                        do {
                            guard let message = try self.createMessageEventWithEmptyStringToUploadAttachment(attachments) else {return}
                            self.didUploadAttachments(message )
                        }catch {
                            self.didReceiveError(error)
                        }                        
                    }
                }
                task.resume()
            } else {
                self.imageDidUpload("", false)
            }
        }
    }
    /// Loads the configuration values for the channel.
    private func loadChannelConfiguration() {
        guard let brandId = brandId else { return }
        guard let channelId = channelId else { return }
        var request = URLRequest(url: URL(string: "\(environment!.chatURL)/1.0/brand/\(brandId)/channel/\(channelId)")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data else { return }
            do {
                let config = try JSONDecoder().decode(ChannelConfiguration.self, from: data)
                self.channelConfig = config
                self.configurationLoaded(config: config)
            } catch {
                print(error)
                self.didReceiveError(error)
            }
        }
        task.resume()
    }
    
    /// Connects to the WebSocket using the SocketService.
    internal func connectToSocket() {
        let brandItem = URLQueryItem(name: "brand", value: brandId?.description)
        let channelItem = URLQueryItem(name: "channelId", value: channelId)
        let customerIdItem = URLQueryItem(name: "customerId", value: customer?.senderId)
        let vQItem = URLQueryItem(name: "v", value: "4.74")
        let eioQItem = URLQueryItem(name: "EIO", value: "3")
        let transportQItem = URLQueryItem(name: "transport", value: "polling")
        let tQItem = URLQueryItem(name: "t", value: "NlrXzTa")
        let socketEndpoint = SocketEndpoint(environment: environment!, queryItems: [brandItem,channelItem,customerIdItem,vQItem,eioQItem,transportQItem,tQItem], method: .get)
        let request = try? socketEndpoint.urlRequest()
        guard let request = request else { return }
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

    private func createMessageEventWithEmptyStringToUploadAttachment(_ attachments: [Attachment]) throws -> Event?{
        //guard let user = customer else { throw CXOneChatError.invalidCustomerId }
        guard let consumer = getIdentity(with: true) else { throw CXOneChatError.invalidCustomerId }
        guard let brand = brandId else { throw CXOneChatError.invalidBrandId }
        guard let channelId = channelId else { throw CXOneChatError.invalidChannelId }
        
        let thread = getCurrentThread()
        guard let thread = thread else { throw CXOneChatError.invalidThread }
        let messageEvent = EventFactory.shared.sendMessageEvent(brandId: brand, channel: channelId, thread: thread.idOnExternalPlatform , message: "",  user:  consumer, attachments: attachments,accessToken: AccessTokenPayload(token: socketService.accessToken?.token))
        return messageEvent
    }
    
    #if DEBUG
    public func forceRefreshToken() {
        refreshToken()
    }
    #endif
    
    internal func getIdentity(with name: Bool) -> CustomerIdentity? {
        var identity: CustomerIdentity
        guard let customer = customer else {return nil}
        if !name {
            identity = CustomerIdentity(idOnExternalPlatform: customer.id)
        } else {
            identity = CustomerIdentity(idOnExternalPlatform: customer.id, firstName: customer.firstName, lastName: customer.familyName)
        }
        return identity
    }
}
