import Foundation


struct PreChatSurveyCustomFieldDTO {
    
    let isRequired: Bool
    
    let type: CustomFieldDTOType
}


// MARK: - Decodable

extension PreChatSurveyCustomFieldDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case isRequired
        case definition
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.isRequired = try container.decode(Bool.self, forKey: .isRequired)
        self.type = try container.decode(CustomFieldDTOType.self, forKey: .definition)
    }
}
