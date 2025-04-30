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

/// A textfield element which contains simple textfield or e-mail.
///
/// In case of e-mail, detectable with `isEmail` property, BE requires proper e-mail validation on the application side.
public struct CustomFieldTextField {
    
    /// The unique key identifier for the SDK contact custom fields sendable via ``ContactCustomFieldsProvider/set(_:for:)``.
    public let ident: String
    
    /// The title/placeholder for the textfield.
    public let label: String
    
    /// The actual value of the field; if exists.
    public let value: String?
    
    /// Determines if element is a simple text field or e-mail.
    public let isEmail: Bool
    
    let updatedAt: Date
}

// MARK: - Equatable

extension CustomFieldTextField: Equatable {
    
    public static func == (lhs: CustomFieldTextField, rhs: CustomFieldTextField) -> Bool {
        lhs.ident == rhs.ident
            && lhs.label == rhs.label
            && lhs.value == rhs.value
            && Calendar.current.compare(lhs.updatedAt, to: rhs.updatedAt, toGranularity: .second) == .orderedSame
            && lhs.isEmail == rhs.isEmail
    }
}
