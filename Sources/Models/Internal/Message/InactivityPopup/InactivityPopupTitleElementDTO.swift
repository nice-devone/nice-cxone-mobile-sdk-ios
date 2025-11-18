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

/// Title element within an inactivity popup.
struct InactivityPopupTitleElementDTO: Equatable {
    
    // MARK: - Properties
    
    /// The unique identifier of the element.
    let id: UUID
    
    /// The title text.
    let text: String
}

// MARK: - Decodable

extension InactivityPopupTitleElementDTO: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        #if DEBUG
        case type
        #endif
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
    }
} 

#if DEBUG
// MARK: - Encodable

extension InactivityPopupTitleElementDTO: Encodable {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(ElementType.title.rawValue, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
    }
}
#endif
