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

/// An access token used by the customer for sending messages if OAuth authorization is on for the channel.
struct AccessTokenDTO: Equatable, Expirable {

    // MARK: - Properties

    /// The actual access token value.
    let value: String

    /// The token to refresh the actual access token value.
    let refreshToken: String
    
    /// The number of seconds before the access token becomes invalid.
    let expiresIn: Int

    /// The date at which this access token was created.
    let createdDate: Date
}

// MARK: - Codable

extension AccessTokenDTO: Codable {
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case createdDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.value = try container.decode(String.self, forKey: .accessToken)
        self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
        self.expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(value, forKey: .accessToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(expiresIn, forKey: .expiresIn)
        try container.encode(createdDate, forKey: .createdDate)
    }
}
