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

/// Complex type with subelements represented as a multi-root tree data structure.
///
/// UI element, on the application side, should present nodes as a nested list
/// and send picker ``nodes`` element's value; if necessary.
public struct CustomFieldHierarchical {
    
    /// The unique key identifier for the SDK contact custom fields sendable via ``ContactCustomFieldsProvider/set(_:for:)``
    /// and selected ``PrechatSurveyNode/value`` from the ``nodes``.
    public let ident: String
    
    /// The title/placeholder for the textfield.
    public let label: String
    
    /// The actual value of the field; if exists.
    public let value: String?
    
    /// The multi-root tree nodes.
    public let nodes: [CustomFieldHierarchicalNode]
    
    let updatedAt: Date
}

// MARK: - Equatable

extension CustomFieldHierarchical: Equatable {
    
    public static func == (lhs: CustomFieldHierarchical, rhs: CustomFieldHierarchical) -> Bool {
        lhs.ident == rhs.ident
            && lhs.label == rhs.label
            && lhs.value == rhs.value
            && lhs.nodes == rhs.nodes
            && Calendar.current.compare(lhs.updatedAt, to: rhs.updatedAt, toGranularity: .second) == .orderedSame
    }
}
