//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Foundation

extension PersonNameComponentsFormatter {

    private static let sharedFormatter = PersonNameComponentsFormatter()

    /// Formats a first and last name into a single locale-aware full name.
    /// - Parameters:
    ///   - firstName: The given name, if any.
    ///   - lastName: The family name, if any.
    /// - Returns: The formatted full name, or `nil` when neither name produces any text. Whitespace-only names count as missing.
    static func fullName(firstName: String?, lastName: String?) -> String? {
        var nameComponents = PersonNameComponents()
        nameComponents.givenName = firstName?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty()
        nameComponents.familyName = lastName?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty()

        return sharedFormatter.string(from: nameComponents).nilIfEmpty()
    }
}
