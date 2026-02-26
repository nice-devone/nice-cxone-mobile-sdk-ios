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

/// The various options for how a channel is configured.
struct ChannelConfigurationDTO {
    
    // MARK: - Properties
    
    let settings: ChannelSettingsDTO

    let isAuthorizationEnabled: Bool
    
    let prechatSurvey: PreChatSurveyDTO?
    
    let liveChatAvailability: CurrentLiveChatAvailability
    
    /// The authentication type for this channel.
    ///
    /// Determines which authentication method to use when connecting to this channel.
    /// Defaults to anonymous if not specified by the backend.
    let authenticationType: AuthenticationType
}

// MARK: - Methods

extension ChannelConfigurationDTO {
 
    func copy(
        settings: ChannelSettingsDTO? = nil,
        isAuthorizationEnabled: Bool? = nil,
        prechatSurvey: PreChatSurveyDTO? = nil,
        liveChatAvailability: CurrentLiveChatAvailability? = nil,
        authenticationType: AuthenticationType? = nil
    ) -> ChannelConfigurationDTO {
        ChannelConfigurationDTO(
            settings: settings ?? self.settings,
            isAuthorizationEnabled: isAuthorizationEnabled ?? self.isAuthorizationEnabled,
            prechatSurvey: prechatSurvey ?? self.prechatSurvey,
            liveChatAvailability: liveChatAvailability ?? self.liveChatAvailability,
            authenticationType: authenticationType ?? self.authenticationType
        )
    }
}

// MARK: - Decodable

extension ChannelConfigurationDTO: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case settings
        case isAuthorizationEnabled
        case preContactForm
        case isLiveChat
        case isSecuredCookieEnabled
    }
    
    enum PreContactFormCodingKeys: CodingKey {
        case name
        case customFields
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.settings = try container.decode(ChannelSettingsDTO.self, forKey: .settings)
        self.isAuthorizationEnabled = try container.decode(Bool.self, forKey: .isAuthorizationEnabled)
        self.liveChatAvailability = CurrentLiveChatAvailability(
            isChannelLiveChat: try container.decode(Bool.self, forKey: .isLiveChat),
            isOnline: false,
            expires: .distantPast
        )
        
        // Derive authentication type from backend boolean flags
        // Backend sends isSecuredCookieEnabled and isAuthorizationEnabled to indicate auth type
        let isSecuredCookieEnabled = try container.decodeIfPresent(Bool.self, forKey: .isSecuredCookieEnabled)

        if isSecuredCookieEnabled == true {
            self.authenticationType = .securedCookie
        } else if self.isAuthorizationEnabled {
            self.authenticationType = .thirdPartyOAuth
        } else {
            self.authenticationType = .anonymous
        }
        
        if let prechatFormContainer = try? container.nestedContainer(keyedBy: PreContactFormCodingKeys.self, forKey: .preContactForm) {
            self.prechatSurvey = PreChatSurveyDTO(
                name: try prechatFormContainer.decode(String.self, forKey: .name),
                customFields: try prechatFormContainer.decode([PreChatSurveyCustomFieldDTO].self, forKey: .customFields)
            )
        } else {
            self.prechatSurvey = nil
        }
    }
}
