//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Foundation

// ContactHandlerChanged

/// Event response that the party responsible for handling the contact has changed.
struct ContactHandlerChangedEventDTO: Equatable, Sendable {

    // MARK: - Properties

    let eventId: String
    let eventType: EventType?
    let createdAt: Date
    /// The data about the contact whose handler changed.
    let data: ContactHandlerChangedDataDTO
}

// MARK: - ReceivedEvent

extension ContactHandlerChangedEventDTO: ReceivedEvent {

    static let associatedEventType: EventType? = .contactHandlerChanged

    var postbackEventType: EventType? { nil }
}

// MARK: - Decodable

extension ContactHandlerChangedEventDTO: Decodable {

    // The payload also carries an `eventObject` of `"Contact"`, which `EventObjectType` does not model.
    // It is deliberately not decoded here - doing so would throw and silently drop the whole event.
    enum CodingKeys: CodingKey {
        case eventId
        case eventType
        case createdAt
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.eventId = try container.decode(String.self, forKey: .eventId)
        self.eventType = try container.decode(EventType.self, forKey: .eventType)
        self.createdAt = try container.decodeISODate(forKey: .createdAt)
        self.data = try container.decode(ContactHandlerChangedDataDTO.self, forKey: .data)
    }
}
