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

struct PluginMessageCustomDTO {
    
    // MARK: - Properties
    
    let id: String
    
    let text: String?
    
    let variables: [String: CodableObject]
    
    // MARK: - Init
    
    init(id: String, text: String?, variables: [String: CodableObject]) {
        self.id = id
        self.text = text
        self.variables = variables
    }
}

// MARK: - Codable

extension PluginMessageCustomDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case id
        case text
        case type
        case variables
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.variables = try container.decode([String: CodableObject].self, forKey: .variables)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(ElementType.custom.rawValue, forKey: .type)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encode(variables, forKey: .variables)
    }
}
