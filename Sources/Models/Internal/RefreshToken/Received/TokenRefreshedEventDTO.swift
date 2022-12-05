import Foundation


/// Event received when a token has been successfully refreshed.
struct TokenRefreshedEventDTO: Codable {
    
    let eventId: UUID
    
    let postback: TokenRefreshedEventPostbackDTO
}
