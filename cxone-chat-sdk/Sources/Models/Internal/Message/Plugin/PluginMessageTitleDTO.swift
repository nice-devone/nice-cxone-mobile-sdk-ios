import Foundation

struct PluginMessageTitleDTO {
    
    // MARK: - Properties
    
    let id: String
    
    let text: String
    
    // MARK: - Init
    
    init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}

// MARK: - Codable

extension PluginMessageTitleDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case id
        case type
        case text
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(ElementType.title.rawValue, forKey: .type)
        try container.encode(text, forKey: .text)
    }
}
