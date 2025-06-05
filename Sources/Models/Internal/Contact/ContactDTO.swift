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

// ContactView

/// Represents all info about a contact (case).
struct ContactDTO: Equatable {

    // MARK: - Properties

    /// The id of the contact.
    let id: String

    /// The id of the thread for which this contact applies.
    let threadIdOnExternalPlatform: UUID

    /// The status of the contact.
    let status: ContactStatus

    /// The timestamp of when the message was created.
    let createdAt: Date
    
    let customFields: [CustomFieldDTO]
}

// MARK: - Codable

extension ContactDTO: Codable {
    
    /// The Contact coding keys.
    enum CodingKeys: CodingKey {
        /// The id of the contact.
        case id
        /// The id of the thread for which this contact applies.
        case threadIdOnExternalPlatform
        /// The status of the contact.
        case status
        /// The timestamp of when the message was created.
        case createdAt
        case customFields
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.threadIdOnExternalPlatform = try container.decode(UUID.self, forKey: .threadIdOnExternalPlatform)
        self.status = try container.decode(ContactStatus.self, forKey: .status)
        self.createdAt = try container.decodeISODate(forKey: .createdAt)
        self.customFields = try container.decode([CustomFieldDTO].self, forKey: .customFields)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(threadIdOnExternalPlatform, forKey: .threadIdOnExternalPlatform)
        try container.encode(status, forKey: .status)
        try container.encodeISODate(createdAt, forKey: .createdAt)
        try container.encode(customFields, forKey: .customFields)
    }
}
