import Foundation

/// The different types of WebSocket events.
enum EventType: Comparable {
    
    /// An event sent to authorize a customer.
    case authorizeCustomer
    
    /// An event received when the customer has been successfully authorized.
    case customerAuthorized
    
    /// An event sent to reconnect a returning customer.
    case reconnectCustomer
    
    /// An event received when the customer has been successfully reconnected.
    case customerReconnected
    
    /// An event sent to refresh an access token.
    case refreshToken
    
    /// An event received when the token has been successfully refreshed.
    case tokenRefreshed

    /// An event received when case successfully created.
    case caseCreated
    
    // MARK: Message
    
    /// An event to send a message in a chat thread.
    case sendMessage
    
    /// An event received when a message has been received in a chat.
    case messageCreated

    /// An event to send to load more messages in a chat thread.
    case loadMoreMessages
    
    /// An event received when more messages have been received for the chat thread.
    case moreMessagesLoaded
    
    /// An event to send to mark a chat message as seen by the customer.
    case messageSeenByCustomer
    
    /// An event received when a message has been seen by an agent.
    case messageSeenByAgent
    
    /// An event received when a read status of a message has been changed.
    case messageReadChanged
    
    // MARK: Thread
    
    /// An event to send to recover an existing chat thread in a single-thread channel.
    case recoverThread
    
    /// An event received when a chat thread has been recovered.
    case threadRecovered

    /// An event to send to fetch the list of chat threads for the customer in a multi-thread channel.
    case fetchThreadList
    
    /// An event received when a list of chat threads has been fetched.
    case threadListFetched
    
    /// An event to send to archive a chat thread in a multi-thread channel.
    case archiveThread
    
    /// An event received when a chat thread has been archived.
    case threadArchived
    
    /// An event to send to load metadata about a chat thread. This includes the most recent message in the thread.
    case loadThreadMetadata
    
    /// An event received when metadata for a chat thread has been loaded.
    case threadMetadataLoaded
    
    /// An event to sent to update the thread name and other info.
    case updateThread
    
    /// An event received when the thread has been updated.
    case threadUpdated
    
    // MARK: Contact
    
    /// An event received when the assigned agent changes for a contact.
    case contactInboxAssigneeChanged
    
    // MARK: Custom fields
    
    /// An event to send to set custom field values for a contact (thread).
    case setContactCustomFields
    
    /// An event to send to set custom field values for a customer.
    case setCustomerCustomFields
    
    // MARK: Typing
    
    /// An event received when an agent or customer starts typing in a chat thread.
    case senderTypingStarted
    
    /// An event received when an agent or customer stops typing in a chat thread.
    case senderTypingEnded
    
    // MARK: Proactive chat
    
    /// An event to send to execute an automation trigger manually.
    case executeTrigger
    
    // MARK: Visitor

    /// An event to send to store a visitor and associate it with a customer (and device token for push notifications).
    case storeVisitor

    /// Events to send to store a visitor and associate it with a customer (and device token for push notifications).
    case storeVisitorEvents
    
    /// An event received when a proactive action has been fired.
    case fireProactiveAction
    
    /// An event to send message from sdk to customer as sent from and agent.
    case sendOutbound
    
    /// A custom visitor event to send any additional data.
    case custom
    
    // MARK: - Default
    
    /// An unknown and unsupported event.
    case unknown(String)
}

// MARK: - Codable

extension EventType: Codable {
    
    enum CodingKeys: String, CodingKey {
        case authorizeCustomer = "AuthorizeCustomer"
        case customerAuthorized = "ConsumerAuthorized"
        case reconnectCustomer = "ReconnectCustomer"
        case customerReconnected = "ConsumerReconnected"
        case refreshToken = "RefreshToken"
        case tokenRefreshed = "TokenRefreshed"
        case caseCreated = "CaseCreated"
        case sendMessage = "SendMessage"
        case messageCreated = "MessageCreated"
        case loadMoreMessages = "LoadMoreMessages"
        case moreMessagesLoaded = "MoreMessagesLoaded"
        case messageSeenByCustomer = "MessageSeenByCustomer"
        case messageSeenByAgent = "MessageSeenByUser"
        case messageReadChanged = "MessageReadChanged"
        case recoverThread = "RecoverThread"
        case threadRecovered = "ThreadRecovered"
        case fetchThreadList = "FetchThreadList"
        case threadListFetched = "ThreadListFetched"
        case archiveThread = "ArchiveThread"
        case threadArchived = "ThreadArchived"
        case loadThreadMetadata = "LoadThreadMetadata"
        case threadMetadataLoaded = "ThreadMetadataLoaded"
        case updateThread = "UpdateThread"
        case threadUpdated = "ThreadUpdated"
        case contactInboxAssigneeChanged = "CaseInboxAssigneeChanged"
        case setContactCustomFields = "SetContactCustomFields"
        case setCustomerCustomFields = "SetCustomerCustomFields"
        case senderTypingStarted = "SenderTypingStarted"
        case senderTypingEnded = "SenderTypingEnded"
        case executeTrigger = "ExecuteTrigger"
        case storeVisitor = "StoreVisitor"
        case storeVisitorEvents = "StoreVisitorEvents"
        case fireProactiveAction = "FireProactiveAction"
        case sendOutbound = "SendOutbound"
        case custom = "Custom"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let key = try container.decode(String.self)
        
        switch key {
        case CodingKeys.authorizeCustomer.rawValue:             self = .authorizeCustomer
        case CodingKeys.customerAuthorized.rawValue:            self = .customerAuthorized
        case CodingKeys.reconnectCustomer.rawValue:             self = .reconnectCustomer
        case CodingKeys.customerReconnected.rawValue:           self = .customerReconnected
        case CodingKeys.refreshToken.rawValue:                  self = .refreshToken
        case CodingKeys.tokenRefreshed.rawValue:                self = .tokenRefreshed
        case CodingKeys.caseCreated.rawValue:                   self = .caseCreated
        case CodingKeys.sendMessage.rawValue:                   self = .sendMessage
        case CodingKeys.messageCreated.rawValue:                self = .messageCreated
        case CodingKeys.loadMoreMessages.rawValue:              self = .loadMoreMessages
        case CodingKeys.moreMessagesLoaded.rawValue:            self = .moreMessagesLoaded
        case CodingKeys.messageSeenByCustomer.rawValue:         self = .messageSeenByCustomer
        case CodingKeys.messageSeenByAgent.rawValue:            self = .messageSeenByAgent
        case CodingKeys.messageReadChanged.rawValue:            self = .messageReadChanged
        case CodingKeys.recoverThread.rawValue:                 self = .recoverThread
        case CodingKeys.threadRecovered.rawValue:               self = .threadRecovered
        case CodingKeys.fetchThreadList.rawValue:               self = .fetchThreadList
        case CodingKeys.threadListFetched.rawValue:             self = .threadListFetched
        case CodingKeys.archiveThread.rawValue:                 self = .archiveThread
        case CodingKeys.threadArchived.rawValue:                self = .threadArchived
        case CodingKeys.loadThreadMetadata.rawValue:            self = .loadThreadMetadata
        case CodingKeys.threadMetadataLoaded.rawValue:          self = .threadMetadataLoaded
        case CodingKeys.updateThread.rawValue:                  self = .updateThread
        case CodingKeys.threadUpdated.rawValue:                 self = .threadUpdated
        case CodingKeys.contactInboxAssigneeChanged.rawValue:   self = .contactInboxAssigneeChanged
        case CodingKeys.setContactCustomFields.rawValue:        self = .setContactCustomFields
        case CodingKeys.setCustomerCustomFields.rawValue:       self = .setCustomerCustomFields
        case CodingKeys.senderTypingStarted.rawValue:           self = .senderTypingStarted
        case CodingKeys.senderTypingEnded.rawValue:             self = .senderTypingEnded
        case CodingKeys.executeTrigger.rawValue:                self = .executeTrigger
        case CodingKeys.storeVisitor.rawValue:                  self = .storeVisitor
        case CodingKeys.storeVisitorEvents.rawValue:            self = .storeVisitorEvents
        case CodingKeys.fireProactiveAction.rawValue:           self = .fireProactiveAction
        case CodingKeys.sendOutbound.rawValue:                  self = .sendOutbound
        case CodingKeys.custom.rawValue:                        self = .custom
        default:                                                self = .unknown(key)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .authorizeCustomer:            try container.encode(CodingKeys.authorizeCustomer.rawValue)
        case .customerAuthorized:           try container.encode(CodingKeys.customerAuthorized.rawValue)
        case .reconnectCustomer:            try container.encode(CodingKeys.reconnectCustomer.rawValue)
        case .customerReconnected:          try container.encode(CodingKeys.customerReconnected.rawValue)
        case .refreshToken:                 try container.encode(CodingKeys.refreshToken.rawValue)
        case .tokenRefreshed:               try container.encode(CodingKeys.tokenRefreshed.rawValue)
        case .caseCreated:                  try container.encode(CodingKeys.caseCreated.rawValue)
        case .sendMessage:                  try container.encode(CodingKeys.sendMessage.rawValue)
        case .messageCreated:               try container.encode(CodingKeys.messageCreated.rawValue)
        case .loadMoreMessages:             try container.encode(CodingKeys.loadMoreMessages.rawValue)
        case .moreMessagesLoaded:           try container.encode(CodingKeys.moreMessagesLoaded.rawValue)
        case .messageSeenByCustomer:        try container.encode(CodingKeys.messageSeenByCustomer.rawValue)
        case .messageSeenByAgent:           try container.encode(CodingKeys.messageSeenByAgent.rawValue)
        case .messageReadChanged:           try container.encode(CodingKeys.messageReadChanged.rawValue)
        case .recoverThread:                try container.encode(CodingKeys.recoverThread.rawValue)
        case .threadRecovered:              try container.encode(CodingKeys.threadRecovered.rawValue)
        case .fetchThreadList:              try container.encode(CodingKeys.fetchThreadList.rawValue)
        case .threadListFetched:            try container.encode(CodingKeys.threadListFetched.rawValue)
        case .archiveThread:                try container.encode(CodingKeys.archiveThread.rawValue)
        case .threadArchived:               try container.encode(CodingKeys.threadArchived.rawValue)
        case .loadThreadMetadata:           try container.encode(CodingKeys.loadThreadMetadata.rawValue)
        case .threadMetadataLoaded:         try container.encode(CodingKeys.threadMetadataLoaded.rawValue)
        case .updateThread:                 try container.encode(CodingKeys.updateThread.rawValue)
        case .threadUpdated:                try container.encode(CodingKeys.threadUpdated.rawValue)
        case .contactInboxAssigneeChanged:  try container.encode(CodingKeys.contactInboxAssigneeChanged.rawValue)
        case .setContactCustomFields:       try container.encode(CodingKeys.setContactCustomFields.rawValue)
        case .setCustomerCustomFields:      try container.encode(CodingKeys.setCustomerCustomFields.rawValue)
        case .senderTypingStarted:          try container.encode(CodingKeys.senderTypingStarted.rawValue)
        case .senderTypingEnded:            try container.encode(CodingKeys.senderTypingEnded.rawValue)
        case .executeTrigger:               try container.encode(CodingKeys.executeTrigger.rawValue)
        case .storeVisitor:                 try container.encode(CodingKeys.storeVisitor.rawValue)
        case .storeVisitorEvents:           try container.encode(CodingKeys.storeVisitorEvents.rawValue)
        case .fireProactiveAction:          try container.encode(CodingKeys.fireProactiveAction.rawValue)
        case .sendOutbound:                 try container.encode(CodingKeys.sendOutbound.rawValue)
        case .custom:                       try container.encode(CodingKeys.custom.rawValue)
        case .unknown:
            return
        }
    }
}
