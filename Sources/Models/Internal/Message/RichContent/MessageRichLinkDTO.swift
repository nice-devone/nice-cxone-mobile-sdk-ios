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

struct MessageRichLinkDTO: Equatable {
    
    let title: String
    
    let url: URL
    
    let fileName: String
    
    let fileUrl: URL
    
    let mimeType: String
}

// MARK: - Codable

extension MessageRichLinkDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case media
        case title
        case url
    }

    enum TitleKeys: CodingKey {
        case content
    }
    
    enum MediaKeys: CodingKey {
        case fileName
        case url
        case mimeType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mediaContainer = try container.nestedContainer(keyedBy: MediaKeys.self, forKey: .media)
        let titleContainer = try container.nestedContainer(keyedBy: TitleKeys.self, forKey: .title)
        
        self.fileName = try mediaContainer.decode(String.self, forKey: .fileName)
        self.fileUrl = try mediaContainer.decode(URL.self, forKey: .url)
        self.mimeType = try mediaContainer.decode(String.self, forKey: .mimeType)
        self.title = try titleContainer.decode(String.self, forKey: .content)
        self.url = try container.decode(URL.self, forKey: .url)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var mediaContainer = container.nestedContainer(keyedBy: MediaKeys.self, forKey: .media)
        var titleContainer = container.nestedContainer(keyedBy: TitleKeys.self, forKey: .title)
        
        try mediaContainer.encode(fileName, forKey: .fileName)
        try mediaContainer.encode(fileUrl.absoluteString, forKey: .url)
        try mediaContainer.encode(mimeType, forKey: .mimeType)
        try titleContainer.encode(title, forKey: .content)
        try container.encode(url.absoluteString, forKey: .url)
    }
}
