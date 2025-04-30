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

/// Represents info data of a recconect customer event.
struct ReconnectCustomerEventDataDTO {

    // MARK: - Properties

    /// Authorization Token.
    let token: String
}

// MARK: - Codable

extension ReconnectCustomerEventDataDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case accessToken
    }
    
    enum TokenKeys: CodingKey {
        case token
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tokenContainer = try container.nestedContainer(keyedBy: TokenKeys.self, forKey: .accessToken)
        
        self.token = try tokenContainer.decode(String.self, forKey: .token)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var tokenContainer = container.nestedContainer(keyedBy: TokenKeys.self, forKey: .accessToken)

        try tokenContainer.encode(token, forKey: .token)
    }
}
