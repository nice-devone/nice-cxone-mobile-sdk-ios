import Foundation

public struct AuthorizeCustomerOAuth: Codable {
    /// The auth code for OAuth.
    public var authorizationCode: String?
    
    /// Optional, only needed for OAuth with code verifier.
    public var codeVerifier: String?
}
