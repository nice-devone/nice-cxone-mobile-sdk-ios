@testable import CXoneChatSDK


extension ThreadMetadataLoadedEventPostbackDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case eventType
        case data
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(eventType, forKey: .eventType)
        try container.encodeIfPresent(data, forKey: .data)
    }
}
