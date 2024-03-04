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

struct PluginMessageFileDTO {
    
    // MARK: - Properties
    
    let id: String
    
    let fileName: String
    
    let url: URL
    
    let mimeType: String
}

// MARK: - Codable

extension PluginMessageFileDTO: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case fileName = "filename"
        case url
        case mimeType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.fileName = try container.decode(String.self, forKey: .fileName)
        self.mimeType = try container.decode(String.self, forKey: .mimeType)
        
        let urlString = try container.decode(String.self, forKey: .url)
        
        guard let url = URL(string: urlString) else {
            throw DecodingError.typeMismatch(URL.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "PluginMessageFileSubElement"))
        }
        
        self.url = url
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(ElementType.file.rawValue, forKey: .type)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(url.absoluteString, forKey: .url)
        try container.encode(mimeType, forKey: .mimeType)
    }
}
