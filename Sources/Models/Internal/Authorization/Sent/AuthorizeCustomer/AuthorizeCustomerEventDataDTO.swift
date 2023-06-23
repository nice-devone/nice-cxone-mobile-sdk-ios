import Foundation


/// Represents info about data of the authorize customer event.
struct AuthorizeCustomerEventDataDTO {
    
    /// The auth code for OAuth.
    let authorizationCode: String?

    /// OAuth code verifier.
    ///
    /// Optional, only needed for OAuth with code verifier.
    let codeVerifier: String?
    
    
    // MARK: - Init
    
    init(authorizationCode: String?, codeVerifier: String?) {
        self.authorizationCode = authorizationCode
        self.codeVerifier = codeVerifier
    }
}


// MARK: - Codable

extension AuthorizeCustomerEventDataDTO: Codable {

    enum CodingKeys: CodingKey {
        case authorization
    }
    
    enum OAuthKeys: CodingKey {
        case authorizationCode
        case codeVerifier
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let oAuthContainer = try? container.nestedContainer(keyedBy: OAuthKeys.self, forKey: .authorization)
        
        self.authorizationCode = try oAuthContainer?.decodeIfPresent(String.self, forKey: .authorizationCode)
        self.codeVerifier = try oAuthContainer?.decodeIfPresent(String.self, forKey: .codeVerifier)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if authorizationCode != nil || authorizationCode != "" || codeVerifier != nil || codeVerifier != "" {
            var oAuthContainer = container.nestedContainer(keyedBy: OAuthKeys.self, forKey: .authorization)
            
            try oAuthContainer.encodeIfPresent(authorizationCode, forKey: .authorizationCode)
            try oAuthContainer.encodeIfPresent(codeVerifier, forKey: .codeVerifier)
        }
    }
}
