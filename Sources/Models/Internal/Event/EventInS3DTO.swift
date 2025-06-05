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

struct EventInS3DTO: Equatable {

    // MARK: - Properties
    
    let eventId: UUID
    
    var eventType: EventType?
    
    let originEventType: EventType
    
    let url: URL
}

// MARK: - ReceivedEvent

extension EventInS3DTO: ReceivedEvent {
    static let eventType: EventType? = .eventInS3

    var postbackEventType: EventType? { nil }
}

// MARK: - Decodable

extension EventInS3DTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case eventId
        case eventType
        case data
    }
    
    enum DataCodingKeys: CodingKey {
        case s3Object
        case originEvent
    }
    enum OriginEventTypeCodingKeys: CodingKey {
        case eventType
    }
    
    enum UrlCodingKeys: CodingKey {
        case url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        let eventTypeContainer = try dataContainer.nestedContainer(keyedBy: OriginEventTypeCodingKeys.self, forKey: .originEvent)
        let urlContainer = try dataContainer.nestedContainer(keyedBy: UrlCodingKeys.self, forKey: .s3Object)

        self.eventId = try container.decode(UUID.self, forKey: .eventId)
        self.eventType = try container.decode(EventType.self, forKey: .eventType)
        self.originEventType = try eventTypeContainer.decode(EventType.self, forKey: .eventType)
        self.url = try urlContainer.decode(URL.self, forKey: .url)
    }
}
