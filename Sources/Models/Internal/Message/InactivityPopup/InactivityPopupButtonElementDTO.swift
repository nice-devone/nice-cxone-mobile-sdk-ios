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

/// Button element within an inactivity popup.
struct InactivityPopupButtonElementDTO: Equatable {
    
    // MARK: - Properties
    
    /// The unique identifier of the element.
    let id: UUID
    
    /// The button text.
    let text: String
    
    /// The postback data for the button.
    let postback: String
    
    /// The type of button (refresh or expire).
    let isSessionRefresh: Bool
}

// MARK: - Decodable

extension InactivityPopupButtonElementDTO: Decodable {
    
    private static let regexPattern = "\"isExpired\"\\s*:\\s*false"
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case postback
        #if DEBUG
        case type
        #endif
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.postback = try container.decode(String.self, forKey: .postback)
        
        self.isSessionRefresh = self.postback.range(of: Self.regexPattern, options: .regularExpression) != nil
    }
} 

#if DEBUG
// MARK: - Encodable

extension InactivityPopupButtonElementDTO: Encodable {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(ElementType.button.rawValue, forKey: .type)
        try container.encode(text, forKey: .text)
        try container.encode(postback, forKey: .postback)
    }
}
#endif
