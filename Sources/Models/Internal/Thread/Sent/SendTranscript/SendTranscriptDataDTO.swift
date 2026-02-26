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

struct SendTranscriptDataDTO {

    // MARK: - Properties
    
    let consumerContact: String
    let consumerRecipient: String
}

// MARK: - Encodable

extension SendTranscriptDataDTO: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case consumerContact
        case consumerRecipients
    }
    enum ConsumerContactKeys: String, CodingKey {
        case id
    }
    enum ConsumerRecipientKeys: String, CodingKey {
        case idOnExternalPlatform
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        var consumerContactContainer = container.nestedContainer(keyedBy: ConsumerContactKeys.self, forKey: .consumerContact)
        try consumerContactContainer.encode(self.consumerContact, forKey: .id)

        let recipientsArray: [[String: String]] = [
            [ConsumerRecipientKeys.idOnExternalPlatform.rawValue: consumerRecipient]
        ]
        try container.encode(recipientsArray, forKey: .consumerRecipients)
    }
}
