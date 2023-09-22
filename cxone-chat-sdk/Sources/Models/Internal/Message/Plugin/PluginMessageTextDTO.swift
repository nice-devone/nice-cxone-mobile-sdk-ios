import Foundation

struct PluginMessageTextDTO {
    
    // MARK: - Properties
    
    let id: String
    
    let text: String
    
    let mimeType: String?
    
    // MARK: - Init
    
    init(id: String, text: String, mimeType: String?) {
        self.id = id
        self.text = text
        self.mimeType = mimeType
    }
}

// MARK: - Codable

extension PluginMessageTextDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case id
        case type
        case text
        case mimeType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(ElementType.text.rawValue, forKey: .type)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(mimeType, forKey: .mimeType)
    }
}
