import Foundation


struct TokenRefreshedEventPostbackDTO: Codable {
    
    // MARK: - Properties
    
    let eventType: EventType
    
    let accessToken: AccessTokenDTO
    
    
    // MARK: - Init
    
    init(eventType: EventType, accessToken: AccessTokenDTO) {
        self.eventType = eventType
        self.accessToken = accessToken
    }
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case eventType
        case data
    }
    
    enum TokenRefreshedKeys: CodingKey {
        case accessToken
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tokenRefreshedContainer = try container.nestedContainer(keyedBy: TokenRefreshedKeys.self, forKey: .data)
        
        self.eventType = try container.decode(EventType.self, forKey: .eventType)
        self.accessToken = try tokenRefreshedContainer.decode(AccessTokenDTO.self, forKey: .accessToken)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var tokenRefreshedContainer = container.nestedContainer(keyedBy: TokenRefreshedKeys.self, forKey: .data)
        
        try container.encode(eventType, forKey: .eventType)
        try tokenRefreshedContainer.encode(accessToken, forKey: .accessToken)
    }
}
