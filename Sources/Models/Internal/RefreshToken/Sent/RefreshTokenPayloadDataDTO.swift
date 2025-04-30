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

struct RefreshTokenPayloadDataDTO {
    
    // MARK: - Properties
    
    let token: String
}

// MARK: - Codable

extension RefreshTokenPayloadDataDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case accessToken
    }
    
    enum AccessTokenCodingKeys: CodingKey {
        case token
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let accessTokenContainer = try container.nestedContainer(keyedBy: AccessTokenCodingKeys.self, forKey: .accessToken)
        
        self.token = try accessTokenContainer.decode(String.self, forKey: .token)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var accessTokenContainer = container.nestedContainer(keyedBy: AccessTokenCodingKeys.self, forKey: .accessToken)
        
        try accessTokenContainer.encode(token, forKey: .token)
    }
}
