import Foundation


struct PluginMessageCustomDTO {
    
    // MARK: - Properties
    
    let id: String
    
    let text: String?
    
    let variables: [String: CodableObject]
    
    
    // MARK: - Init
    
    init(id: String, text: String?, variables: [String: CodableObject]) {
        self.id = id
        self.text = text
        self.variables = variables
    }
}


// MARK: - Codable

extension PluginMessageCustomDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case id
        case text
        case type
        case variables
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.variables = try container.decode([String: CodableObject].self, forKey: .variables)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(ElementType.custom.rawValue, forKey: .type)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encode(variables, forKey: .variables)
    }
}
