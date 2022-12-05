import Foundation


/// Represents info data of a recconect customer event.
struct ReconnectCustomerEventDataDTO: Codable {
    
    // MARK: - Properties
    
    /// Authorization Token.
    let token: String
    
    
    // MARK: - Init
    
    init(token: String) {
        self.token = token
    }
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case accessToken
    }
    
    enum TokenKeys: CodingKey {
        case token
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tokenContainer = try container.nestedContainer(keyedBy: TokenKeys.self, forKey: .accessToken)
        
        self.token = try tokenContainer.decode(String.self, forKey: .token)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var tokenContainer = container.nestedContainer(keyedBy: TokenKeys.self, forKey: .accessToken)
        
        try tokenContainer.encode(token, forKey: .token)
    }
}
