//
//  File.swift
//  
//
//  Created by Customer Dynamics Development on 11/3/21.
//

import Foundation


/// Sends to the websocket that the consumer has read the latest message
public struct MessageReadEvent {
	public var action: String
	public var eventId: String
	public var payload: MessageReadEventPayload
}
extension MessageReadEvent: Codable {}

/// Payload of `MessageReadEvent`
public struct MessageReadEventPayload {
	public var brand: Brand
	public var channel: Channel
	public var data: MessageReadEventData
    public var eventType: String
}
extension MessageReadEventPayload: Codable {}
/// Data of `MessageReadEventData`
public struct MessageReadEventData {
	public var thread: CustomFieldThreadCodable
}
extension MessageReadEventData: Codable {}
