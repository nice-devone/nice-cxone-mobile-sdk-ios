//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

struct StoreVisitorEventsPayloadDTO {

    let eventType: EventType

    let brand: BrandDTO

    let visitorId: LowerCaseUUID

    let id: LowerCaseUUID

    let data: EventDataType

    let channel: ChannelIdentifierDTO
}

// MARK: - Encodable

extension StoreVisitorEventsPayloadDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case eventType
        case brand
        case visitor
        case destination
        case data
        case channel
    }
    
    enum DestinationKeys: CodingKey {
        case id
    }
    
    enum VisitorKeys: CodingKey {
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var destinationContainer = container.nestedContainer(keyedBy: DestinationKeys.self, forKey: .destination)
        var visitorContainer = container.nestedContainer(keyedBy: VisitorKeys.self, forKey: .visitor)
        
        try container.encode(eventType, forKey: .eventType)
        try container.encode(brand, forKey: .brand)
        try visitorContainer.encode(visitorId, forKey: .id)
        try destinationContainer.encode(id, forKey: .id)
        try container.encode(data, forKey: .data)
        try container.encode(channel, forKey: .channel)
    }
}
