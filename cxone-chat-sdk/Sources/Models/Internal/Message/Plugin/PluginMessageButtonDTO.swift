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

struct PluginMessageButtonDTO {
    
    // MARK: - Properties
    
    let id: String
    
    let text: String
    
    let postback: String?
    
    let url: URL?
    
    let displayInApp: Bool
    
    // MARK: - Init
    
    init(id: String, text: String, postback: String?, url: URL?, displayInApp: Bool) {
        self.id = id
        self.text = text
        self.postback = postback
        self.url = url
        self.displayInApp = displayInApp
    }
}

// MARK: - Codable

extension PluginMessageButtonDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case id
        case type
        case text
        case postback
        case url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.postback = try container.decodeIfPresent(String.self, forKey: .postback)
        self.displayInApp = try container.decode(ElementType.self, forKey: .type) == .iFrameButton
        
        if let postback = postback?.lowercased(), postback.contains("deeplink") {
            let dictionary = try postback
                .replacingOccurrences(of: "'", with: "\"")
                .toDictionary()
            
            guard let deeplink = dictionary["deeplink"] as? String else {
                throw DecodingError.valueNotFound(
                    String.self,
                    DecodingError.Context(codingPath: container.codingPath, debugDescription: "PluginMessageButtonDTO")
                )
            }
            guard let url = URL(string: deeplink) else {
                throw DecodingError.typeMismatch(URL.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "PluginMessageButtonDTO"))
            }
            
            self.url = url
        } else if let urlString = try? container.decodeIfPresent(String.self, forKey: .url), !urlString.isEmpty {
            guard let url = URL(string: urlString) else {
                throw DecodingError.typeMismatch(URL.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "PluginMessageButtonDTO"))
            }
            
            self.url = url
        } else {
            self.url = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(displayInApp ? ElementType.iFrameButton.rawValue : ElementType.button.rawValue, forKey: .type)
        try container.encode(text, forKey: .text)
        
        try container.encodeIfPresent(postback, forKey: .postback)
        try container.encodeIfPresent(url?.absoluteString, forKey: .url)
    }
}
