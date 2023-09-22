@testable import CXoneChatSDK

extension MoreMessagesLoadedEventPostbackDataDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case messages
        case scrollToken
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(messages, forKey: .messages)
        try container.encodeIfPresent(scrollToken, forKey: .scrollToken)
    }
}
