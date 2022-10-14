import Foundation

/// The different types of WebSocket events.
public enum EventType: String, Codable {
    
    /// An event sent to authorize a customer.
    case authorizeCustomer = "AuthorizeConsumer"
    
    /// An event received when the customer has been successfully authorized.
    case customerAuthorized = "ConsumerAuthorized"
    
    /// An event sent to reconnect a returning customer.
    case reconnectCustomer = "ReconnectConsumer"
    
    /// An event received when the customer has been successfully reconnected.
    case customerReconnected = "ConsumerReconnected"
    
    /// An event sent to refresh an access token.
    case refreshToken = "RefreshToken"
    
    /// An event received when the token has been successfully refreshed.
    case tokenRefreshed = "TokenRefreshed"

    // MARK: Message
    
    /// An event to send a message in a chat thread.
    case sendMessage = "SendMessage"
    
    /// An event received when a message has been received in a chat.
    case messageCreated = "MessageCreated"
    
//    case sendOutbound = "SendOutbound"

    /// An event to send to load more messages in a chat thread.
    case loadMoreMessages = "LoadMoreMessages"
    
    /// An event received when more messages have been received for the chat thread.
    case moreMessagesLoaded = "MoreMessagesLoaded"
    
    /// An event to send to mark a chat message as seen by the customer.
    case messageSeenByCustomer = "MessageSeenByConsumer"
    
    /// An event received when a message has been seen by an agent.
    case messageSeenByAgent = "MessageSeenByUser"
    
    /// An event received when a read status of a message has been changed.
    case messageReadChanged = "MessageReadChanged"
    
    // MARK: Thread
    /// An event to send to recover an existing chat thread in a single-thread channel.
    case recoverThread = "RecoverThread"
    
    /// An event received when a chat thread has been recovered.
    case threadRecovered = "ThreadRecovered"

    /// An event to send to fetch the list of chat threads for the customer in a multi-thread channel.
    case fetchThreadList = "FetchThreadList"
    
    /// An event received when a list of chat threads has been fetched.
    case threadListFetched = "ThreadListFetched"
    
    /// An event to send to archive a chat thread in a multi-thread channel.
    case archiveThread = "ArchiveThread"
    
    /// An event received when a chat thread has been archived.
    case threadArchived = "ThreadArchived"
    
    /// An event to send to load metadata about a chat thread. This includes the most recent message in the thread.
    case loadThreadMetadata = "LoadThreadMetadata"
    
    /// An event received when metadata for a chat thread has been loaded.
    case threadMetadataLoaded = "ThreadMetadataLoaded"
    
    /// An event to sent to update the thread name and other info.
    case updateThread = "UpdateThread"
    
    /// An event received when the thread has been updated.
    case threadUpdated = "ThreadUpdated"
    
    // MARK: Contact
    
    /// An event received when the assigned agent changes for a contact.
    case contactInboxAssigneeChanged = "CaseInboxAssigneeChanged"
    
    // MARK: Custom fields
    
    /// An event to send to set custom field values for a contact (thread).
    case setCustomerContactCustomFields = "SetConsumerContactCustomFields"
    
    /// An event to send to set custom field values for a customer.
    case setCustomerCustomFields = "SetConsumerCustomFields"

    // MARK: Typing
    /// An event received when an agent or customer starts typing in a chat thread.
    case senderTypingStarted = "SenderTypingStarted"
    
    /// An event received when an agent or customer stops typing in a chat thread.
    case senderTypingEnded = "SenderTypingEnded"
    
    // MARK: Proactive chat
    
    /// An event to send to execute an automation trigger manually.
    case executeTrigger = "ExecuteTrigger"
    
    // MARK: Visitor

    /// An event to send to store a visitor and associate it with a customer (and device token for push notifications).
    case storeVisitor = "StoreVisitor"

    case storeVisitorEvents = "StoreVisitorEvents"
    
    /// An event received when a proactive action has been fired.
    case fireProactiveAction = "FireProactiveAction"
    
    /// An event to send message from sdk to consumer as sent from and agent
    case sendOutbound = "SendOutbound"
}
