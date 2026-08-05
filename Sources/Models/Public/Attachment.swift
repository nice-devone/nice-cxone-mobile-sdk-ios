//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Foundation

/// Represents info about an uploaded attachment.
public struct Attachment: Equatable, Sendable {
    
    /// The URL where the attachment can be found.
    public let url: String

    /// A friendly name to display to the user.
    public let friendlyName: String

    /// The MIME type relevant to the attachment type.
    public let mimeType: String

    /// The name of the attachment file.
    public let fileName: String

    // MARK: - Init

    /// Creates an `Attachment` value.
    ///
    /// - Parameters:
    ///   - url: The remote URL the file is hosted at.
    ///   - friendlyName: A human-readable name suitable for display in the UI.
    ///   - mimeType: The MIME type (e.g. `image/png`).
    ///   - fileName: The original on-disk filename.
    public init(url: String, friendlyName: String, mimeType: String, fileName: String) {
        self.url = url
        self.friendlyName = friendlyName
        self.mimeType = mimeType
        self.fileName = fileName
    }
}
