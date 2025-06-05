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

struct CustomFieldTextFieldDTO {
    
    // MARK: - Properties
    
    let ident: String
    
    let label: String
    
    let value: String?
    
    let updatedAt: Date
    
    let isEmail: Bool
}

// MARK: - Equatable

extension CustomFieldTextFieldDTO: Equatable {
    
    static func == (lhs: CustomFieldTextFieldDTO, rhs: CustomFieldTextFieldDTO) -> Bool {
        lhs.ident == rhs.ident
            && lhs.label == rhs.label
            && lhs.value == rhs.value
            && Calendar.current.compare(lhs.updatedAt, to: rhs.updatedAt, toGranularity: .second) == .orderedSame
            && lhs.isEmail == rhs.isEmail
    }
}

// MARK: - Decodable

extension CustomFieldTextFieldDTO: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case ident
        case label
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.ident = try container.decode(String.self, forKey: .ident)
        self.label = try container.decode(String.self, forKey: .label)
        self.value = nil
        self.updatedAt = .distantPast
        
        switch try container.decode(String.self, forKey: .type) {
        case "text":
            self.isEmail = false
        case "email":
            self.isEmail = true
        default:
            throw DecodingError.valueNotFound(Bool.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "type"))
        }
    }
}
