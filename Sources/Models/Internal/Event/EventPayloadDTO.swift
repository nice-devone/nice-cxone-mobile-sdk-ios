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

/// The details about the event to be sent.
struct EventPayloadDTO {
    
    // MARK: - Properties
    
    /// The brand for which the event applies.
    let brand: BrandDTO
    
    /// The channel for which the event applies.
    let channel: ChannelIdentifierDTO
    
    /// The identity of the customer that is sending the event.
    let customerIdentity: CustomerIdentityDTO
    
    /// The type of event to be sent.
    let eventType: EventType
    
    /// The visitor to reconnect. Only used for the ReconnectCustomer event.
    let visitorId: LowerCaseUUID?

    /// The data to be sent for the event.
    let data: EventDataType?
    
    // MARK: - Init
    
    init(brandId: Int, channelId: String, customerIdentity: CustomerIdentityDTO, eventType: EventType, data: EventDataType?, visitorId: LowerCaseUUID?) {
        self.brand = BrandDTO(id: brandId)
        self.channel = ChannelIdentifierDTO(id: channelId)
        self.customerIdentity = customerIdentity
        self.eventType = eventType
        self.data = data
        self.visitorId = visitorId
    }
}

// MARK: - Encodable

extension EventPayloadDTO: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case brand
        case channel
        case consumerIdentity
        case customerIdentity
        case eventType
        case visitor
        case data
    }
    
    enum VisitorKeys: CodingKey {
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(brand, forKey: .brand)
        try container.encode(channel, forKey: .channel)
        try container.encode(customerIdentity, forKey: codingKey(for: eventType))
        try container.encode(eventType, forKey: .eventType)
        try container.encodeIfPresent(data, forKey: .data)
        
        if let visitorId = visitorId {
            var visitorContainer = container.nestedContainer(keyedBy: VisitorKeys.self, forKey: .visitor)
            
            try visitorContainer.encodeIfPresent(visitorId, forKey: .id)
        }
    }
    
    private func codingKey(for eventType: EventType) -> CodingKeys {
        switch eventType {
        case .sendMessage,
                .recoverThread,
                .recoverLiveChat,
                .loadMoreMessages,
                .setContactCustomFields,
                .setCustomerCustomFields,
                .senderTypingEnded,
                .senderTypingStarted,
                .messageSeenByCustomer,
                .authorizeCustomer,
                .fetchThreadList,
                .loadThreadMetadata,
                .updateThread,
                .archiveThread:
            return .customerIdentity
        default:
            return .consumerIdentity
        }
    }
}
