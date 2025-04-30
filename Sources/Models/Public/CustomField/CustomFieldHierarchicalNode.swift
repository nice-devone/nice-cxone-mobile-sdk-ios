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

/// A single element of the ``PreChatSurveyHierarchical/nodes`` represented as a tree data structure.
public struct CustomFieldHierarchicalNode {
    
    /// The value for the contact custom fields.
    ///
    /// Send in combination of ``PreChatSurveyHierarchical/ident`` via ``ContactCustomFieldsProvider/set(_:for:)`` method.
    public let value: String
    
    /// The text for UI element which represents its value.
    ///
    /// - Warning: Dont send this property as a value of ``ContactCustomFieldsProvider/set(_:for:)``.
    /// It only readable representation of its actual ``value``.
    public let label: String
    
    /// The tree leaves; if any exists.
    public let children: [CustomFieldHierarchicalNode]
}

// MARK: - Equatable

extension CustomFieldHierarchicalNode: Equatable {
    
    public static func == (lhs: CustomFieldHierarchicalNode, rhs: CustomFieldHierarchicalNode) -> Bool {
        lhs.value == rhs.value
            && lhs.label == rhs.label
            && lhs.value == rhs.value
            && lhs.children == rhs.children
    }
}
