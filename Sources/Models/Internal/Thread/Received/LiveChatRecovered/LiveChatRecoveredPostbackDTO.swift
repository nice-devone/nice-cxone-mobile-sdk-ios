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

struct LiveChatRecoveredPostbackDTO: Decodable, Equatable {
    
    let eventType: EventType
    
    let data: LiveChatRecoveredPostbackDataDTO?
}

// MARK: - Decodable

extension LiveChatRecoveredPostbackDTO {
    
    enum CodingKeys: CodingKey {
        case eventType
        case data
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.eventType = try container.decode(EventType.self, forKey: .eventType)
        self.data = try? container.decodeIfPresent(LiveChatRecoveredPostbackDataDTO.self, forKey: .data)
    }
}
