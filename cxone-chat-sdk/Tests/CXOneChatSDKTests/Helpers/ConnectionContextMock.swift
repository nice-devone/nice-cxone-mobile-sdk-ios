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
@testable import CXoneChatSDK
import KeychainSwift

class ConnectionContextMock: ConnectionContext {
    var keychainSwift: KeychainSwift = KeychainSwiftMock()
    
    /// The token of the device for push notifications.
    var deviceToken = ""
    
    /// The code used for login with OAuth.
    var authorizationCode = ""
    
    /// The code verifier used for OAuth (if PKCE is required).
    var codeVerifier = ""
    
    /// The unique contact id for the last loaded thread.
    var contactId: String?
    
    /// The current channel configuration for currently connected CXone session.
    var channelConfig = ChannelConfigurationDTO(
        settings: ChannelSettingsDTO(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: false),
        isAuthorizationEnabled: false,
        prechatSurvey: nil,
        contactCustomFieldDefinitions: [],
        customerCustomFieldDefinitions: []
    )
    
    /// The id of the brand for the chat.
    var brandId: Int = .min
    
    /// The id of the channel for the chat.
    var channelId = ""
    
    /// The id generated for the destination.
    var destinationId = UUID()
    
    /// The environment/location to use for CXone.
    var environment: EnvironmentDetails = CustomEnvironment(chatURL: "", socketURL: "")
    
    /// An object that coordinates a group of related, network data transfer tasks.
    let session: URLSession
    
    var isConnected: Bool { channelId != "" && brandId != .min && visitorId != nil && _customer != nil }
    
    var visitorId: UUID?
    
    var _customer: CustomerIdentityDTO?
    var customer: CustomerIdentityDTO? {
        get {
            guard UserDefaults.standard.bool(forKey: "cxOneHasRun") else {
                UserDefaults.standard.set(true, forKey: "cxOneHasRun")
                return nil
            }
            
            return _customer
        }
        set { _customer = newValue }
    }
    
    var visitDetails: CXoneChatSDK.CurrentVisitDetails?

    /// The auth token received from authorizing the customer. Only present in OAuth flow.
    var accessToken: AccessTokenDTO?

    init(session: URLSession = .shared) {
        self.session = session
    }

    func setAccessToken(_ token: AccessTokenDTO?) throws { }
    
    func clear() { }
}
