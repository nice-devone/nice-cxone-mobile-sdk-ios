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

@testable import CXoneChatSDK

extension MessageDTO: Swift.Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(idOnExternalPlatform, forKey: .idOnExternalPlatform)
        try container.encode(threadIdOnExternalPlatform, forKey: .threadIdOnExternalPlatform)
        try container.encodeISODate(createdAt, forKey: .createdAt)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(direction, forKey: .direction)
        try container.encode(contentType, forKey: .messageContent)
        try container.encode(userStatistics, forKey: .userStatistics)
        try container.encodeIfPresent(authorUser, forKey: .authorUser)
        try container.encodeIfPresent(authorEndUserIdentity, forKey: .authorEndUserIdentity)
    }
}
