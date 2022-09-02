import Foundation

struct StoreVisitorEvents: Encodable {
    var action: EventAction
    var eventId: UUID
    var payload: StoreVisitorEventsPayload
}
