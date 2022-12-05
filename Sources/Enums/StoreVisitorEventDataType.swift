import Foundation


enum StoreVisitorEventDataType: Encodable {
    
    case visitorEvent(VisitorsEventsDTO)
    
    case storeVisitorPayload(VisitorDTO)

    
    // MARK: - Encoder
    
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
