//
//  File.swift
//  
//
//  Created by Customer Dynamics Development on 11/16/21.
//

import Foundation


/// Used to notice any changes to who the agent is.
struct ContactInboxAssigneeChanged: Codable {
	var eventId: String
	var eventObject: String
	var createdAt: String
	var data: ContactInboxAssigneeChangedData
}

/// Data of `CaseInboxAssigneeChanged`
struct ContactInboxAssigneeChangedData: Codable {
	var brand: Brand
	var channel: Channel
	var `case`: Case
	var inboxAssignee: ContactInboxAssignee
}

/// InboxAssignee of `CaseInboxAssigneeChangedData`
struct ContactInboxAssignee: Codable {
	var incontactId: String
	var firstName: String
	var surname: String
	var imageUrl: String
	var isBotUser: Bool
	var isSurveyUser: Bool
}
