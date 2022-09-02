import Foundation

struct StoreVisitorEventsPayload: Encodable {
    public let eventType: EventType 
    public let brand: Brand
    public let visitor: VisitorIdentifier
    public let destination: Destination
    public let data: StoreVisitorEventData
    public let channel: ChannelIdentifier
}
