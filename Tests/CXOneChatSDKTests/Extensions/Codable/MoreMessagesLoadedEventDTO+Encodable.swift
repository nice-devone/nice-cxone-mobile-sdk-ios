@testable import CXoneChatSDK


extension MoreMessagesLoadedEventDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case eventId
        case postback
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(eventId, forKey: .eventId)
        try container.encodeIfPresent(postback, forKey: .postback)
    }
}
