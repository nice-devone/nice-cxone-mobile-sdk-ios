import Foundation

/// A token used to refresh the access token.
struct RefreshToken: Codable {
    public var action: EventAction
    public var eventId: UUID
    public var payload: RefreshTokenPayload
}
