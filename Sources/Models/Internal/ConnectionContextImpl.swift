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

class ConnectionContextImpl: ConnectionContext {

    // MARK: - Properties
    
    let keychainService: KeychainService
    
    /// The token of the device for push notifications.
    var deviceToken: String?

    /// The code used for login with OAuth.
    var authorizationCode: String
    
    /// The code verifier used for OAuth (if PKCE is required).
    var codeVerifier: String
    
    /// The unique contact id for the last loaded thread.
    var contactId: String?
    
    /// The current channel configuration for currently connected CXone session.
    var channelConfig: ChannelConfigurationDTO
    
    /// The id of the brand for the chat.
    var brandId: Int
    
    /// The id of the channel for the chat.
    var channelId: String
    
    /// The id generated for the destination.
    var destinationId: UUID
    
    /// The environment/location to use for CXone.
    var environment: EnvironmentDetails
    
    /// An object that coordinates a group of related, network data transfer tasks.
    let session: URLSessionProtocol
    
    /// Current chat state of the SDK
    ///
    /// The state defines whether it is necessary to set up the SDK, connect to the CXone services or start communication with an agent.
    var chatState: ChatState = .initial
    
    var visitorId: UUID? {
        get { UserDefaultsService.shared.get(UUID.self, for: .visitorId) }
        set { UserDefaultsService.shared.set(newValue, for: .visitorId) }
    }

    var visitDetailsStore: CurrentVisitDetails?
    var visitDetails: CurrentVisitDetails? {
        get {
            if visitDetailsStore == nil {
                visitDetailsStore = UserDefaultsService.shared.get(CurrentVisitDetails.self, for: .visitDetails)
            }

            return visitDetailsStore
        }
        set {
            if visitDetailsStore != newValue {
                visitDetailsStore = newValue
                
                UserDefaultsService.shared.set(newValue, for: .visitDetails)
            }
        }
    }

    var customer: CustomerIdentityDTO? {
        get { keychainService.get(CustomerIdentityDTO.self, for: .customer) }
        set { keychainService.set(newValue, for: .customer) }
    }
    
    /// The auth token received from authorizing the customer. Only present in OAuth flow.
    var accessToken: AccessTokenDTO? {
        get { keychainService.get(AccessTokenDTO.self, for: .accessToken) }
        set { keychainService.set(newValue, for: .accessToken) }
    }

    // MARK: - Init
    
    init(
        keychainService: KeychainService,
        session: URLSession? = nil,
        environment: EnvironmentDetails = CustomEnvironment(chatURL: "", socketURL: "", loggerURL: ""),
        brandId: Int = .min,
        deviceToken: String? = nil,
        authorizationCode: String = "",
        codeVerifier: String = "",
        contactId: String? = nil,
        channelConfig: ChannelConfigurationDTO = ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(
                hasMultipleThreadsPerEndUser: false,
                isProactiveChatEnabled: false,
                fileRestrictions: FileRestrictionsDTO(
                    allowedFileSize: 40,
                    allowedFileTypes: [],
                    isAttachmentsEnabled: false
                ),
                features: [:]
            ),
            isAuthorizationEnabled: false,
            prechatSurvey: nil,
            liveChatAvailability: CurrentLiveChatAvailability(isChannelLiveChat: false, isOnline: false, expires: .distantPast)
        ),
        channelId: String = "",
        destinationId: UUID = UUID(),
        visitDetailsStore: CurrentVisitDetails? = nil
    ) {
        self.keychainService = keychainService
        self.deviceToken = deviceToken
        self.authorizationCode = authorizationCode
        self.codeVerifier = codeVerifier
        self.contactId = contactId
        self.channelConfig = channelConfig
        self.brandId = brandId
        self.channelId = channelId
        self.destinationId = destinationId
        self.environment = environment
        #if DEBUG
        self.session = session ?? URLSession.lenient()
        #else
        self.session = session ?? URLSession.default
        #endif
        self.visitDetailsStore = visitDetailsStore
    }

    // MARK: - Methods
    
    func clear() {
        keychainService.purge()
        UserDefaultsService.purge()
    }
}

// MARK: - Helpers

private extension URLSession {
    
    // periphery:ignore - False positive, used in a non DEBUG configuration
    static var `default`: URLSession {
        let configuration = URLSessionConfiguration.default
        
        return URLSession(configuration: configuration)
    }
}
