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
import KeychainSwift

protocol ConnectionContext {
    
    var keychainSwift: KeychainSwift { get set }
    
    /// The token of the device for push notifications.
    var deviceToken: String { get set }
    
    /// The code used for login with OAuth.
    var authorizationCode: String { get set }
    
    /// The code verifier used for OAuth (if PKCE is required).
    var codeVerifier: String { get set }
    
    /// The unique contact id for the last loaded thread.
    var contactId: String? { get set }
    
    /// The current channel configuration for currently connected CXone session.
    var channelConfig: ChannelConfigurationDTO { get set }
    
    /// The id of the brand for the chat.
    var brandId: Int { get set }
    
    /// The id of the channel for the chat.
    var channelId: String { get set }
    
    /// The id generated for the destination.
    var destinationId: UUID { get set }
    
    /// The environment/location to use for CXone.
    var environment: EnvironmentDetails { get set }
    
    /// An object that coordinates a group of related, network data transfer tasks.
    var session: URLSession { get }
    
    var isConnected: Bool { get }
    
    var visitorId: UUID? { get set }

    var visitDetails: CurrentVisitDetails? { get set }

    var customer: CustomerIdentityDTO? { get set }
    
    /// The auth token received from authorizing the customer. Only present in OAuth flow.
    var accessToken: AccessTokenDTO? { get }
    
    func setAccessToken(_ token: AccessTokenDTO?) throws
    
    func clear()
}

extension ConnectionContext {
    var visitId: UUID? {
        visitDetails?.visitId
    }
}

struct CurrentVisitDetails: Codable, Equatable {
    let visitId: UUID
    let expires: Date
}
