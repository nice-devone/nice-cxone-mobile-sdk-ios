@testable import CXoneChatSDK


extension MessageCreatedEventDataDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case brand
        case channel
        case `case`
        case thread
        case message
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(brand, forKey: .brand)
        try container.encode(channel, forKey: .channel)
        try container.encode(self.case, forKey: .case)
        try container.encode(thread, forKey: .thread)
        try container.encode(message, forKey: .message)
    }
}
