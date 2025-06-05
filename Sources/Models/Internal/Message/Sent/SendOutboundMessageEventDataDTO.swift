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

struct SendOutboundMessageEventDataDTO {
    
    // MARK: - Properties
    
    let thread: ThreadDTO

    let contentType: MessageContentDTOType

    let idOnExternalPlatform: UUID

    let contactCustomFields: [CustomFieldDTO]

    let attachments: [AttachmentDTO]

    let deviceFingerprint: DeviceFingerprintDTO

    let token: String?
}

// MARK: - Encodable

extension SendOutboundMessageEventDataDTO: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case thread
        case messageContent
        case idOnExternalPlatform
        case contact = "consumerContact"
        case attachments
        case deviceFingerprint = "browserFingerprint"
        case accessToken
    }
    
    enum AccessTokenCodingKey: CodingKey {
        case token
    }
    
    enum ContactCustomFieldsCodingKey: CodingKey {
        case customFields
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var contactCustomFieldsContainer = container.nestedContainer(keyedBy: ContactCustomFieldsCodingKey.self, forKey: .contact)
        
        try container.encode(thread, forKey: .thread)
        try container.encode(contentType, forKey: .messageContent)
        try container.encode(idOnExternalPlatform, forKey: .idOnExternalPlatform)
        try contactCustomFieldsContainer.encode(contactCustomFields, forKey: .customFields)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(deviceFingerprint, forKey: .deviceFingerprint)
        
        if let token = token, !token.isEmpty {
            var accessTokenContainer = container.nestedContainer(keyedBy: AccessTokenCodingKey.self, forKey: .accessToken)
            
            try accessTokenContainer.encode(token, forKey: .token)
        }
    }
}
