@testable import CXoneChatSDK

extension ThreadMetadataLoadedEventPostbackDataDTO: Encodable {
 
    enum CodingKeys: CodingKey {
        case ownerAssignee
        case lastMessage
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(ownerAssignee, forKey: .ownerAssignee)
        try container.encodeIfPresent(lastMessage, forKey: .lastMessage)
    }
}
