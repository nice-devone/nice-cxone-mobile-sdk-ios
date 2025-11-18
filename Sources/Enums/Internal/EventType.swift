//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
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

import Foundation

/// The different types of WebSocket events.
enum EventType: String, CaseIterable {
    
    // MARK: - Connection
    
    /// An event sent to refresh an access token.
    case refreshToken = "RefreshToken"
    
    /// An event received when the token has been successfully refreshed.
    case tokenRefreshed = "TokenRefreshed"
    
    // MARK: - Customer
    
    /// An event sent to authorize a customer.
    case authorizeCustomer = "AuthorizeCustomer"
    
    /// An event received when the customer has been successfully authorized.
    case customerAuthorized = "ConsumerAuthorized"
    
    /// An event sent to reconnect a returning customer.
    case reconnectCustomer = "ReconnectCustomer"
    
    /// An event received when the customer has been successfully reconnected.
    case customerReconnected = "ConsumerReconnected"
    
    // MARK: Message
    
    /// An event to send a message in a chat thread.
    case sendMessage = "SendMessage"
    
    /// POSTBACK interaction (user selected an action).
    case postback = "Postback"
    
    /// An event received when a message has been received in a chat.
    case messageCreated = "MessageCreated"

    /// An event to send to load more messages in a chat thread.
    case loadMoreMessages = "LoadMoreMessages"
    
    /// An event received when more messages have been received for the chat thread.
    case moreMessagesLoaded = "MoreMessagesLoaded"
    
    /// An event to send to mark a chat message as seen by the customer.
    case messageSeenByCustomer = "MessageSeenByCustomer"
    
    /// An event received when a messages has been seen by a customer
    case messageSeenChanged = "MessageSeenChanged"
    
    /// An event received when a read status of a message has been changed.
    case messageReadChanged = "MessageReadChanged"
    
    /// An event to send message from sdk to customer as sent from and agent.
    case sendOutbound = "SendOutbound"
    
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
    
    /// An event received when case successfully created.
    case caseCreated = "CaseCreated"
    
    /// An event received when case status has been changed.
    case caseStatusChanged = "CaseStatusChanged"
    
    /// An event to send to set the position of the customer in the queue.
    case setPositionInQueue = "SetPositionInQueue"
    
    /// An event to send when consumer ends conversation
    case endContact = "EndContact"

    case liveChatRecovered = "LivechatRecovered"
    
    case recoverLiveChat = "RecoverLivechat"
    
    // MARK: Contact
    
    /// An event received when the assigned agent changes for a contact.
    case contactInboxAssigneeChanged = "CaseInboxAssigneeChanged"
    
    // MARK: Custom fields
    
    /// An event to send to set custom field values for a contact (thread).
    case setContactCustomFields = "SetContactCustomFields"
    
    /// An event to send to set custom field values for a customer.
    case setCustomerCustomFields = "SetCustomerCustomFields"
    
    // MARK: Typing
    
    /// An event received when an agent or customer starts typing in a chat thread.
    case senderTypingStarted = "SenderTypingStarted"
    
    /// An event received when an agent or customer stops typing in a chat thread.
    case senderTypingEnded = "SenderTypingEnded"
    
    // MARK: Proactive chat
    
    /// An event to send to execute an automation trigger manually.
    case executeTrigger = "ExecuteTrigger"
    
    /// An event received when a proactive action has been fired.
    case fireProactiveAction = "FireProactiveAction"
    
    // MARK: Visitor

    /// Events to send to store a visitor and associate it with a customer (and device token for push notifications).
    case storeVisitorEvents = "StoreVisitorEvents"
    
    /// A custom visitor event to send any additional data.
    case custom = "Custom"

    // MARK: - S3
    
    case eventInS3 = "EventInS3"

    // MARK: - Default

    /// An unknown and unsupported event.
    case unknown
}

// MARK: - Codable

extension EventType: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        if let eventType = EventType(rawValue: rawValue) {
            self = eventType
        } else {
            LogManager.warning("Unable to decode eventType `.\(rawValue)`")
            
            self = .unknown
        }
    }
}
