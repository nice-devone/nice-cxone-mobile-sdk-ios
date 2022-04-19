//
//  Created by Customer Dynamics Development on 9/28/21.
//

import Foundation

///Used when receiving information from the WebSocket on the agent's side.
struct AgentTypingStarted: Codable {
	var eventId: String
	var eventObject: String
	var createdAt: String
	var createdAtWithMilliseconds: String
	var data: AgentTypingStartedData
}

/// The `data` of the `AgentTypingStarted`
struct AgentTypingStartedData: Codable {
	var brand: Brand
	var channel: Channel
	var thread: MessageThreadCodable
	var user: InContactUserIdentity?
	var authorEndUserIdentity: AuthorCustomerIdentity?
}
