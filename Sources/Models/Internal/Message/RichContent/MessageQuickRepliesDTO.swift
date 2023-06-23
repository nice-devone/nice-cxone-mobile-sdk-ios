import Foundation


struct MessageQuickRepliesDTO: Equatable {
    
    let title: String
    
    let buttons: [MessageReplyButtonDTO]
}


// MARK: - Codable

extension MessageQuickRepliesDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case text
        case actions
    }

    enum TextKeys: CodingKey {
        case content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let textContainer = try container.nestedContainer(keyedBy: TextKeys.self, forKey: .text)
        
        self.title = try textContainer.decode(String.self, forKey: .content)
        self.buttons = try container.decode([MessageReplyButtonDTO].self, forKey: .actions)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var textContainer = container.nestedContainer(keyedBy: TextKeys.self, forKey: .text)
        
        try textContainer.encode(title, forKey: .content)
        try container.encode(buttons, forKey: .actions)
    }
}
