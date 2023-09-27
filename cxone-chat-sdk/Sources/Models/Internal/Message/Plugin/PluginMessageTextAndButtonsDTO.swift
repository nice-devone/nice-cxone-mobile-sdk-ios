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

struct PluginMessageTextAndButtonsDTO {
    
    // MARK: - Properties
    
    let id: String
    
    let elements: [PluginMessageSubElementDTOType]
    
    // MARK: - Init
    
    init(id: String, elements: [PluginMessageSubElementDTOType]) {
        self.id = id
        self.elements = elements
    }
}

// MARK: - Codable

extension PluginMessageTextAndButtonsDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case id
        case type
        case elements
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard try container.decode(ElementType.self, forKey: .type) == .textAndButtons else {
            throw DecodingError.typeMismatch(
                ElementType.self,
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "PluginMessageTextAndButtonsElement")
            )
        }
        
        self.id = try container.decode(String.self, forKey: .id)
        self.elements = try container.decode([PluginMessageSubElementDTOType].self, forKey: .elements)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(ElementType.textAndButtons.rawValue, forKey: .type)
        try container.encode(elements, forKey: .elements)
    }
}
