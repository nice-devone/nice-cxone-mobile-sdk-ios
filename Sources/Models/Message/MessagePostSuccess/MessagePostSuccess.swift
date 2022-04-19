//
//  Created by Customer Dynamics Development on 9/27/21.
//

import Foundation
import SwiftUI

/// The `Codable` for when a Message is created.
public struct MessagePostSuccess {
	public var eventId: String
	public var eventObject: String
	public var eventType: String
	public var createdAt: String
	public var data: MessagePostSuccessData
}

extension MessagePostSuccess: Codable {
    enum CodingKeys: String, CodingKey {
        case eventId = "eventId"
        case eventObject = "eventObject"
        case eventType = "eventType"
        case createdAt = "createdAt"
        case data = "data"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        eventId = try values.decode(String.self, forKey: .eventId)
        eventObject = try values.decode(String.self, forKey: .eventObject)
        eventType = try values.decode(String.self, forKey: .eventType)
        createdAt = try values.decode(String.self, forKey: .createdAt)
        data = try values.decode(MessagePostSuccessData.self, forKey: .data)
    }
}

/// The `data` of a `MessagePostSuccess`
public struct MessagePostSuccessData {
	public var brand: Brand
	public var channel: Channel
	public var `case`: Case
	public var thread: MessageThreadCodable
	public var message: MessagePostSuccessMessage
}

extension MessagePostSuccessData: Codable {
    enum CodingKeys: String, CodingKey {

        case brand = "brand"
        case message = "message"
        case channel = "channel"
        case `case` = "case"
        case thread = "thread"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        brand = try values.decode(Brand.self, forKey: .brand)
        message = try values.decode(MessagePostSuccessMessage.self, forKey: .message)
        channel = try values.decode(Channel.self, forKey: .channel)
        `case` = try values.decode(Case.self, forKey: .case)
        thread = try values.decode(MessageThreadCodable.self, forKey: .thread)
    }
}

/// The `case` pf a `MessagePostSuccessData`
public struct Case {
	public var threadId: String
    public var id: String?
}
extension Case: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case threadId = "threadId"
    }

   public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        threadId = try values.decode(String.self, forKey: .threadId)
    }
}

public struct AttachmentSuccess: Codable {
	public var id: String
	public var friendlyName: String
	public var url: String
	public var securedPermanentUrl: String
	public var previewUrl: String
}

/// The `message` of `MessagePostSuccessData`
public struct MessagePostSuccessMessage {
	public var id: String
	public var idOnExternalPlatform: UUID
	public var postId: String
	public var threadId: String
	public var messageContent: MessageContent
	public var createdAt: String
	public var isMadeByUser: Bool
	public var isRead: Bool
	public var attachments: [AttachmentSuccess]
	public var readAt: String?
	public var user: InContactUserIdentity?
	public var authorEndUserIdentity: AuthorCustomerIdentity?    
    
}
extension MessagePostSuccessMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case idOnExternalPlatform = "idOnExternalPlatform"
        case postId = "postId"
        case threadId = "threadId"
        case messageContent = "messageContent"
        case createdAt = "createdAt"
        case isMadeByUser = "isMadeByUser"
        case isRead = "isRead"
        case attachments = "attachments"
        case readAt = "readAt"
        case user = "user"
        case authorEndUserIdentity = "authorEndUserIdentity"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        idOnExternalPlatform = try values.decode(UUID.self, forKey: .idOnExternalPlatform)
        postId = try values.decode(String.self, forKey: .postId)
        threadId = try values.decode(String.self, forKey: .threadId)
        messageContent = try values.decode(MessageContent.self, forKey: .messageContent)
        createdAt = try values.decode(String.self, forKey: .createdAt)
        isMadeByUser = try values.decode(Bool.self, forKey: .isMadeByUser)
        isRead = try values.decode(Bool.self, forKey: .isRead)
        attachments = try values.decodeIfPresent([AttachmentSuccess].self, forKey: .attachments) ?? []
        readAt = try values.decodeIfPresent(String.self, forKey: .readAt)
        user = try values.decodeIfPresent(InContactUserIdentity.self, forKey: .user)
        authorEndUserIdentity = try values.decodeIfPresent(AuthorCustomerIdentity.self, forKey: .authorEndUserIdentity)
    }
}

/// User identity of the agent
public struct InContactUserIdentity: Codable {
	public var id: Int
	public var incontactId: String
	public var firstName: String
}

/// User identity of the client.
public struct AuthorCustomerIdentity: Codable {
	public var idOnExternalPlatform: String
	public var nickname: String
}
