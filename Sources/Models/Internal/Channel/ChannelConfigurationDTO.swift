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

/// The various options for how a channel is configured.
struct ChannelConfigurationDTO {
    
    // MARK: - Properties
    
    let settings: ChannelSettingsDTO

    let isAuthorizationEnabled: Bool
    
    let prechatSurvey: PreChatSurveyDTO?
    
    let contactCustomFieldDefinitions: [CustomFieldDTOType]

    let customerCustomFieldDefinitions: [CustomFieldDTOType]
}

// MARK: - Decodable

extension ChannelConfigurationDTO: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case settings
        case isAuthorizationEnabled
        case preContactForm
        case customerCustomFields = "endUserCustomFields"
        case contactCustomFields = "caseCustomFields"
    }
    
    enum PreContactFormCodingKeys: CodingKey {
        case name
        case customFields
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.settings = try container.decode(ChannelSettingsDTO.self, forKey: .settings)
        self.isAuthorizationEnabled = try container.decode(Bool.self, forKey: .isAuthorizationEnabled)
        self.customerCustomFieldDefinitions = try container.decodeIfPresent([CustomFieldDTOType].self, forKey: .customerCustomFields) ?? []
        self.contactCustomFieldDefinitions = try container.decodeIfPresent([CustomFieldDTOType].self, forKey: .contactCustomFields) ?? []
        
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
