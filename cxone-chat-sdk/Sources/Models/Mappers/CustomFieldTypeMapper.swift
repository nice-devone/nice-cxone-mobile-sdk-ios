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

enum CustomFieldTypeMapper {
    
    static func map(from entity: CustomFieldDTOType) -> CustomFieldType {
        switch entity {
        case .textField(let entity):
            return .textField(
                CustomFieldTextField(ident: entity.ident, label: entity.label, value: entity.value, isEmail: entity.isEmail, updatedAt: entity.updatedAt)
            )
        case .selector(let entity):
            return .selector(
                CustomFieldSelector(ident: entity.ident, label: entity.label, value: entity.value, options: entity.options, updatedAt: entity.updatedAt)
            )
        case .hierarchical(let entity):
            return .hierarchical(
                CustomFieldHierarchical(
                    ident: entity.ident,
                    label: entity.label,
                    value: entity.value,
                    nodes: entity.nodes.map(CustomFieldHierarchicalNodeDTO.map),
                    updatedAt: entity.updatedAt
                )
            )
        }
    }
    
    static func map(from entity: CustomFieldType) -> CustomFieldDTOType {
        switch entity {
        case .textField(let entity):
            return .textField(
                CustomFieldTextFieldDTO(ident: entity.ident, label: entity.label, value: entity.value, updatedAt: entity.updatedAt, isEmail: entity.isEmail)
            )
        case .selector(let entity):
            return .selector(
                CustomFieldSelectorDTO(ident: entity.ident, label: entity.label, value: entity.value, updatedAt: entity.updatedAt, options: entity.options)
            )
        case .hierarchical(let entity):
            return .hierarchical(
                CustomFieldHierarchicalDTO(
                    ident: entity.ident,
                    label: entity.label,
                    value: entity.value,
                    updatedAt: entity.updatedAt,
                    nodes: entity.nodes.map(CustomFieldHierarchicalNodeDTO.map)
                )
            )
        }
    }
}

private extension CustomFieldHierarchicalNodeDTO {
    
    static func map(from entity: CustomFieldHierarchicalNodeDTO) -> CustomFieldHierarchicalNode {
        CustomFieldHierarchicalNode(value: entity.value, label: entity.label, children: entity.children.map(Self.map))
    }
    
    static func map(from entity: CustomFieldHierarchicalNode) -> CustomFieldHierarchicalNodeDTO {
        CustomFieldHierarchicalNodeDTO(value: entity.value, label: entity.label, children: entity.children.map(Self.map))
    }
}
