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

/// All info about a payload of a message.
struct MessagePluginDTO {
    
    // MARK: - Properties
    
    /// The content of the payload.
    let text: String?
    
    /// The postback  of the payload.
    let postback: String?
    
    /// The type of message payload content
    let element: PluginMessageDTOType
    
    // MARK: - Init
    
    init(text: String?, postback: String?, element: PluginMessageDTOType) {
        self.text = text
        self.postback = postback
        self.element = element
    }
}

// MARK: - Codable

extension MessagePluginDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case text
        case postback
        case elements
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.postback = try container.decodeIfPresent(String.self, forKey: .postback)
        
        if let subElements = try? container.decode([PluginMessageSubElementDTOType].self, forKey: .elements) {
            self.element = .subElements(subElements)
        } else if let objects = try? container.decode([PluginMessageDTOType].self, forKey: .elements) {
            if objects.count > 1 {
                self.element = .gallery(objects)
            } else {
                self.element = objects[0]
            }
        } else {
            throw DecodingError.typeMismatch(
                PluginMessageDTOType.self,
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "MessagePayloadDTO")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(self.text, forKey: .text)
        try container.encodeIfPresent(self.postback, forKey: .postback)
        
        switch element {
        case .gallery, .subElements:
            try container.encode(element, forKey: .elements)
        default:
            try container.encode([element], forKey: .elements)
        }
    }
}
