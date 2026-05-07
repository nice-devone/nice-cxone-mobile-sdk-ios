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

struct MessageTimePickerDTO: Equatable {
    /// Text displayed in the conversation cell.
    let title: String
    /// Title shown at the top of the time picker sheet.
    let sheetTitle: String
    /// List of available time slot options.
    let timeSlots: [MessageTimePickerTimeSlotDTO]
}

// MARK: - Codable

extension MessageTimePickerDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case title
        case event
    }
    enum TitleKeys: CodingKey {
        case content
    }
    enum EventKeys: CodingKey {
        case title
        case timeSlots
    }
    enum EventTitleKeys: CodingKey {
        case content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let titleContainer = try container.nestedContainer(keyedBy: TitleKeys.self, forKey: .title)
        let eventContainer = try container.nestedContainer(keyedBy: EventKeys.self, forKey: .event)
        let eventTitleContainer = try eventContainer.nestedContainer(keyedBy: EventTitleKeys.self, forKey: .title)
        
        self.title = try titleContainer.decode(String.self, forKey: .content)
        self.sheetTitle = try eventTitleContainer.decode(String.self, forKey: .content)
        self.timeSlots = try eventContainer.decode([MessageTimePickerTimeSlotDTO].self, forKey: .timeSlots)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var titleContainer = container.nestedContainer(keyedBy: TitleKeys.self, forKey: .title)
        var eventContainer = container.nestedContainer(keyedBy: EventKeys.self, forKey: .event)
        var eventTitleContainer = eventContainer.nestedContainer(keyedBy: EventTitleKeys.self, forKey: .title)
        
        try titleContainer.encode(title, forKey: .content)
        try eventTitleContainer.encode(sheetTitle, forKey: .content)
        try eventContainer.encode(timeSlots, forKey: .timeSlots)
    }
}
