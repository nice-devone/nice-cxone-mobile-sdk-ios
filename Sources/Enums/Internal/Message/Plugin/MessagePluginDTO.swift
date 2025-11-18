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

/// All info about a payload of a message.
struct MessagePluginDTO: Equatable {
    
    /// The type of message payload content
    let type: PluginMessageDTOType
}

// MARK: - Codable

extension MessagePluginDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case elements
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let object = try container.decode([PluginMessageDTOType].self, forKey: .elements).first else {
            throw DecodingError.valueNotFound(
                PluginMessageDTOType.self,
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "PluginMessageDTOType")
            )
        }
        
        self.type = object
    }
}

#if DEBUG
// MARK: - Encodable

extension MessagePluginDTO: Encodable {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode([type], forKey: .elements)
    }
}
#endif
