import Foundation

enum StoreVisitorEventData: Encodable {
    case visitorEvent(VisitorsEvents)
    case storeVisitorPayload(Visitor)
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .visitorEvent(let event):
            try container.encode(event)
        case .storeVisitorPayload(let payload):
            try container.encode(payload)
        }
    }
}

