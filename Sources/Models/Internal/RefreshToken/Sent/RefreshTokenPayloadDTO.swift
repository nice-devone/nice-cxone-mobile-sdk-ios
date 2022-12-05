import Foundation


/// Represents payload of the refresh token.
struct RefreshTokenPayloadDTO: Codable {
    
    /// The type of the event.
    let eventType: EventType

    /// The unique id of the brand.
    let brand: BrandDTO

    /// The unique identifier of the channel.
    let channel: ChannelIdentifierDTO

    /// The information about a customer identity to be sent on events.
    let consumerIdentity: CustomerIdentityDTO

    let data: RefreshTokenPayloadDataDTO
}
