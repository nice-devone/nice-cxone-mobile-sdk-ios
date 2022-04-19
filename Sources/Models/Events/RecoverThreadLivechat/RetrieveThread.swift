//
//  Created by Customer Dynamics Development on 9/22/21.
//

import Foundation

struct RecoverThreadLivechatEvent: Codable {
	var action: String
	var eventId: String
	var payload: ThreadPayload
}

/// The `payload` of a `RetrieveThread`
struct ThreadPayload: Codable {
	var brand: Brand
	var channel: Channel
	var consumerIdentity: CustomerIdentity
	var eventType: String
    var data: RecoverThreadData?
}
struct RecoverThread: Codable {
    var brand: Brand
    var channel: Channel
    var consumerIdentity: CustomerIdentity
    var eventType: String
    var data: RecoverThreadData?
}
struct RecoverThreadData: Codable {
    var thread: CustomFieldThreadCodable
}
