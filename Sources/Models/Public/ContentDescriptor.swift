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

/// Represents info about an attachment data to be uploaded.
public struct ContentDescriptor {
    
    // MARK: - Properties

    /// The actual data of the attachment.
    public let data: ContentDescriptorSource

    /// The MIME type relevant to the attachment type.
    public let mimeType: String

    /// The name of the attachment file.
    public let fileName: String

    /// The friendly (original) name of the file
    public let friendlyName: String
    
    // MARK: - Init
    
    /// - Parameters:
    ///    - data: The actual data of the attachment.
    ///    - mimeType: The MIME type relevant to the attachment type.
    ///    - fileName: The obscured name of the attachment file sent to the server.
    ///    - friendlyName: The friendly (original) name of the attachment file
    public init(data: Data, mimeType: String, fileName: String, friendlyName: String) {
        self.data = ContentDescriptorSource.bytes(data)
        self.mimeType = mimeType
        self.fileName = fileName
        self.friendlyName = friendlyName
    }

    /// - Parameters:
    ///    - data: The actual data of the attachment.
    ///    - mimeType: The MIME type relevant to the attachment type.
    ///    - fileName: The obscured name of the attachment file sent to the server.
    ///    - friendlyName: The friendly (original) name of the attachment file
    public init(url: URL, mimeType: String, fileName: String, friendlyName: String) {
        self.data = .url(url)
        self.mimeType = mimeType
        self.fileName = fileName
        self.friendlyName = friendlyName
    }
}
