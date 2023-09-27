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

import CXoneChatSDK

enum FormCustomFieldType {
    
    // MARK: - Cases
    
    case textField(FormTextFieldEntity)
    
    case list(FormListFieldEntity)
    
    case tree(FormTreeFieldEntity)
    
    // MARK: - Init
    
    init(from entity: PreChatSurveyCustomField, with customFields: [String: String]? = nil) {
        switch entity.type {
        case .textField(let textField):
            let value = customFields?[textField.ident]
            
            self = .textField(
                FormTextFieldEntity(label: textField.label, ident: textField.ident, value: value, isRequired: entity.isRequired, isEmail: textField.isEmail)
            )
        case .selector(let list):
            let value = customFields?[list.ident]
            
            self = .list(FormListFieldEntity(label: list.label, ident: list.ident, value: value, isRequired: entity.isRequired, options: list.options))
        case .hierarchical(let tree):
            let value = customFields?[tree.ident]
            
            self = .tree(FormTreeFieldEntity(label: tree.label, ident: tree.ident, value: value, isRequired: entity.isRequired, nodes: tree.nodes))
        }
    }
    
    init(from type: CustomFieldType) {
        switch type {
        case .textField(let entity):
            self = .textField(FormTextFieldEntity(label: entity.label, ident: entity.ident, value: entity.value, isRequired: false, isEmail: entity.isEmail))
        case .selector(let entity):
            self = .list(FormListFieldEntity(label: entity.label, ident: entity.ident, value: entity.value, isRequired: false, options: entity.options))
        case .hierarchical(let entity):
            self = .tree(FormTreeFieldEntity(label: entity.label, ident: entity.ident, value: entity.value, isRequired: false, nodes: entity.nodes))
        }
    }
}
