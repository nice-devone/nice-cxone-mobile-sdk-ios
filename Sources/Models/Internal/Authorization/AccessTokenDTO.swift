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

/// An access token used by the customer for sending messages if OAuth authorization is on for the channel.
struct AccessTokenDTO: Equatable {

    // MARK: - Properties

    /// The actual token value.
    let token: String

    /// The number of seconds before the access token becomes invalid.
    let expiresIn: Int

    /// The date at which this access token was created.
    let currentDate: Date
    
    // MARK: - Methods
    
    func isExpired(currentDate: Date) -> Bool {
        let date = Calendar.current.dateComponents([.second], from: currentDate, to: currentDate)
        
        return date.second ?? 0 > (expiresIn - 180)
    }
}

// MARK: - Codable

extension AccessTokenDTO: Codable {
    
    enum CodingKeys: String, CodingKey {
        case token
        case currentDate
        case expiresIn
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.token = try container.decode(String.self, forKey: .token)
        self.expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        self.currentDate = try container.decodeIfPresent(Date.self, forKey: .currentDate) ?? Date()
    }
}
