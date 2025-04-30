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

/// The types of data that can be sent on an event.
enum EventDataType {
    
    // MARK: - Thread/Case
    
    case archiveThreadData(ThreadEventDataDTO)
    
    case loadThreadData(ThreadEventDataDTO)
    
    case updateThreadData(ThreadEventDataDTO)
    
    case setContactCustomFieldsData(SetContactCustomFieldsEventDataDTO)
    
    // MARK: - Customer
    
    case setCustomerCustomFieldData(CustomerCustomFieldsDataDTO)
    
    case customerTypingData(CustomerTypingEventDataDTO)
    
    case authorizeCustomerData(AuthorizeCustomerEventDataDTO)
    
    case reconnectCustomerData(ReconnectCustomerEventDataDTO)
    
    case refreshTokenPayload(RefreshTokenPayloadDataDTO)
    
    // MARK: - Message
    
    case sendMessageData(SendMessageEventDataDTO)
    
    case messageSeenByCustomer(ThreadEventDataDTO)
    
    case loadMoreMessageData(LoadMoreMessagesEventDataDTO)
    
    case sendOutboundMessageData(SendOutboundMessageEventDataDTO)
    
    // MARK: - LiveChat
    
    case endContact(EndContactEventDataDTO)
    
    case loadLiveChatData(ThreadEventDataDTO)
}

// MARK: - Encodable

extension EventDataType: Encodable {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .sendMessageData(let message):
            try container.encode(message)
        case .archiveThreadData(let thread):
            try container.encode(thread)
        case .loadThreadData(let thread):
            try container.encode(thread)
        case .loadMoreMessageData(let moreMessageData):
            try container.encode(moreMessageData)
        case .setContactCustomFieldsData(let data):
            try container.encode(data)
        case .setCustomerCustomFieldData(let data):
            try container.encode(data)
        case .customerTypingData(let data):
            try container.encode(data)
        case .authorizeCustomerData(let data):
            try container.encode(data)
        case .reconnectCustomerData(let data):
            try container.encode(data)
        case .updateThreadData(let data):
            try container.encode(data)
        case .refreshTokenPayload(let data):
            try container.encode(data)
        case .sendOutboundMessageData(let data):
            try container.encode(data)
        case .messageSeenByCustomer(let data):
            try container.encode(data)
        case .endContact(let data):
            try container.encode(data)
        case .loadLiveChatData(let data):
            try container.encode(data)
        }
    }
}
