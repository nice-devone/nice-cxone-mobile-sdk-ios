import Foundation

/// Event received when a token has been successfully refreshed.
struct TokenRefreshedEvent: Codable {
    public var eventId: UUID
    public var postback: TokenRefreshedEventPostback
}
