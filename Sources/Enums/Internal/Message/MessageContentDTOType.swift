import Foundation


enum MessageContentDTOType: Codable {
    
    // MARK: - Cases
    
    case text(String)
    
    case plugin(MessagePayloadDTO)
    
    case unknown
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case type
        case payload
    }
    
    enum PayloadKeys: CodingKey {
        case text
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        switch try container.decode(String.self, forKey: .type) {
        case "TEXT":
            let payloadContainer = try container.nestedContainer(keyedBy: PayloadKeys.self, forKey: .payload)
            
            self = .text(try payloadContainer.decode(String.self, forKey: .text))
        case "PLUGIN":
            self = .plugin(try container.decode(MessagePayloadDTO.self, forKey: .payload))
        default:
            self = .unknown
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var payloadContainer = container.nestedContainer(keyedBy: PayloadKeys.self, forKey: .payload)
        
        switch self {
        case .text(let text):
            try container.encode("TEXT", forKey: .type)
            try payloadContainer.encode(text, forKey: .text)
        case .plugin(let plugin):
            try container.encode("PLUGIN", forKey: .type)
            try container.encode(plugin, forKey: .payload)
        case .unknown:
            break
        }
    }
}
