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

/// The initial decoding of a message from the WebSocket.
struct GenericEventDTO: Equatable {
    
    // MARK: - Properties
    
    /// Event ID of this event (or original event we're responding to)
    let eventId: UUID
    /// The type of the event.
    let eventType: EventType?
    /// The postback of the event.
    let postback: GenericEventPostbackDTO?
}

// MARK: - ReceivedEvent

extension GenericEventDTO: ReceivedEvent {
    
    static let eventType: EventType? = nil

    var postbackEventType: EventType? { postback?.eventType }
}

// MARK: - Decodable

extension GenericEventDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case eventId
        case eventType
        case postback
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.eventId = try container.decodeUUID(forKey: .eventId)
        self.eventType = try container.decodeIfPresent(EventType.self, forKey: .eventType)
        self.postback = try container.decodeIfPresent(GenericEventPostbackDTO.self, forKey: .postback)
    }
}
