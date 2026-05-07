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

struct MessageTimePickerTimeSlotDTO: Equatable {
    /// Unique identifier for the time slot.
    let id: String
    /// Duration of the time slot, in seconds.
    let duration: Int
    /// Start date and time of the slot.
    let startTime: Date
}

// MARK: - Codable

extension MessageTimePickerTimeSlotDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case id
        case duration
        case startTime
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.duration = try container.decode(Int.self, forKey: .duration)
        self.startTime = try container.decodeISODate(forKey: .startTime)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(duration, forKey: .duration)
        try container.encodeISODate(startTime, forKey: .startTime)
    }
}
