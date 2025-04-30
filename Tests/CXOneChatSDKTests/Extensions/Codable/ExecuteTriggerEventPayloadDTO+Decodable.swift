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

@testable import CXoneChatSDK

extension ExecuteTriggerEventPayloadDTO: Swift.Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let destinationContainer = try container.nestedContainer(keyedBy: DestinationKeys.self, forKey: .destination)
        let visitorContainer = try container.nestedContainer(keyedBy: VisitorKeys.self, forKey: .visitor)
        let triggerContainer = try container
            .nestedContainer(keyedBy: TriggerDataKeys.self, forKey: .data)
            .nestedContainer(keyedBy: TriggerKeys.self, forKey: .trigger)
        
        self.init(
            eventType: try container.decode(EventType.self, forKey: .eventType),
            brand: try container.decode(BrandDTO.self, forKey: .brand),
            channel: try container.decode(ChannelIdentifierDTO.self, forKey: .channel),
            customerIdentity: try container.decode(CustomerIdentityDTO.self, forKey: .customerIdentity),
            eventId: try destinationContainer.decode(LowerCaseUUID.self, forKey: .id),
            visitorId: try visitorContainer.decode(LowerCaseUUID.self, forKey: .id),
            triggerId: try triggerContainer.decode(LowerCaseUUID.self, forKey: .id)
        )
    }
}
