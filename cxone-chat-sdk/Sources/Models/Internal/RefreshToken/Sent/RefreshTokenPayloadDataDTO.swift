import Foundation

struct RefreshTokenPayloadDataDTO {
    
    // MARK: - Properties
    
    let token: String
    
    // MARK: - Init
    
    init(token: String) {
        self.token = token
    }
}

// MARK: - Codable

extension RefreshTokenPayloadDataDTO: Codable {
    
    enum CodingKeys: CodingKey {
        case accessToken
    }
    
    enum AccessTokenCodingKeys: CodingKey {
        case token
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let accessTokenContainer = try container.nestedContainer(keyedBy: AccessTokenCodingKeys.self, forKey: .accessToken)
        
        self.token = try accessTokenContainer.decode(String.self, forKey: .token)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var accessTokenContainer = container.nestedContainer(keyedBy: AccessTokenCodingKeys.self, forKey: .accessToken)
        
        try accessTokenContainer.encode(token, forKey: .token)
    }
}
