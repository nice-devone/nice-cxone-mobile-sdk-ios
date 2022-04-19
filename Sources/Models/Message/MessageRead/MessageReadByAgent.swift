//
//  File.swift
//  
//
//  Created by Customer Dynamics Development on 11/3/21.
//

import Foundation


/// Decodes when the agent has read the latest message in the thread.
public struct MessageReadEventByAgent: Codable {
	public var eventId: String
	public var eventObject: String
	public var eventType: String
	public var createdAt: String
	public var data: MessageReadEventDataAgent
}

/// Data of `MessageReadEventByAgent`
public struct MessageReadEventDataAgent: Codable {
	public var brand: Brand
	public var message: MessageReadMessage
}

/// Message of `MessageReadEventDataAgent`
public struct MessageReadMessage: Codable {
	public var id: String
	public var idOnExternalPlatform: UUID
	public var postId: String
	public var threadId: String
	public var messageContent: MessageContent
	public var isRead: Bool?
}
