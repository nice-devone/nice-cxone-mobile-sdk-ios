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

struct MessageQuickRepliesDTO: Equatable {
    
    let title: String
    
    let buttons: [MessageReplyButtonDTO]
}

// MARK: - Codable

extension MessageQuickRepliesDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case text
        case actions
    }

    enum TextKeys: CodingKey {
        case content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let textContainer = try container.nestedContainer(keyedBy: TextKeys.self, forKey: .text)
        
        self.title = try textContainer.decode(String.self, forKey: .content)
        self.buttons = try container.decode([MessageReplyButtonDTO].self, forKey: .actions)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var textContainer = container.nestedContainer(keyedBy: TextKeys.self, forKey: .text)
        
        try textContainer.encode(title, forKey: .content)
        try container.encode(buttons, forKey: .actions)
    }
}
