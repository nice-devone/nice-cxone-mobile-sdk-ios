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

struct TokenRefreshedEventPostbackDTO: Equatable {
    
    // MARK: - Properties
    
    let eventType: EventType
    
    let accessToken: AccessTokenDTO
}

// MARK: - Decodable

extension TokenRefreshedEventPostbackDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case eventType
        case data
    }
    
    enum TokenRefreshedKeys: CodingKey {
        case accessToken
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tokenRefreshedContainer = try container.nestedContainer(keyedBy: TokenRefreshedKeys.self, forKey: .data)
        
        self.eventType = try container.decode(EventType.self, forKey: .eventType)
        self.accessToken = try tokenRefreshedContainer.decode(AccessTokenDTO.self, forKey: .accessToken)
    }
}
