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

/// Response given when an attachment is not successfully uploaded.
struct AttachmentUploadFailResponseDTO {
    
    // MARK: - Sub Objects
    
    private struct FileType: Decodable {
        let description: String
        let mimeType: String
    }
    
    // MARK: - Properties
    
    let allowedFileSize: Double
    let allowedFileTypes: [String: String]
    let isAttachmentsEnabled: Bool
}

// MARK: - Decodable

extension AttachmentUploadFailResponseDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case allowedFileSize
        case allowedFileTypes
        case isAttachmentsEnabled
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let allowedFileSize = Double(try container.decode(String.self, forKey: .allowedFileSize)) {
            self.allowedFileSize = allowedFileSize
        } else {
            throw DecodingError.valueNotFound(Double.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "allowedFileSize"))
        }
        
        let allowedFileTypes = try container.decode([FileType].self, forKey: .allowedFileTypes)
        self.allowedFileTypes = Dictionary(uniqueKeysWithValues: allowedFileTypes.map { ($0.mimeType, $0.description) })
        self.isAttachmentsEnabled = try container.decode(Bool.self, forKey: .isAttachmentsEnabled)
    }
}
