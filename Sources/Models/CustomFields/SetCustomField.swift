//
//  File.swift
//  
//
//  Created by Customer Dynamics Development on 11/23/21.
//

import Foundation


/// Used to set the ConsumerContact custom field settings
struct SetContactCustomField: Codable {
	var action: String
	var eventId: String
	var payload: SetContactCustomFieldPayload
}

/// Payload of the `SetConsumerContactCustomField`
struct SetContactCustomFieldPayload: Codable {
	var brand: Brand
	var channel: Channel
	var consumerIdentity: CustomerIdentity
	var data: SetContactCustomFieldData
	var eventType: String
}


/// Data of the `SetConsumerContactCustomField`
struct SetContactCustomFieldData: Codable {
	var thread: CustomFieldThreadCodable
	var customFields: [CustomField]
	var consumerContact: Contact
}


/// consumerContact of the `SetCustomContactCustomFieldData`
struct Contact: Codable {
	var id: String
}
