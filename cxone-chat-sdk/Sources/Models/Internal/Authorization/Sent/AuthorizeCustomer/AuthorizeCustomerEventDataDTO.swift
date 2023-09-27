//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

/// Represents info about data of the authorize customer event.
struct AuthorizeCustomerEventDataDTO {
    
    /// The auth code for OAuth.
    let authorizationCode: String?

    /// OAuth code verifier.
    ///
    /// Optional, only needed for OAuth with code verifier.
    let codeVerifier: String?
    
    // MARK: - Init
    
    init(authorizationCode: String?, codeVerifier: String?) {
        self.authorizationCode = authorizationCode
        self.codeVerifier = codeVerifier
    }
}

// MARK: - Codable

extension AuthorizeCustomerEventDataDTO: Codable {

    enum CodingKeys: CodingKey {
        case authorization
    }
    
    enum OAuthKeys: CodingKey {
        case authorizationCode
        case codeVerifier
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let oAuthContainer = try? container.nestedContainer(keyedBy: OAuthKeys.self, forKey: .authorization)
        
        self.authorizationCode = try oAuthContainer?.decodeIfPresent(String.self, forKey: .authorizationCode)
        self.codeVerifier = try oAuthContainer?.decodeIfPresent(String.self, forKey: .codeVerifier)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if authorizationCode != nil || authorizationCode != "" || codeVerifier != nil || codeVerifier != "" {
            var oAuthContainer = container.nestedContainer(keyedBy: OAuthKeys.self, forKey: .authorization)
            
            try oAuthContainer.encodeIfPresent(authorizationCode, forKey: .authorizationCode)
            try oAuthContainer.encodeIfPresent(codeVerifier, forKey: .codeVerifier)
        }
    }
}
