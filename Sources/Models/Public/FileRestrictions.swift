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

/// A value type describing the constraints applied to file uploads.
///
/// This model is used to determine whether attachments can be uploaded,
/// the maximum allowed file size (in MiB, where 1 MiB = 1024×1024 bytes),
/// and the list of permitted MIME types.
///
/// - Note: If `isAttachmentsEnabled` is `false`, uploads should be disabled
///   regardless of size or type.
public struct FileRestrictions {

    // MARK: - Properties

    /// Maximum size of allowed uploads in megabytes (1024x1024).
    public let allowedFileSize: Int32

    /// Details of allowed file mime types.
    public let allowedFileTypes: [AllowedFileType]

    /// True iff attachment uploads are allowed.  If false, no uploads are allowed.
    public let isAttachmentsEnabled: Bool

    // MARK: - Init

    /// Creates a new set of file upload restrictions.
    ///
    /// - Parameters:
    ///   - allowedFileSize: The maximum allowed file size in mebibytes (MiB, 1024x1024 bytes).
    ///   - allowedFileTypes: The list of permitted MIME types for uploads.
    ///   - isAttachmentsEnabled: A Boolean value indicating whether attachment uploads are allowed at all.
    public init(allowedFileSize: Int32, allowedFileTypes: [AllowedFileType], isAttachmentsEnabled: Bool) {
        self.allowedFileSize = allowedFileSize
        self.allowedFileTypes = allowedFileTypes
        self.isAttachmentsEnabled = isAttachmentsEnabled
    }
}

// MARK: - Mappers

extension FileRestrictions {
    
    /// Construct from [FileRestrictionsDTO] for internal use only.
    init(from: FileRestrictionsDTO) {
        self.init(
            allowedFileSize: from.allowedFileSize,
            allowedFileTypes: from.allowedFileTypes.map(AllowedFileType.init),
            isAttachmentsEnabled: from.isAttachmentsEnabled
        )
    }
}
