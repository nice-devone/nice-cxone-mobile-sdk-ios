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

/// Event received when a customer is successfully authorized.
struct CustomerAuthorizedEventDTO: Equatable {
    /// The unique identifier of the event.
    let eventId: UUID

    /// Type of event
    let eventType: EventType?

    /// The postback for the customer authorized event.
    let postback: CustomerAuthorizedEventPostbackDTO
}

// MARK: - ReceivedEvent

extension CustomerAuthorizedEventDTO: ReceivedEvent {
    
    static let eventType: EventType? = .customerAuthorized

    var postbackEventType: EventType? { postback.eventType }
}

// MARK: - Decoder

extension CustomerAuthorizedEventDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case eventId
        case eventType
        case postback
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let postback = try container.decode(CustomerAuthorizedEventPostbackDTO.self, forKey: .postback)
        self.eventId = try container.decode(UUID.self, forKey: .eventId)
        // Use eventtype from postback if not available at top level
        self.eventType = try container.decodeIfPresent(EventType.self, forKey: .eventType) ?? postback.eventType
        self.postback = postback
    }
}
