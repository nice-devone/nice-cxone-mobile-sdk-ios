import Foundation

// MessageView

/// Represents all info about a message in a chat.
public struct Message: Codable {
    public init(idOnExternalPlatform: UUID, threadIdOnExternalPlatform: UUID, messageContent: MessageContent, createdAt: String, attachments: [Attachment], direction: MessageDirection, userStatistics: UserStatistics, authorUser: Agent? = nil, authorEndUserIdentity: CustomerIdentity? = nil) {
        self.idOnExternalPlatform = idOnExternalPlatform
        self.threadIdOnExternalPlatform = threadIdOnExternalPlatform
        self.messageContent = messageContent
        self.createdAt = createdAt
        self.attachments = attachments
        self.direction = direction
        self.userStatistics = userStatistics
        self.authorUser = authorUser
        self.authorEndUserIdentity = authorEndUserIdentity
    }
    
    /// The unique id for the message.
    public var idOnExternalPlatform: UUID

    /// The thread id for the message.
    public var threadIdOnExternalPlatform: UUID

    /// The content of the message
    public var messageContent: MessageContent

    /// The timestamp of when the message was created.
    public var createdAt: String // TODO: Change type to Date
    
    /// The attachments on the message.
    public var attachments: [Attachment]
    
    /// The direction that the message is being sent (in regards to the agent).
    public var direction: MessageDirection
    
    /// Statistic information about the message (read status, viewed status, etc.).
    public var userStatistics: UserStatistics
    
    /// Information about the sender of a message.
    public var senderInfo: SenderInfo {
        return SenderInfo(message: self)
    }
    
    /// The agent that sent the message. Only present if the direction is outbound.
    public var authorUser: Agent?
    
    /// The customer that sent the message. Only present if the direction is inbound.
    public var authorEndUserIdentity: CustomerIdentity?
}
