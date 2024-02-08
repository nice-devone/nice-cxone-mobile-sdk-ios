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

enum PluginMessageSubElementDTOType {
    
    case text(PluginMessageTextDTO)
    
    case button(PluginMessageButtonDTO)
    
    case file(PluginMessageFileDTO)
    
    case title(PluginMessageTitleDTO)
}

// MARK: - Codable

extension PluginMessageSubElementDTOType: Codable {
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let singleContainer = try decoder.singleValueContainer()
        
        switch try container.decode(ElementType.self, forKey: .type) {
        case .button, .iFrameButton:
            self = .button(try singleContainer.decode(PluginMessageButtonDTO.self))
        case .text:
            self = .text(try singleContainer.decode(PluginMessageTextDTO.self))
        case .file:
            self = .file(try singleContainer.decode(PluginMessageFileDTO.self))
        case .title:
            self = .title(try singleContainer.decode(PluginMessageTitleDTO.self))
        default:
            throw DecodingError.valueNotFound(
                PluginMessageSubElementDTOType.self,
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "type")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .text(let entity):
            try container.encode(entity)
        case .button(let entity):
            try container.encode(entity)
        case .file(let entity):
            try container.encode(entity)
        case .title(let entity):
            try container.encode(entity)
        }
    }
}
