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

struct ServerError: LocalizedError {

    // MARK: - Properties

    let message: String

    let connectionId: UUID

    let requestId: UUID

    var errorDescription: String? { message }
}

// MARK: - Equatable

extension ServerError: Equatable {
    
    static func == (lhs: ServerError, rhs: ServerError) -> Bool {
        lhs.message == rhs.message
            && lhs.connectionId == rhs.connectionId
            && lhs.requestId == rhs.requestId
    }
}

// MARK: - ReceivedEvent

extension ServerError: ReceivedEvent {
    static let eventType: EventType? = nil

    /// - Warning: The value is initialized locally so it does not refer to the server one
    var eventId: UUID { UUID.provide() }
    var eventType: EventType? { nil }
    var postbackEventType: EventType? { nil }
}

// MARK: - Codable

extension ServerError: Codable {
    
    enum CodingKeys: CodingKey {
        case eventId
        case message
        case connectionId
        case requestId
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.message = try container.decode(String.self, forKey: .message)
        self.connectionId = try container.decode(UUID.self, forKey: .connectionId)
        self.requestId = try container.decode(UUID.self, forKey: .requestId)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.eventId, forKey: .eventId)
        try container.encode(self.message, forKey: .message)
        try container.encode(self.connectionId, forKey: .connectionId)
        try container.encode(self.requestId, forKey: .requestId)
    }
}
