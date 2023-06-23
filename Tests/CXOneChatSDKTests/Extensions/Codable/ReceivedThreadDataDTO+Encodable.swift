@testable import CXoneChatSDK


extension ReceivedThreadDataDTO: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(idOnExternalPlatform, forKey: .idOnExternalPlatform)
        try container.encode(channelId, forKey: .channelId)
        try container.encode(threadName, forKey: .threadName)
        try container.encode(canAddMoreMessages, forKey: .canAddMoreMessages)
    }
}
