import Foundation


struct MessageReplyButtonDTO: Equatable {
    
    let text: String
    
    let postback: String?
    
    let description: String?
    
    let iconName: String?
    
    let iconUrl: URL?
    
    let iconMimeType: String?
}


// MARK: - Codable

extension MessageReplyButtonDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case type
        case icon
        case text
        case description
        case postback
    }
    
    enum IconKeys: CodingKey {
        case fileName
        case url
        case mimeType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard try container.decode(ElementType.self, forKey: .type) == .replyButton else {
            throw DecodingError.typeMismatch(
                ElementType.self,
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "MessageReplyButtonDTO")
            )
        }
        
        self.text = try container.decode(String.self, forKey: .text)
        self.postback = try container.decodeIfPresent(String.self, forKey: .postback)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        
        if let iconContainer = try? container.nestedContainer(keyedBy: IconKeys.self, forKey: .icon) {
            self.iconName = try iconContainer.decode(String.self, forKey: .fileName)
            self.iconUrl = try iconContainer.decode(URL.self, forKey: .url)
            self.iconMimeType = try iconContainer.decode(String.self, forKey: .mimeType)
        } else {
            self.iconName = nil
            self.iconUrl = nil
            self.iconMimeType = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(ElementType.replyButton.rawValue, forKey: .type)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(postback, forKey: .postback)
        try container.encodeIfPresent(description, forKey: .description)
        
        if let iconUrl {
            var iconContainer = container.nestedContainer(keyedBy: IconKeys.self, forKey: .icon)
            
            try iconContainer.encode(iconName, forKey: .fileName)
            try iconContainer.encode(iconUrl, forKey: .url)
            try iconContainer.encode(iconMimeType, forKey: .mimeType)
        }
        
    }
}
