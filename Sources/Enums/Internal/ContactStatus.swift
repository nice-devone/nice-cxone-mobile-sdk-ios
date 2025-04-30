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

/// The list of all statuses on a contact.
enum ContactStatus: String, CaseIterable {
    
    /// The contact is newly opened.
    case new
    
    /// The contact is currently open.
    case open

    /// The contact is pending.
    case pending

    /// The contact has been escalated.
    case escalated

    /// The contact has been resolved.
    case resolved

    /// The contact is closed.
    case closed
    
    /// The contact contains some unknown status string.
    case unknown
}

// MARK: - Codable

extension ContactStatus: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        if let eventType = ContactStatus(rawValue: rawValue) {
            self = eventType
        } else {
            LogManager.warning("Unable to decode contact status `.\(rawValue)`")
            
            self = .unknown
        }
    }
}
