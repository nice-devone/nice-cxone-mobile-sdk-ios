//
//  File.swift
//  
//
//  Created by Tyler Hendrickson on 3/5/22.
//

import Foundation

/// An event to be sent through the WebSocket.
public struct Event: Encodable {
    
    /// The action that was performed for the event.
    private var action: String
    
    /// The unique id for the event.
    private var eventId = UUID().uuidString
    
    /// The event details
    var payload: EventPayload
    
    init(brandId: Int, channelId: String, customerIdentity: CustomerIdentity, eventType: EventType, data: EventData? = nil) {
        payload = EventPayload(
            brandId: brandId,
            channelId: channelId,
            customerIdentity: customerIdentity,
            eventType: eventType,
            data: data)
        action = (eventType == EventType.authorizeCustomer || eventType == EventType.refreshToken) ? EventAction.register.rawValue : EventAction.chatWindowEvent.rawValue
    }
}

/// The details about the event to be sent.
struct EventPayload: Encodable {
    
    /// The brand for which the event applies.
    private var brand: Brand
    
    /// The channel for which the event applies.
    private var channel: Channel
    
    /// The identity of the customer that is sending the event.
    private var consumerIdentity: CustomerIdentity // Prop name must stay the same
    
    /// The type of event to be sent.
    private var eventType: String
    
    /// The data to be sent for the event.
    var data: EventData?
    
    init(brandId: Int, channelId: String, customerIdentity: CustomerIdentity, eventType: EventType, data: EventData? = nil) {
        self.brand = Brand(id: brandId)
        self.channel = Channel(id: channelId)
        self.consumerIdentity = customerIdentity
        self.eventType = eventType.rawValue
        self.data = data
    }
}
extension Event {
    var id: String {
        eventId
    }
}
struct ReconnectPayload {
    /// The brand for which the event applies.
     var brand: Brand
    
    /// The channel for which the event applies.
     var channel: Channel
    
    /// The identity of the customer that is sending the event.
     var consumerIdentity: CustomerIdentity
    
    /// The type of event to be sent.
    var eventType: String
    
    var visitor: Visitor
    
    /// The data to be sent for the event.
    var data: ReconnectUserData?
    
}

extension ReconnectPayload: Codable {}

struct ReconnectEvent {
    /// The action that was performed for the event.
    private var action: String
    
    /// The unique id for the event.
    private var eventId = UUID().uuidString
    
    /// The event details
    var payload: ReconnectPayload
    
    init(brandId: Int, channelId: String, customerIdentity: CustomerIdentity, eventType: EventType, visitor: String, token: String? = nil) {
       payload = ReconnectPayload(brand: Brand(id: brandId),
                                      channel: Channel(id: channelId),
                                      consumerIdentity: customerIdentity,
                                      eventType: eventType.rawValue,
                                      visitor: Visitor(id: visitor),
                                  data: ReconnectUserData(accessToken: Token(token: token ?? "")))
        
        action = EventAction.chatWindowEvent.rawValue
    }
}
extension ReconnectEvent: Codable {}
