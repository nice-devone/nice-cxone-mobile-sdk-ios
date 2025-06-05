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

/// A list/selector element type. It contains list of options which are selected via dropdown picker, table or related UI element.
public struct CustomFieldSelector {
    
    /// The unique key identifier for the SDK contact custom fields sendable via ``ContactCustomFieldsProvider/set(_:for:)``.
    public let ident: String
    
    /// The title/placeholder for the textfield.
    public let label: String
    
    /// The actual value of the custom field; if exists.
    public let value: String?
    
    /// Key-value pairs with selector options.
    ///
    /// Key represents a value identifier on the backend side and value is used as a label in the application UI component.
    /// Integration application has to send value identifier instead of its real value because value might change.
    public let options: [String: String]
    
    let updatedAt: Date
}

// MARK: - Equatable

extension CustomFieldSelector: Equatable {
    
    public static func == (lhs: CustomFieldSelector, rhs: CustomFieldSelector) -> Bool {
        lhs.ident == rhs.ident
            && lhs.label == rhs.label
            && lhs.value == rhs.value
            && lhs.options == rhs.options
            && Calendar.current.compare(lhs.updatedAt, to: rhs.updatedAt, toGranularity: .second) == .orderedSame
    }
}
