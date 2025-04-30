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

enum CustomFieldDTOType: Equatable {
    
    // MARK: - Cases
    
    case textField(CustomFieldTextFieldDTO)
    
    case selector(CustomFieldSelectorDTO)
    
    case hierarchical(CustomFieldHierarchicalDTO)
    
    // MARK: - Properties
    
    var ident: String {
        switch self {
        case .textField(let entity):
            return entity.ident
        case .selector(let entity):
            return entity.ident
        case .hierarchical(let entity):
            return entity.ident
        }
    }
    
    // MARK: - Methods
    
    /// Returns identifier for the value
    ///
    /// For custom field `"gender-male": "Male"` returns `gender-male`
    func isValueIdentifier(_ valueIdentifier: String) -> Bool {
        switch self {
        case .selector(let entity):
            return entity.options.contains { $0.key == valueIdentifier }
        case .hierarchical(let entity):
            return entity.nodes.contains { $0.getValueIdentifier(with: valueIdentifier) != nil }
        default:
            return false
        }
    }
    
    /// Returns identifier for the value
    ///
    /// For custom field `"gender-male": "Male"`, based on `"Male"` returns `gender-male`
    func getValueIdentifier(for value: String) -> String? {
        switch self {
        case .selector(let entity):
            return entity.options.first { $0.key == value }?.key
        case .hierarchical(let entity):
            return entity.nodes.first { $0.getValueIdentifier(with: value) != nil }?.key
        default:
            return nil
        }
    }
    
    /// Returns actual value based on the `value` parameter
    ///
    /// For custom field `"gender-male": "Male"`, based on `"Male"` returns `Male`
    func isOptionValue(_ value: String) -> Bool {
        switch self {
        case .textField:
            return false
        case .selector(let entity):
            return entity.options.contains { $0.value == value }
        case .hierarchical(let entity):
            return entity.nodes.contains { $0.value == value }
        }
    }
}

// MARK: - Decodable

extension CustomFieldDTOType: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let textfield = try? container.decode(CustomFieldTextFieldDTO.self) {
            self = .textField(textfield)
        } else if let selector = try? container.decode(CustomFieldSelectorDTO.self) {
            self = .selector(selector)
        } else if let hierarchical = try? container.decode(CustomFieldHierarchicalDTO.self) {
            self = .hierarchical(hierarchical)
        } else {
            throw DecodingError.valueNotFound(CustomFieldDTOType.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "type"))
        }
    }
}

private extension CustomFieldHierarchicalNodeDTO {
 
    func getValueIdentifier(with value: String) -> String? {
        if children.isEmpty {
            return key
        } else {
            return children.first { $0.getValueIdentifier(with: value) != nil }?.key
        }
    }
}
