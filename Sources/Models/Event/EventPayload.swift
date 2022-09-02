import Foundation

/// The details about the event to be sent.
struct EventPayload: Encodable {
    
    /// The brand for which the event applies.
    private var brand: Brand
    
    /// The channel for which the event applies.
    private var channel: ChannelIdentifier
    
    /// The identity of the customer that is sending the event.
    private var consumerIdentity: CustomerIdentity // Prop name must stay the same
    
    /// The visitor to reconnect. Only used for the ReconnectCustomer event.
    internal var visitor: VisitorIdentifier?
    
    /// The type of event to be sent.
    private var eventType: EventType
    
    /// The data to be sent for the event.
    var data: EventData?
    
    init(brandId: Int, channelId: String, customerIdentity: CustomerIdentity, eventType: EventType, data: EventData? = nil) {
        self.brand = Brand(id: brandId)
        self.channel = ChannelIdentifier(id: channelId)
        self.consumerIdentity = customerIdentity
        self.eventType = eventType
        self.data = data
    }
}
