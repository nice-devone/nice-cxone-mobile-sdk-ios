//
//  Created by Customer Dynamics Development on 9/29/21.
//

import Foundation

/// Used to POST a Typing Event to the WebSocket
struct ClientTypingEnded: Codable {
	var action: String
	var eventId: String
	var payload: ClientTypingEndedPayload
}

/// The `payload` of the `ClientTypingEnded`
struct ClientTypingEndedPayload: Codable {
	var brand: Brand
	var channel: Channel
	var data: ClientTypingEndedData
	var consumerIdentity: CustomerIdentity
	var eventType: String
}

/// The`data` of the `ClientTypingEndedPayload`
struct ClientTypingEndedData: Codable {
	var thread: ThreadCodable
}
