//
//  Created by Customer Dynamics Development on 9/22/21.
//

import Foundation

/// Codable for the `RetrievePost` receive from a WebSocket.
public struct RetrievePostSuccess: Codable {
	public var eventId: String
	public var postback: RetrievePostSuccessPostback
	
}

/// The `postback` of a `RetrievePostSuccess`
public struct RetrievePostSuccessPostback: Codable {
	public var eventType: String
	public var data: RetrievePostSuccessData
}

/// The `data` of a `RetrievePostSuccessPostback`
public struct RetrievePostSuccessData: Codable {
	public var consumerContact: ContactPostback
	public var messages: [MessagePostback]
	public var ownerAssignee: OwnerAssignee?
	public var thread: ThreadPostback
    public var messagesScrollToken: String
}

/// The `consumerPostBack` of the `RetrievePostSuccessData`
public struct ContactPostback: Codable {
	public var status: String
	public var createdAt: String
	public var statusUpdatedAt: String
	public var customer: CustomerPostback
	public var messagesId: [String]
	public var agentName: String?
    public var caseId: String?
}

/// The `ownerAssignee` of the `RetrievePostSuccessData`
public struct OwnerAssignee: Codable {
	public var name: String
	public var surname: String
	public var fullName: String
	public var image: String
}

/// The `thread` of the `RetrievePostSuccessData`
public struct ThreadPostback: Codable {
	public var id: String
	public var channelId: String
	public var idOnExternalPlatform: UUID
	public var threadName: String
	public var isOwn: Bool
	public var createdAt: String
	public var updatedAt: String
	public var author: Author
}

/// The `author` of the `ThreadPostback`
public struct Author: Codable {
	public var id: String
	public var name: String
	public var nickname: String
}

/// Part of the `messages` array of the `RetrievePostSuccessData`
public struct MessagePostback: Codable {
	public var messageId: UUID
	public var idOnExternalPlatform: UUID
	public var isOwn: Bool
	public var url: String
	public var messageContent: MessageContent
	public var isRead: Bool
	public var endUser: CustomerPostback?
	public var messageAssignedUser: MessageAssignedUser?
	public var createdAt: String
	public var attachments: [AttachmentSuccess]
}

public struct MessageAssignedUser: Codable {
	public var fullName: String
}

/// The `endUser` of the `MessagePostback`
//public struct EndUserPostback: Codable {
//	public var id: String
//	public var name: String
//	public var nickname: String
//}

/// The `customer` of the `ConsumerContactPostback`
public struct CustomerPostback: Codable {
	public var customerId: String?
	public var name: String
	public var surname: String?
	public var customerIdent: String?
    public var id: String?
//    public var name: String
    public var nickname: String?
}
