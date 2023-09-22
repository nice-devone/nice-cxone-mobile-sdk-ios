@testable import CXoneChatSDK

extension MessageCreatedEventDTO: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(eventId, forKey: .eventId)
        try container.encode(eventObject, forKey: .eventObject)
        try container.encode(eventType, forKey: .eventType)
        try container.encodeISODate(createdAt, forKey: .createdAt)
        try container.encode(data, forKey: .data)
    }
}
