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
import Foundation

extension SendOutboundMessageEventDataDTO: Swift.Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let accessTokenContainer = try? container.nestedContainer(keyedBy: AccessTokenCodingKey.self, forKey: .accessToken)
        let contactCustomFieldsContainer = try container.nestedContainer(keyedBy: ContactCustomFieldsCodingKey.self, forKey: .contact)
        
        self.init(
            thread: try container.decode(ThreadDTO.self, forKey: .thread),
            contentType: try container.decode(MessageContentDTOType.self, forKey: .messageContent),
            idOnExternalPlatform: try container.decode(UUID.self, forKey: .idOnExternalPlatform),
            contactCustomFields: try contactCustomFieldsContainer.decode([CustomFieldDTO].self, forKey: .customFields),
            attachments: try container.decode([AttachmentDTO].self, forKey: .attachments),
            deviceFingerprint: try container.decode(DeviceFingerprintDTO.self, forKey: .deviceFingerprint),
            token: try accessTokenContainer?.decodeIfPresent(String.self, forKey: .token)
        )
    }
}
