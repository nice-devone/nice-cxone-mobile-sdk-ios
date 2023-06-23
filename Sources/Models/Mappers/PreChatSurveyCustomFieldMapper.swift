import Foundation


enum PreChatSurveyCustomFieldMapper {
    
    static func map(from entity: PreChatSurveyCustomFieldDTO) -> PreChatSurveyCustomField {
        PreChatSurveyCustomField(isRequired: entity.isRequired, type: CustomFieldTypeMapper.map(from: entity.type))
    }
}
