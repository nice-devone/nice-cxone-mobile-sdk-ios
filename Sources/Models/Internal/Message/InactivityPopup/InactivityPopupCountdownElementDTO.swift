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

/// Countdown element within an inactivity popup.
struct InactivityPopupCountdownElementDTO: Equatable {
    
    // MARK: - Properties
    
    /// The unique identifier of the element.
    let id: UUID
    
    /// The start time of the countdown.
    let startedAt: Date
    
    /// The duration of the countdown in seconds.
    let numberOfSeconds: Int
}

// MARK: - Decodable

extension InactivityPopupCountdownElementDTO: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case variables
        #if DEBUG
        case type
        #endif
    }
    enum VariablesKeys: String, CodingKey {
        case startedAt
        case numberOfSeconds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let variablesContainer = try container.nestedContainer(keyedBy: VariablesKeys.self, forKey: .variables)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.startedAt = try variablesContainer.decodeISODate(forKey: .startedAt)
        self.numberOfSeconds = try variablesContainer.decode(Int.self, forKey: .numberOfSeconds)
    }
}

#if DEBUG
// MARK: - Encodable

extension InactivityPopupCountdownElementDTO: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var variablesContainer = container.nestedContainer(keyedBy: VariablesKeys.self, forKey: .variables)
        
        try container.encode(id, forKey: .id)
        try container.encode(ElementType.countdown.rawValue, forKey: .type)
        try variablesContainer.encodeISODate(startedAt, forKey: .startedAt)
        try variablesContainer.encode(numberOfSeconds, forKey: .numberOfSeconds)
    }
}
#endif
