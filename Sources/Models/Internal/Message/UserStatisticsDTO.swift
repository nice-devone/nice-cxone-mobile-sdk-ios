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

/// Represents statistics about the user.
struct UserStatisticsDTO: Equatable {
    
    // MARK: - Properties
    
    /// The date at which the message was seen. Will be null if not yet seen.
    let seenAt: Date?
    
    /// The date at which the message was read. Will be null if not yet read.
    let readAt: Date?
}

// MARK: - Codable

extension UserStatisticsDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case seenAt
        case readAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.seenAt = try container.decodeISODateIfPresent(forKey: .seenAt)
        self.readAt = try container.decodeISODateIfPresent(forKey: .readAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeISODateIfPresent(seenAt, forKey: .seenAt)
        try container.encodeISODateIfPresent(readAt, forKey: .readAt)
    }
}
