import Foundation

struct ExecuteTriggerEventPayload: Codable {
    public let eventType: EventType
    public let brand: Brand
    public let channel: ChannelIdentifier
    public let consumerIdentity: CustomerIdentity
    public let destination: Destination
    public let visitor: VisitorIdentifier
    public let data: TriggerData
}
