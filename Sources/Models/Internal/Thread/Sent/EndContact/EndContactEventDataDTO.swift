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

struct EndContactEventDataDTO {
    
    /// The thread for which this change applies.
    let thread: UUID
    
    /// The contact information 
    let contact: String
}

// MARK: - Encodable

extension EndContactEventDataDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case thread
        case contact
    }
    
    enum ThreadCodingKeys: CodingKey {
        case idOnExternalPlatform
    }
    
    enum ContactCodingKeys: CodingKey {
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var threadContainer = container.nestedContainer(keyedBy: ThreadCodingKeys.self, forKey: .thread)
        try threadContainer.encode(thread, forKey: .idOnExternalPlatform)
        
        var contactContainer = container.nestedContainer(keyedBy: ContactCodingKeys.self, forKey: .contact)
        try contactContainer.encode(contact, forKey: .id)
    }
}
