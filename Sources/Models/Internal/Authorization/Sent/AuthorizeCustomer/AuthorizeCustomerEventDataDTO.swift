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

/// Represents info about data of the authorize customer event.
struct AuthorizeCustomerEventDataDTO {
    
    // MARK: - Properties
    
    /// The auth code for OAuth.
    let authorizationCode: String?

    /// OAuth code verifier.
    ///
    /// Optional, only needed for OAuth with code verifier.
    let codeVerifier: String?
    
    /// Flag to disable partial channel info properties.
    ///
    /// Response to this event, `CustomerAuthorizedEventDTO` is able to return some additional data from channel info but we are not using it.
    let disableChannelInfo: Bool
    
    /// Platform identifier.
    let sdkPlatform: String
    
    /// The SDK version.
    let sdkVersion: String
    
    // MARK: - Init
    
    init(
        authorizationCode: String?,
        codeVerifier: String?,
        disableChannelInfo: Bool = true,
        sdkPlatform: String = "ios",
        sdkVersion: String = CXoneChatSDKModule.version
    ) {
        self.authorizationCode = authorizationCode
        self.codeVerifier = codeVerifier
        self.disableChannelInfo = disableChannelInfo
        self.sdkPlatform = sdkPlatform
        self.sdkVersion = sdkVersion
    }
}

// MARK: - Encodable

extension AuthorizeCustomerEventDataDTO: Encodable {

    enum CodingKeys: CodingKey {
        case authorization
        case disableChannelInfo
        case sdkPlatform
        case sdkVersion
    }
    
    enum OAuthKeys: CodingKey {
        case authorizationCode
        case codeVerifier
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(disableChannelInfo, forKey: .disableChannelInfo)
        try container.encode(sdkPlatform, forKey: .sdkPlatform)
        try container.encode(sdkVersion, forKey: .sdkVersion)
        
        if authorizationCode != "" || codeVerifier != "" {
            var oAuthContainer = container.nestedContainer(keyedBy: OAuthKeys.self, forKey: .authorization)
            
            try oAuthContainer.encodeIfPresent(authorizationCode, forKey: .authorizationCode)
            try oAuthContainer.encodeIfPresent(codeVerifier, forKey: .codeVerifier)
        }
    }
}
