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

/// Details about file uploads allowed.
public struct FileRestrictions {
    /// Maximum size of allowed uploads in megabytes (1024x1024).
    public let allowedFileSize: Int32

    /// Details of allowed file mime types.
    public let allowedFileTypes: [AllowedFileType]

    /// True iff attachment uploads are allowed.  If false, no uploads are allowed.
    public let isAttachmentsEnabled: Bool
}

extension FileRestrictions {
    /// Construct from [FileRestrictionsDTO] for internal use only.
    init(from: FileRestrictionsDTO) {
        self.init(
            allowedFileSize: from.allowedFileSize,
            allowedFileTypes: from.allowedFileTypes.map(AllowedFileType.init(from: )),
            isAttachmentsEnabled: from.isAttachmentsEnabled
        )
    }
}
