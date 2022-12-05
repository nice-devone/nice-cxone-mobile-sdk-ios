import Foundation


/// A token used to refresh the access token.
struct RefreshTokenDTO: Codable {
    
    let action: EventActionType

    let eventId: UUID

    let payload: RefreshTokenPayloadDTO
}
