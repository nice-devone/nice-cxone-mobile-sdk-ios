@testable import CXoneChatSDK


extension MessageDTO: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(idOnExternalPlatform, forKey: .idOnExternalPlatform)
        try container.encode(threadIdOnExternalPlatform, forKey: .threadIdOnExternalPlatform)
        try container.encodeISODate(createdAt, forKey: .createdAt)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(direction, forKey: .direction)
        try container.encode(contentType, forKey: .messageContent)
        try container.encode(userStatistics, forKey: .userStatistics)
        try container.encodeIfPresent(authorUser, forKey: .authorUser)
        try container.encodeIfPresent(authorEndUserIdentity, forKey: .authorEndUserIdentity)
    }
}
