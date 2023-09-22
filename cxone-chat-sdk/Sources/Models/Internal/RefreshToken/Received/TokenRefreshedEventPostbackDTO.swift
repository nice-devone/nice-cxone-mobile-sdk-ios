import Foundation

struct TokenRefreshedEventPostbackDTO {
    
    // MARK: - Properties
    
    let eventType: EventType
    
    let accessToken: AccessTokenDTO
    
    // MARK: - Init
    
    init(eventType: EventType, accessToken: AccessTokenDTO) {
        self.eventType = eventType
        self.accessToken = accessToken
    }
}

// MARK: - Decodable

extension TokenRefreshedEventPostbackDTO: Decodable {
    
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
}
