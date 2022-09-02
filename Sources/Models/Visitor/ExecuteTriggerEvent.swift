import Foundation

struct ExecuteTriggerEvent: Encodable{
    var action: EventAction
    var eventId: UUID
    var payload: ExecuteTriggerEventPayload
}


