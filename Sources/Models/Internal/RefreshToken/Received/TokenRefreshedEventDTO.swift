import Foundation


/// Event received when a token has been successfully refreshed.
struct TokenRefreshedEventDTO: Decodable {
    
    let eventId: UUID
    
    let postback: TokenRefreshedEventPostbackDTO
}
