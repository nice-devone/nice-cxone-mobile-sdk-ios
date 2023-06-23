@testable import CXoneChatSDK


extension MessageReadByAgentEventDataDTO: Encodable {
 
    enum CodingKeys: CodingKey {
        case brand
        case message
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(brand, forKey: .brand)
        try container.encode(message, forKey: .message)
    }
}
