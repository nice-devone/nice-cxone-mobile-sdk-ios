//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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
    
    var updatedAt: Date {
        switch self {
        case .textField(let entity):
            return entity.updatedAt
        case .selector(let entity):
            return entity.updatedAt
        case .hierarchical(let entity):
            return entity.updatedAt
        }
    }
    
    var value: String? {
        switch self {
        case .textField(let entity):
            return entity.value
        case .selector(let entity):
            return entity.value
        case .hierarchical(let entity):
            return entity.value
        }
    }
    
    // MARK: - Methods
    
    mutating func updateValue(_ value: String) {
        switch self {
        case .textField(let entity):
            self = .textField(
                CustomFieldTextFieldDTO(ident: entity.ident, label: entity.label, value: value, updatedAt: entity.updatedAt, isEmail: entity.isEmail)
            )
        case .selector(let entity):
            self = .selector(
                CustomFieldSelectorDTO(ident: entity.ident, label: entity.label, value: value, updatedAt: entity.updatedAt, options: entity.options)
            )
        case .hierarchical(let entity):
            self = .hierarchical(
                CustomFieldHierarchicalDTO(ident: entity.ident, label: entity.label, value: value, updatedAt: entity.updatedAt, nodes: entity.nodes)
            )
        }
    }
    
    mutating func updateUpdatedAt(_ updatedAt: Date) {
        switch self {
        case .textField(let entity):
            self = .textField(
                CustomFieldTextFieldDTO(ident: entity.ident, label: entity.label, value: entity.value, updatedAt: updatedAt, isEmail: entity.isEmail)
            )
        case .selector(let entity):
            self = .selector(
                CustomFieldSelectorDTO(ident: entity.ident, label: entity.label, value: entity.value, updatedAt: updatedAt, options: entity.options)
            )
        case .hierarchical(let entity):
            self = .hierarchical(
                CustomFieldHierarchicalDTO(ident: entity.ident, label: entity.label, value: entity.value, updatedAt: updatedAt, nodes: entity.nodes)
            )
        }
    }
    
    /// Returns identifier for the value
    ///
    /// For custom field `"gender-male": "Male"` returns `gender-male`
    func getValueIdentifier(for value: String) -> String? {
        switch self {
        case .textField:
            return nil
        case .selector(let entity):
            return entity.options.first { $0.value == value }?.key
        case .hierarchical(let entity):
            return entity.nodes.first { $0.value == value }?.key
        }
    }
    
    /// Returns value
    ///
    /// For custom field `"gender-male": "Male"` returns `Male`
    func getOptionValue(for value: String) -> String? {
        switch self {
        case .textField:
            return nil
        case .selector(let entity):
            return entity.options.first { $0.value == value }?.value
        case .hierarchical(let entity):
            return entity.nodes.first { $0.value == value }?.value
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
