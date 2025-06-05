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

@testable import CXoneChatSDK
import Foundation

extension AuthorizeCustomerEventDataDTO: Swift.Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let oAuthContainer = try? container.nestedContainer(keyedBy: OAuthKeys.self, forKey: .authorization)
        
        self.init(
            authorizationCode: try oAuthContainer?.decodeIfPresent(String.self, forKey: .authorizationCode),
            codeVerifier: try oAuthContainer?.decodeIfPresent(String.self, forKey: .codeVerifier),
            disableChannelInfo: try container.decode(Bool.self, forKey: .disableChannelInfo),
            sdkPlatform: try container.decode(String.self, forKey: .sdkPlatform),
            sdkVersion: try container.decode(String.self, forKey: .sdkVersion)
        )
    }
}
