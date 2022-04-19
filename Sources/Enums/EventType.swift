//
//  File.swift
//  
//
//  Created by Tyler Hendrickson on 3/5/22.
//

import Foundation


/// The different types of WebSocket events.
public enum EventType: String, Codable {
    case authorizeCustomer = "AuthorizeConsumer"
    case customerAuthorized = "ConsumerAuthorized"
    case reconnectConsumer = "ReconnectConsumer"
    case consumerReconnected = "ConsumerReconnected"
    
    case refreshToken = "RefreshToken"
    case tokenRefreshed = "TokenRefreshed"

    
    // MARK: Message
    case sendMessage = "SendMessage"
    case messageCreated = "MessageCreated"
    
    case sendOfflineMessage = "SendOfflineMessage"
    case offlineMessageSent = "OfflineMessageSent"
    
    case sendOutbound = "SendOutbound"

    case loadMoreMessages = "LoadMoreMessages"
    case moreMessagesLoaded = "MoreMessagesLoaded"
    
    case messageSeenByAgent = "MessageSeenByUser"
    
    // TODO: Figure out where/if we're using this
    case messageReadChanged = "MessageReadChanged"
    
    // MARK: Thread
    case recoverThread = "RecoverThread"
    case threadRecovered = "ThreadRecovered"
    
    case recoverLivechat = "RecoverLivechat"
    case livechatRecovered = "LivechatRecovered"

    case fetchThreadList = "FetchThreadList"
    case threadListFetched = "ThreadListFetched"
    
    case archiveThread = "ArchiveThread"
    case threadArchived = "ThreadArchived"
    
    case loadThreadMetadata = "LoadThreadMetadata"
    case threadMetadataLoaded = "ThreadMetadataLoaded"
    
    case updateThread = "UpdateThread"
    case threadUpdated = "ThreadUpdated"
    
    case messageSeenByCustomer = "MessageSeenByConsumer"
    
    // MARK: Contact
    case contactCreated = "CaseCreated"
    case contactToRoutingQueueAssignmentChanged = "CaseToRoutingQueueAssignmentChanged"
    case contactStatusChanged = "CaseStatusChanged"
    case contactRecipientsChanged = "ContactRecipientsChanged"
    case contactInboxAssigneeChanged = "CaseInboxAssigneeChanged"
    case endCustomerContact = "EndConsumerContact"

    // MARK: Custom fields
    case setCustomerContactCustomFields = "SetConsumerContactCustomFields"
    case setCustomerCustomFields = "SetConsumerCustomFields"

    // MARK: Typing
    case senderTypingStarted = "SenderTypingStarted"
    case senderTypingEnded = "SenderTypingEnded"
    
    // MARK: Other
    case sendTranscript = "SendTranscript"
    case transcriptSent = "TranscriptSent"
    
    case sendPageViews = "SendPageViews"
    case executeTrigger = "ExecuteTrigger"
    
    // MARK: StoreVisitors    
    case storeVisitor = "StoreVisitor"
    case storeVisitorEvent = "StoreVisitorEvents"
}
