import Foundation

/// The various options for how a channel is configured.
struct ChannelConfigurationDTO {
    
    // MARK: - Properties
    
    let settings: ChannelSettingsDTO

    let isAuthorizationEnabled: Bool
    
    let prechatSurvey: PreChatSurveyDTO?
    
    let contactCustomFieldDefinitions: [CustomFieldDTOType]

    let customerCustomFieldDefinitions: [CustomFieldDTOType]
    
    // MARK: - Init
    
    init(
        settings: ChannelSettingsDTO,
        isAuthorizationEnabled: Bool,
        prechatSurvey: PreChatSurveyDTO?,
        contactCustomFieldDefinitions: [CustomFieldDTOType],
        customerCustomFieldDefinitions: [CustomFieldDTOType]
    ) {
        self.settings = settings
        self.isAuthorizationEnabled = isAuthorizationEnabled
        self.prechatSurvey = prechatSurvey
        self.contactCustomFieldDefinitions = contactCustomFieldDefinitions
        self.customerCustomFieldDefinitions = customerCustomFieldDefinitions
    }
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
