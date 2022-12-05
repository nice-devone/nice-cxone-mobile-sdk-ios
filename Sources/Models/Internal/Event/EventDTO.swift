import Foundation


/// An event to be sent through the WebSocket.
struct EventDTO: Encodable {

    // MARK: - Properties

    /// The action that was performed for the event.
    let action: EventActionType

    /// The unique id for the event.
    let eventId = UUID()
    
    /// The event details.
    var payload: EventPayloadDTO
    
    
    // MARK: - Init
    
    init(brandId: Int, channelId: String, customerIdentity: CustomerIdentityDTO, eventType: EventType, data: EventDataType?) {
        payload = .init(brandId: brandId, channelId: channelId, customerIdentity: customerIdentity, eventType: eventType, data: data)
        action = (eventType == .authorizeCustomer || eventType == .refreshToken) ? .register : .chatWindowEvent
    }
}
