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

struct SetContactCustomFieldsEventDataDTO {
    
    // MARK: - Properties
    
    let thread: ThreadDTO

    let customFields: [CustomFieldDTO]

    let contactId: String
}

// MARK: - Codable

extension SetContactCustomFieldsEventDataDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case thread
        case customFields
        case contact
    }
    
    enum ContactKeys: CodingKey {
        case id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let contactIdentifierContainer = try container.nestedContainer(keyedBy: ContactKeys.self, forKey: .contact)
        
        self.thread = try container.decode(ThreadDTO.self, forKey: .thread)
        self.customFields = try container.decode([CustomFieldDTO].self, forKey: .customFields)
        self.contactId = try contactIdentifierContainer.decode(String.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var contactIdentifierContainer = container.nestedContainer(keyedBy: ContactKeys.self, forKey: .contact)
        
        try container.encode(thread, forKey: .thread)
        try container.encode(customFields, forKey: .customFields)
        try contactIdentifierContainer.encode(contactId, forKey: .id)
    }
}
