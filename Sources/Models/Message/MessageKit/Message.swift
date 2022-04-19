//
//  Created by Customer Dynamics Development on 9/2/21.
//

import Foundation
import UIKit
import CoreLocation
import MessageKit

public enum MessageTypeForReal {
	case text
	case plugin
}

/// Initializer for converting our message codable to a MessageType for MessageKit
@available(iOS 13.0, *)
public struct Message: MessageType {

	// MARK: - Variables
	public var messageId: String
	public var sender: SenderType {
		return user
	}
	public var messageType: MessageTypeForReal = .text
	public var sentDate: Date
	public var kind: MessageKind
	public var plugin: [MessagePayloadElement?]
	public var threadId: UUID
	public var user: Customer
	public var isRead: Bool

	
	// MARK: - Initializers
	public init(messageType: MessageTypeForReal, plugin: [MessagePayloadElement?], kind: MessageKind, user: Customer, messageId: UUID, date: Date, threadId: UUID, isRead: Bool) {
		self.messageType = messageType
		self.kind = kind
		self.user = user
        self.messageId = messageId.uuidString
		self.sentDate = date
		self.threadId = threadId
		self.isRead = isRead
		self.plugin = plugin
	}

	
	/// The Initializer of the Text Message based off of a `MessagePostSuccess`
	public init(message: MessagePostSuccess) {
		self.init(messageType: message.data.message.messageContent.type == EventMessageType.text.rawValue ? .text : .plugin,
				  plugin: message.data.message.messageContent.payload.elements,
				  text: message.data.message.messageContent.payload.text,
				  user: Customer(senderId: message.data.message.user?.incontactId ??
                             message.data.message.authorEndUserIdentity?.idOnExternalPlatform ?? UUID().uuidString.lowercased(),
							 displayName: message.data.message.user?.firstName ??
							 message.data.message.authorEndUserIdentity?.nickname ?? ""),
				  messageId: message.data.message.idOnExternalPlatform,
				  date: message.createdAt.iso8601withFractionalSeconds ?? Date(),
                  threadId: message.data.thread.idOnExternalPlatform,
				  isRead: message.data.message.readAt != nil ? true : false)
	}
	
	public init(attachment: AttachmentSuccess, threadId: UUID, message: MessagePostback) {
		self.init(messageType: message.messageContent.type == EventMessageType.text.rawValue ? .text : .plugin,
				  plugin: message.messageContent.payload.elements,
				  imageURL: URL(string: attachment.url)!,
                  user: Customer(senderId: message.endUser?.id ?? UUID().uuidString.lowercased(),
							 displayName: message.endUser?.name ?? ""),
				  messageId: message.idOnExternalPlatform,
				  date: message.createdAt.iso8601withFractionalSeconds ?? Date(),
				  threadId: threadId,
				  isRead: message.isRead)
	}
    
    public init(threadId: UUID, message: MessagePostback) {
        self.init(messageType: message.messageContent.type == EventMessageType.text.rawValue ? .text : .plugin,
                  plugin: message.messageContent.payload.elements,
                  text: message.messageContent.payload.text,
                  user: Customer(senderId: message.endUser?.id ?? UUID().uuidString.lowercased(),
                             displayName: message.endUser?.name ?? ""),
                  messageId: message.idOnExternalPlatform,
                  date: message.createdAt.iso8601withFractionalSeconds ?? Date(),
                  threadId: threadId,
                  isRead: message.isRead)
    }
	
	public init(attachment: AttachmentSuccess, threadId: UUID, message: MessagePostSuccess) {
        self.init(messageType: message.data.message.messageContent.type == EventMessageType.text.rawValue ? .text : .plugin,
				  plugin: message.data.message.messageContent.payload.elements,
                  imageURL: URL(string: attachment.url )!,
				  user: Customer(senderId: message.data.message.user?.incontactId ??
                             message.data.message.authorEndUserIdentity?.idOnExternalPlatform ?? UUID().uuidString.lowercased(),
							 displayName: message.data.message.user?.firstName ??
							 message.data.message.authorEndUserIdentity?.nickname ?? ""),
				  messageId: UUID(),// message.data.message.idOnExternalPlatform,
				  date: message.createdAt.iso8601withFractionalSeconds ?? Date(),
				  threadId: threadId, isRead: message.data.message.readAt != nil ? true : false)
	}
	
	/// The Initializer of the Text Message based off of a `ThreadPostback`
    public init(thread: ThreadPostback, message: MessagePostback) {
        let user: Customer = Customer(senderId: message.endUser?.id ?? UUID().uuidString.lowercased(),
                              displayName: message.endUser?.name ?? "")
        self.init(messageType: message.messageContent.type == EventMessageType.text.rawValue ? .text : .plugin,
                  plugin: message.messageContent.payload.elements,
                  text: message.messageContent.payload.text,
                  user: user,
                  messageId: message.idOnExternalPlatform,
                  date: message.createdAt.iso8601withFractionalSeconds ?? Date(),
                  threadId: thread.idOnExternalPlatform,
                  isRead: message.isRead)
    }

	/// The Initializer of the Text Message based off of a `String`
	public init(messageType: MessageTypeForReal, plugin: [MessagePayloadElement?], text: String, user: Customer, messageId: UUID, date: Date, threadId: UUID, isRead: Bool) {
		self.init(messageType: messageType,
				  plugin: plugin,
				  kind: .text(text),
				  user: user,
				  messageId: messageId,
				  date: date,
				  threadId: threadId,
				  isRead: isRead)
	}

	/// The Initializer of the Text Message based off of a `NSAttributedString`
	public init(messageType: MessageTypeForReal, plugin: [MessagePayloadElement?], attributedText: NSAttributedString, user: Customer, messageId: UUID, date: Date, threadId: UUID, isRead: Bool) {
		self.init(messageType: messageType,
				  plugin: plugin,
				  kind: .attributedText(attributedText),
				  user: user, messageId: messageId,
				  date: date,
				  threadId: threadId,
				  isRead: isRead)
	}

	/// The Initializer of the Text Message based off of an `UIImage`
	public init(messageType: MessageTypeForReal, plugin: [MessagePayloadElement?], image: UIImage, user: Customer, messageId: UUID, date: Date, threadId: UUID, isRead: Bool) {
		let mediaItem = ImageMediaItem(image: image)
		self.init(messageType: messageType,
				  plugin: plugin,
				  kind: .photo(mediaItem),
				  user: user,
				  messageId: messageId,
				  date: date,
				  threadId: threadId,
				  isRead: isRead)
	}

	/// The Initializer of the Text Message based off of an image `URL`
	public init(messageType: MessageTypeForReal, plugin: [MessagePayloadElement?], imageURL: URL, user: Customer, messageId: UUID, date: Date, threadId: UUID, isRead: Bool) {
		let mediaItem = ImageMediaItem(imageURL: imageURL)
		self.init(messageType: messageType,
				  plugin: plugin,
				  kind: .photo(mediaItem),
				  user: user,
				  messageId: messageId,
				  date: date,
				  threadId: threadId,
				  isRead: isRead)
	}

	/// The Initializer of the Text Message based off of a `UIImage`
	public init(messageType: MessageTypeForReal, plugin: [MessagePayloadElement?], thumbnail: UIImage, user: Customer, messageId: UUID, date: Date, threadId: UUID, isRead: Bool) {
		let mediaItem = ImageMediaItem(image: thumbnail)
		self.init(messageType: messageType,
				  plugin: plugin,
				  kind: .video(mediaItem),
				  user: user,
				  messageId: messageId,
				  date: date,
				  threadId: threadId,
				  isRead: isRead)
	}

	/// The Initializer of the Text Message based off of a `ThreadPostback`
	public init(messageType: MessageTypeForReal,  plugin: [MessagePayloadElement?], location: CLLocation, user: Customer, messageId: UUID, date: Date, threadId: UUID, isRead: Bool) {
		let locationItem = CoordinateItem(location: location)
		self.init(messageType: messageType,
				  plugin: plugin,
				  kind: .location(locationItem),
				  user: user,
				  messageId: messageId,
				  date: date,
				  threadId: threadId,
				  isRead: isRead)
	}

	/// The Initializer of the Text Message based off of a `String` with only an Emoji
	public init(messageType: MessageTypeForReal, plugin: [MessagePayloadElement?], emoji: String, user: Customer, messageId: UUID, date: Date, threadId: UUID, isRead: Bool) {
		self.init(messageType: messageType,
				  plugin: plugin,
				  kind: .emoji(emoji),
				  user: user,
				  messageId: messageId,
				  date: date,
				  threadId: threadId,
				  isRead: isRead)
	}

	/// The Initializer of the Audio Message based off of a `URL`
	public init(messageType: MessageTypeForReal,  plugin: [MessagePayloadElement?], audioURL: URL, user: Customer, messageId: UUID, date: Date, threadId: UUID, isRead: Bool) {
		let audioItem = MockAudioItem(url: audioURL)
		self.init(messageType: messageType,
				  plugin: plugin,
				  kind: .audio(audioItem),
				  user: user,
				  messageId: messageId,
				  date: date,
				  threadId: threadId,
				  isRead: isRead)
	}

	/// The Initializer of the Contact Message based off of a `MockContactItem`
	public init(messageType: MessageTypeForReal, plugin: [MessagePayloadElement?], contact: MockContactItem, user: Customer, messageId: UUID, date: Date, threadId: UUID, isRead: Bool) {
		self.init(messageType: messageType,
				  plugin: plugin,
				  kind: .contact(contact),
				  user: user,
				  messageId: messageId,
				  date: date,
				  threadId: threadId,
				  isRead: isRead)
	}

	/// The Initializer of the Text Message based off of a `MessageLinkItem`
	public init(messageType: MessageTypeForReal, plugin: [MessagePayloadElement?], linkItem: MessageLinkItem, user: Customer, messageId: UUID, date: Date, threadId: UUID, isRead: Bool) {
		self.init(messageType: messageType,
				  plugin: plugin,
				  kind: .linkPreview(linkItem),
				  user: user,
				  messageId: messageId,
				  date: date,
				  threadId: threadId,
				  isRead: isRead)
	}
}
extension Message: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}

extension Message: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
}
