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

struct CaseStatusChangedEventDTO: Equatable {
    
    // MARK: - Properties
    
    var eventId: UUID
    
    var eventObject: EventObjectType
    
    var eventType: EventType?
    
    var createdAt: Date
    
    let data: CaseStatusChangedDataDTO
}

// MARK: - ReceivedEvent

extension CaseStatusChangedEventDTO: ReceivedEvent {
    static let eventType: EventType? = .caseStatusChanged

    var postbackEventType: EventType? { nil }
}

// MARK: - Decodable

extension CaseStatusChangedEventDTO: Decodable {
 
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
        self.data = try container.decode(CaseStatusChangedDataDTO.self, forKey: .data)
    }
}
