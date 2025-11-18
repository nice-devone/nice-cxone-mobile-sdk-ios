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

struct MessageSeenChangedDTO: Equatable {
    
    /// The unique identifier of the event.
    let eventId: UUID
    
    /// The type of the event.
    let eventType: EventType?
    
    let message: MessageDTO
    
    /// The timestamp of when the message was created.
    let createdAt: Date
}

// MARK: - ReceivedEvent

extension MessageSeenChangedDTO: ReceivedEvent {
    static let eventType: EventType? = .messageSeenChanged

    var postbackEventType: EventType? { nil }
}

// MARK: - Decodable

extension MessageSeenChangedDTO: Decodable {
  
    enum CodingKeys: CodingKey {
        case eventId
        case eventType
        case createdAt
        case data
    }
    
    enum DataKeys: CodingKey {
        case message
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eventId = try container.decode(UUID.self, forKey: .eventId)
        self.eventType = try container.decodeIfPresent(EventType.self, forKey: .eventType)
        self.createdAt = try container.decodeISODate(forKey: .createdAt)
        
        let dataContainer = try container.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
        self.message = try dataContainer.decode(MessageDTO.self, forKey: .message)
    }
}
