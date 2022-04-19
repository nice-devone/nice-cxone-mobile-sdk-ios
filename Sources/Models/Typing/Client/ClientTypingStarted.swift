//
//  Created by Customer Dynamics Development on 9/29/21.
//

import Foundation

/// Used to POST a Typing Event to the WebSocket
struct ClientTypingStarted: Codable {
	var action: String
	var eventId: String
	var payload: ClientTypingStartedPayload
}

/// The `payload` of the `ClientTypingStarted`
struct ClientTypingStartedPayload: Codable {
	var brand: Brand
	var channel: Channel
	var data: ClientTypingStartedData
	var consumerIdentity: CustomerIdentity
	var eventType: String
}

/// The `data` of the `ClientTypingStarted`
struct ClientTypingStartedData: Codable {
	var thread: ThreadCodable
}
