import Foundation


enum PluginMessageSubElementDTOType: Codable {
    
    // MARK: - Cases
    
    case text(PluginMessageTextDTO)
    
    case button(PluginMessageButtonDTO)
    
    case file(PluginMessageFileDTO)
    
    case title(PluginMessageTitleDTO)
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let singleContainer = try decoder.singleValueContainer()
        
        switch try container.decode(ElementType.self, forKey: .type) {
        case .button, .iFrameButton:
            self = .button(try singleContainer.decode(PluginMessageButtonDTO.self))
        case .text:
            self = .text(try singleContainer.decode(PluginMessageTextDTO.self))
        case .file:
            self = .file(try singleContainer.decode(PluginMessageFileDTO.self))
        case .title:
            self = .title(try singleContainer.decode(PluginMessageTitleDTO.self))
        default:
            throw CXoneChatError.invalidData
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .text(let entity):
            try container.encode(entity)
        case .button(let entity):
            try container.encode(entity)
        case .file(let entity):
            try container.encode(entity)
        case .title(let entity):
            try container.encode(entity)
        }
    }
}
