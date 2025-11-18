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

struct AnalyticsEventDTO {

    // MARK: - Properties

    let eventId: UUID
    let type: AnalyticsEventType
    let visitId: UUID
    let destinationId: UUID
    let createdAt: Date
    let data: Encodable

    // MARK: - Init

    init(
        eventId: UUID = UUID(),
        type: AnalyticsEventType,
        visitId: UUID,
        destinationId: UUID,
        createdAt: Date,
        data: Encodable = [String: String]()
    ) {
        self.eventId = eventId
        self.type = type
        self.visitId = visitId
        self.destinationId = destinationId
        self.createdAt = createdAt
        self.data = data
    }

    init(
        eventId: UUID = UUID(),
        type: AnalyticsEventType,
        connection: ConnectionContext,
        createdAt: Date,
        data: Encodable = [String: String]()
    ) throws {
        guard let visitId = connection.visitId else {
            throw CXoneChatError.missingVisitId
        }

        self.init(
            eventId: eventId,
            type: type,
            visitId: visitId,
            destinationId: connection.destinationId,
            createdAt: createdAt,
            data: data
        )
    }
}

// MARK: - Encodable

extension AnalyticsEventDTO: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case eventId = "id"
        case type
        case visitId
        case destination
        case createdAt = "createdAtWithMilliseconds"
        case data
    }

    enum DestinationKeys: String, CodingKey {
        case id
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var destination = container.nestedContainer(keyedBy: DestinationKeys.self, forKey: .destination)

        try container.encode(eventId, forKey: .eventId)
        try container.encode(type, forKey: .type)
        try container.encode(visitId, forKey: .visitId)
        try destination.encode(destinationId, forKey: .id)
        try container.encodeISODate(createdAt, forKey: .createdAt, withFractionalSeconds: true)
        try container.encode(data, forKey: .data)
    }
}
