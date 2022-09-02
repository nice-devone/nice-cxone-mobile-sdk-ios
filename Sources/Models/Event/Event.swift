import Foundation

/// An event to be sent through the WebSocket.
public struct Event: Encodable {
    
    /// The action that was performed for the event.
    private var action: EventAction
    
    /// The unique id for the event.
    private var eventId = UUID()
    
    /// The event details.
    var payload: EventPayload
    
    init(brandId: Int, channelId: String, customerIdentity: CustomerIdentity, eventType: EventType, data: EventData? = nil) {
        payload = EventPayload(
            brandId: brandId,
            channelId: channelId,
            customerIdentity: customerIdentity,
            eventType: eventType,
            data: data)
        action = (eventType == EventType.authorizeCustomer || eventType == EventType.refreshToken) ? EventAction.register : EventAction.chatWindowEvent
    }
}

