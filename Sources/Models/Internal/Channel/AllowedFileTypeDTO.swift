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

/// Details about a file type allowed to be uploaded
struct AllowedFileTypeDTO {
    /// Allowed mime type.
    ///
    /// This may be of the form [type/*] in which case any subtype is allowed
    /// as long as the mime type type portion matches "type".
    let mimeType: String
    let details: String // description collides with CustomStringConvertible
}

extension AllowedFileTypeDTO: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case mimeType
        case details = "description"
    }
}
