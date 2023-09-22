import Foundation

struct ExecuteTriggerEventDTO: Encodable {
    
    let action: EventActionType

    let eventId: UUID

    let payload: ExecuteTriggerEventPayloadDTO
}
