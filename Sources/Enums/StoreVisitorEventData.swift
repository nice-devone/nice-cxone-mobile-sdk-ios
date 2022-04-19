//
//  File.swift
//  
//
//  Created by kjoe on 3/22/22.
//

import Foundation
enum StoreVisitorEventData: Encodable {
    case visitorEvent(VisitorsEvents)
    case storeVisitorPayload(StoreVisitorPayload)
    
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
struct VisitorsEvents {
    let visitorEvents: [VisitorEvent]
}
extension VisitorsEvents: Encodable {}
