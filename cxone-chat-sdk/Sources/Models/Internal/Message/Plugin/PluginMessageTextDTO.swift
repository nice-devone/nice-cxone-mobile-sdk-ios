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

struct PluginMessageTextDTO {
    
    // MARK: - Properties
    
    let id: String
    
    let text: String
    
    let mimeType: String?
    
    // MARK: - Init
    
    init(id: String, text: String, mimeType: String?) {
        self.id = id
        self.text = text
        self.mimeType = mimeType
    }
}

// MARK: - Codable

extension PluginMessageTextDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case id
        case type
        case text
        case mimeType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(ElementType.text.rawValue, forKey: .type)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(mimeType, forKey: .mimeType)
    }
}
