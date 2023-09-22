@testable import CXoneChatSDK

extension CustomerAuthorizedEventPostbackDataDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case consumerIdentity
        case accessToken
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(consumerIdentity, forKey: .consumerIdentity)
        try container.encodeIfPresent(accessToken, forKey: .accessToken)
    }
}
