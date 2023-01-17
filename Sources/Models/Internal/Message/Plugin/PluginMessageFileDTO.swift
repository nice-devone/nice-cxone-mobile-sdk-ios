import Foundation


struct PluginMessageFileDTO: Codable {
    
    // MARK: - Properties
    
    let id: String
    
    let fileName: String
    
    let url: URL
    
    let mimeType: String
    
    
    // MARK: - Init
    
    init(id: String, fileName: String, url: URL, mimeType: String) {
        self.id = id
        self.fileName = fileName
        self.url = url
        self.mimeType = mimeType
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case fileName = "filename"
        case url
        case mimeType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.fileName = try container.decode(String.self, forKey: .fileName)
        self.mimeType = try container.decode(String.self, forKey: .mimeType)
        
        let urlString = try container.decode(String.self, forKey: .url)
        
        guard let url = URL(string: urlString) else {
            throw DecodingError.typeMismatch(URL.self, .init(codingPath: container.codingPath, debugDescription: "PluginMessageFileSubElement"))
        }
        
        self.url = url
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(ElementType.file.rawValue, forKey: .type)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(url.absoluteString, forKey: .url)
        try container.encode(mimeType, forKey: .mimeType)
    }
}
