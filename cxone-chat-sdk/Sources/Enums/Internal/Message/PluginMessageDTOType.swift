import Foundation

enum PluginMessageDTOType {
    
    case gallery([PluginMessageDTOType])
    
    case menu(PluginMessageMenuDTO)
    
    case textAndButtons(PluginMessageTextAndButtonsDTO)
    
    case quickReplies(PluginMessageQuickRepliesDTO)
    
    case satisfactionSurvey(PluginMessageSatisfactionSurveyDTO)
    
    case custom(PluginMessageCustomDTO)
    
    case subElements([PluginMessageSubElementDTOType])
}

// MARK: - Codable

extension PluginMessageDTOType: Codable {
    
    init(from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        
        if let object = try? singleValueContainer.decode(PluginMessageTextAndButtonsDTO.self) {
            self = .textAndButtons(object)
        } else if let object = try? singleValueContainer.decode(PluginMessageQuickRepliesDTO.self) {
            self = .quickReplies(object)
        } else if let object = try? singleValueContainer.decode(PluginMessageMenuDTO.self) {
            self = .menu(object)
        } else if let object = try? singleValueContainer.decode(PluginMessageSatisfactionSurveyDTO.self) {
            self = .satisfactionSurvey(object)
        } else if let object = try? singleValueContainer.decode(PluginMessageCustomDTO.self) {
            self = .custom(object)
        } else if let objects = try? singleValueContainer.decode([PluginMessageSubElementDTOType].self) {
            self = .subElements(objects)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: singleValueContainer.codingPath, debugDescription: "PluginMessageType"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var singleContainer = encoder.singleValueContainer()
        
        switch self {
        case .gallery(let entities):
            try singleContainer.encode(entities)
        case .quickReplies(let entity):
            try singleContainer.encode(entity)
        case .textAndButtons(let entity):
            try singleContainer.encode(entity)
        case .menu(let entity):
            try singleContainer.encode(entity)
        case.satisfactionSurvey(let entity):
            try singleContainer.encode(entity)
        case .custom(let entity):
            try singleContainer.encode(entity)
        case .subElements(let entities):
            try singleContainer.encode(entities)
        }
    }
}
