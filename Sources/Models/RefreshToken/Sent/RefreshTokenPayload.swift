import Foundation

public struct RefreshTokenPayload: Codable {
    public var eventType: EventType
    public var brand: Brand
    public var channel: ChannelIdentifier
    public var consumerIdentity: CustomerIdentity
    var data: RefreshTokenPayloadData
}
