import Foundation


enum MessageSubElementDTOType: Equatable {
    
    case replyButton(MessageReplyButtonDTO)
}


// MARK: - Codable

extension MessageSubElementDTOType: Codable {
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let singleContainer = try decoder.singleValueContainer()
        
        switch try container.decode(ElementType.self, forKey: .type) {
        case .replyButton:
            self = .replyButton(try singleContainer.decode(MessageReplyButtonDTO.self))
        default:
            throw DecodingError.valueNotFound(MessageSubElementDTOType.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "type"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .replyButton(let entity):
            try container.encode(entity)
        }
    }
}
