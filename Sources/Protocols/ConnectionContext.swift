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
import Mockable

@Mockable
protocol ConnectionContext: AnyObject {
    
    // periphery:ignore - false positive
    var keychainService: KeychainService { get }
    
    /// The token of the device for push notifications.
    var deviceToken: String? { get set }
    
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
    var destinationId: String { get set }
    
    /// The environment/location to use for CXone.
    var environment: EnvironmentDetails { get set }
    
    /// An object that coordinates a group of related, network data transfer tasks.
    var session: URLSessionProtocol { get }

    var chatState: ChatState { get set }
    
    var visitorId: String? { get set }

    var visitDetails: CurrentVisitDetails? { get set }

    var customer: CustomerIdentityDTO? { get set }
    
    /// The auth token received from authorizing the customer. Only present in OAuth flow.
    var accessToken: AccessTokenDTO? { get set }
    
    func clear()
}

// MARK: - Helpers

extension ConnectionContext {

    var visitId: String? {
        visitDetails?.visitId
    }
    
    /// Enum representing different modes for chat functionality.
    var chatMode: ChatMode {
        if channelConfig.liveChatAvailability.isChannelLiveChat {
            return .liveChat
        } else if channelConfig.settings.hasMultipleThreadsPerEndUser {
            return .multithread
        } else {
            return .singlethread
        }
    }
}
