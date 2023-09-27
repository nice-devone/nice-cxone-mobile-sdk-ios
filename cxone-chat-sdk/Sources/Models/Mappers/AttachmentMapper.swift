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

enum AttachmentMapper {
    
    static func map(_ entity: Attachment) -> AttachmentDTO {
        AttachmentDTO(url: entity.url, friendlyName: entity.friendlyName, mimeType: entity.mimeType, fileName: entity.fileName)
    }
    
    static func map(_ entity: AttachmentDTO) -> Attachment {
        Attachment(url: entity.url, friendlyName: entity.friendlyName, mimeType: entity.mimeType, fileName: entity.fileName)
    }
}
