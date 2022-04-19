//
//  File.swift
//  
//
//  Created by kjoe on 3/21/22.
//

import Foundation
struct  StoreVisitorEventPayload {
    public let eventType: EventType 
    public let brand: Brand
    public let visitor:  Visitor
    public let destination: Destination
    public let data: StoreVisitorEventData
    
}
struct StoreVisitorEvent{
    var action: String
    var eventId: String
    var payload: StoreVisitorEventPayload
}
extension StoreVisitorEvent: Encodable {}
extension StoreVisitorEventPayload: Encodable {}

struct Visitor {
    public let id: String
}
extension Visitor: Codable {}

struct Destination {
    public let id: String
}
extension Destination: Codable {}


struct ExecuteTriggerEventPayload {
    public let eventType: EventType
    public let brand: Brand
    public let channel: Channel
    public let consumerIdentity: CustomerIdentity
    public let destination: Destination
    public let visitor:  Visitor
    public let data: TriggerData
}
extension ExecuteTriggerEventPayload: Codable {}
struct ExecuteTriggerEvent{
    var action: String
    var eventId: String
    var payload: ExecuteTriggerEventPayload
}
extension ExecuteTriggerEvent: Encodable {}

struct TriggerData {
    let trigger: Trigger
}
extension TriggerData: Codable {}
