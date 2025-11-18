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

/// Type-safe enum for inactivity popup elements with associated values.
enum MessagePluginSubElementDTOType: Equatable {
    
    /// Title element.
    case title(InactivityPopupTitleElementDTO)
    
    /// Text/body element.
    case text(InactivityPopupTextElementDTO)
    
    /// Button element.
    case button(InactivityPopupButtonElementDTO)
    
    /// Countdown element.
    case countdown(InactivityPopupCountdownElementDTO)
}

// MARK: - Decodable

extension MessagePluginSubElementDTOType: Decodable {
    
    enum CodingKeys: CodingKey {
        case type
        case payload
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let singleContainer = try decoder.singleValueContainer()
        
        let elementType = try container.decode(ElementType.self, forKey: .type)
        
        switch elementType {
        case .title:
            self = .title(try singleContainer.decode(InactivityPopupTitleElementDTO.self))
        case .text:
            self = .text(try singleContainer.decode(InactivityPopupTextElementDTO.self))
        case .button:
            self = .button(try singleContainer.decode(InactivityPopupButtonElementDTO.self))
        case .countdown:
            self = .countdown(try singleContainer.decode(InactivityPopupCountdownElementDTO.self))
        default:
            throw DecodingError.valueNotFound(
                MessagePluginSubElementDTOType.self,
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unsupported inactivity popup element type: \(elementType)")
            )
        }
    }
}

#if DEBUG
// MARK: - Encodable

extension MessagePluginSubElementDTOType: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .title(let titleElement):
            try container.encode(ElementType.title, forKey: .type)
            try titleElement.encode(to: encoder)
        case .text(let textElement):
            try container.encode(ElementType.text, forKey: .type)
            try textElement.encode(to: encoder)
        case .button(let buttonElement):
            try container.encode(ElementType.button, forKey: .type)
            try buttonElement.encode(to: encoder)
        case .countdown(let countdownElement):
            try container.encode(ElementType.countdown, forKey: .type)
            try countdownElement.encode(to: encoder)
        }
    }
}
#endif
