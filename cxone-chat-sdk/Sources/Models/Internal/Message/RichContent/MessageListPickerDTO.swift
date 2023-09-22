import Foundation

struct MessageListPickerDTO: Equatable {
    
    let title: String
    
    let text: String
    
    let elements: [MessageSubElementDTOType]
}

// MARK: - Codable

extension MessageListPickerDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case title
        case text
        case actions
    }

    enum TitleKeys: CodingKey {
        case content
    }
    
    enum TextKeys: CodingKey {
        case content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let titleContainer = try container.nestedContainer(keyedBy: TitleKeys.self, forKey: .title)
        let textContainer = try container.nestedContainer(keyedBy: TextKeys.self, forKey: .text)
        
        self.title = try titleContainer.decode(String.self, forKey: .content)
        self.text = try textContainer.decode(String.self, forKey: .content)
        self.elements = try container.decode([MessageSubElementDTOType].self, forKey: .actions)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var titleContainer = container.nestedContainer(keyedBy: TitleKeys.self, forKey: .title)
        var textContainer = container.nestedContainer(keyedBy: TextKeys.self, forKey: .text)
        
        try titleContainer.encode(title, forKey: .content)
        try textContainer.encode(text, forKey: .content)
        try container.encode(elements, forKey: .actions)
    }
}
