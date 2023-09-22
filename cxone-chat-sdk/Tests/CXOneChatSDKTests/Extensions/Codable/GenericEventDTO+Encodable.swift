@testable import CXoneChatSDK

extension GenericEventDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case eventType
        case postback
        case error
        case internalServerError
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(eventType, forKey: .eventType)
        try container.encodeIfPresent(postback, forKey: .error)
        try container.encodeIfPresent(internalServerError, forKey: .postback)
        try container.encodeIfPresent(error, forKey: .internalServerError)
    }
}
