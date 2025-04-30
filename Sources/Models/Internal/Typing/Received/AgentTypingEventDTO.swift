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

// SenderTypingStarted

/// Event received when the agent begins typing or stops typing.
struct AgentTypingEventDTO: Equatable {

    // MARK: - Properties
    
    let eventId: UUID

    let eventObject: EventObjectType

    let eventType: EventType?

    let createdAt: Date

    let data: AgentTypingEventDataDTO

    var agentTyping: Bool {
        eventType == .senderTypingStarted
    }
}

// MARK: - ReceivedEvent

extension AgentTypingEventDTO: ReceivedEvent {
    static let eventType: EventType? = nil

    var postbackEventType: EventType? { nil }
}

// MARK: - Codable

extension AgentTypingEventDTO: Codable {

    enum CodingKeys: CodingKey {
        case eventId
        case eventObject
        case eventType
        case createdAt
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.eventId = try container.decode(UUID.self, forKey: .eventId)
        self.eventObject = try container.decode(EventObjectType.self, forKey: .eventObject)
        self.eventType = try container.decode(EventType.self, forKey: .eventType)
        self.createdAt = try container.decodeISODate(forKey: .createdAt)
        self.data = try container.decode(AgentTypingEventDataDTO.self, forKey: .data)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(eventId, forKey: .eventId)
        try container.encode(eventObject, forKey: .eventObject)
        try container.encode(eventType, forKey: .eventType)
        try container.encodeISODate(createdAt, forKey: .createdAt)
        try container.encode(data, forKey: .data)
    }
}
