//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

/// Represents all data about a single custom field.
struct CustomFieldDTO: Equatable {

    // MARK: - Properties

    let ident: String

    var value: String
    
    var updatedAt: Date

    // MARK: - Init

    /// - Parameters:
    ///   - ident: The key of the custom field data.
    ///   - value: The actual value of the custom field.
    ///   - updatedAt: The timestamp of the value when the value has been created/updated.
    init(ident: String, value: String, updatedAt: Date) {
        self.ident = ident
        self.value = value
        self.updatedAt = updatedAt
    }
    
    init?(from type: CustomFieldDTOType) {
        guard let value = type.value, !value.isEmpty else {
            return nil
        }
        
        self = CustomFieldDTO(ident: type.ident, value: value, updatedAt: type.updatedAt)
    }
}

// MARK: - Codable

extension CustomFieldDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case ident
        case value
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.ident = try container.decode(String.self, forKey: .ident)
        self.value = try container.decode(String.self, forKey: .value)
        self.updatedAt = try container.decodeISODate(forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(ident, forKey: .ident)
        try container.encode(value, forKey: .value)
        try container.encodeISODate(updatedAt, forKey: .updatedAt)
    }
}
