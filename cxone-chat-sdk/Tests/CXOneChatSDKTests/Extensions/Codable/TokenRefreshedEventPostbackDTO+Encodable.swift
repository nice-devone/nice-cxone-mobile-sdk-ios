@testable import CXoneChatSDK

extension TokenRefreshedEventPostbackDTO: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var tokenRefreshedContainer = container.nestedContainer(keyedBy: TokenRefreshedKeys.self, forKey: .data)
        
        try container.encode(eventType, forKey: .eventType)
        try tokenRefreshedContainer.encode(accessToken, forKey: .accessToken)
    }
}
