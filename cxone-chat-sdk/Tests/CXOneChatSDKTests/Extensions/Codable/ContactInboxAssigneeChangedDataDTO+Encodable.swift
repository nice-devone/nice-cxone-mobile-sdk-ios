@testable import CXoneChatSDK

extension ContactInboxAssigneeChangedDataDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case brand
        case channel
        case `case`
        case inboxAssignee
        case previousInboxAssignee
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(brand, forKey: .brand)
        try container.encode(channel, forKey: .channel)
        try container.encode(self.case, forKey: .case)
        try container.encode(inboxAssignee, forKey: .inboxAssignee)
        try container.encodeIfPresent(previousInboxAssignee, forKey: .previousInboxAssignee)
    }
}
