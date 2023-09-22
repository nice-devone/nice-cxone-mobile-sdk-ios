import Foundation

struct StoreVisitorEventsDTO: Encodable {
    
    let action: EventActionType

    let eventId: UUID

    let payload: StoreVisitorEventsPayloadDTO
}
