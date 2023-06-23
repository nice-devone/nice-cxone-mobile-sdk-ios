import Foundation


/// Represents all info about a message in a chat.
public struct Message {
    
    // MARK: - Properties
    
    /// The unique id for the message.
    public let id: UUID
    
    /// The thread id for the message.
    public let threadId: UUID
    
    /// The content of the message
    public let contentType: MessageContentType
    
    /// The timestamp of when the message was created.
    public let createdAt: Date
    
    /// The attachments on the message.
    public let attachments: [Attachment]
    
    /// The direction that the message is being sent (in regards to the agent).
    public let direction: MessageDirection
    
    /// Statistic information about the message (read status, viewed status, etc.).
    public let userStatistics: UserStatistics?
    
    /// The agent that sent the message. Only present if the direction is to client (outbound).
    public let authorUser: Agent?
    
    /// The customer that sent the message. Only present if the direction is to agent (inbound).
    public let authorEndUserIdentity: CustomerIdentity?
    
    /// Information about the sender of a message.
    public var senderInfo: SenderInfo {
        SenderInfo(message: self)
    }
    
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique id for the message.
    ///   - threadId: The thread id for the message.
    ///   - messageContent: The content of the message
    ///   - createdAt: The timestamp of when the message was created.
    ///   - attachments: The attachments on the message.
    ///   - direction: The direction that the message is being sent (in regards to the agent).
    ///   - userStatistics: Statistic information about the message (read status, viewed status, etc.).
    ///   - authorUser: The agent that sent the message. Only present if the direction is to client (outbound).
    ///   - authorEndUserIdentity: The customer that sent the message. Only present if the direction is to agent (inbound).
    public init(
        id: UUID,
        threadId: UUID,
        contentType: MessageContentType,
        createdAt: Date,
        attachments: [Attachment],
        direction: MessageDirection,
        userStatistics: UserStatistics?,
        authorUser: Agent?,
        authorEndUserIdentity: CustomerIdentity?
    ) {
        self.id = id
        self.threadId = threadId
        self.contentType = contentType
        self.createdAt = createdAt
        self.attachments = attachments
        self.direction = direction
        self.userStatistics = userStatistics
        self.authorUser = authorUser
        self.authorEndUserIdentity = authorEndUserIdentity
    }
}
