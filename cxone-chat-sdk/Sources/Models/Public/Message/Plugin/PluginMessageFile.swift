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

/// A file subelement.
public struct PluginMessageFile {
    
    // MARK: - Properties
    
    /// The unique identifier of the subelement.
    public let id: String
    
    /// The name of the attachment file.
    public let fileName: String
    
    /// The URL where the attachment can be found.
    public let url: URL
    
    /// The MIME type relevant to the attachment type.
    public let mimeType: String
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique identifier of the subelement.
    ///   - fileName: The name of the attachment file.
    ///   - url: The URL where the attachment can be found.
    ///   - mimeType: The MIME type relevant to the attachment type.
    public init(id: String, fileName: String, url: URL, mimeType: String) {
        self.id = id
        self.fileName = fileName
        self.url = url
        self.mimeType = mimeType
    }
}
