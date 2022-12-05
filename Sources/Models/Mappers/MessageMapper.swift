import Foundation


enum MessageMapper {
    
    static func map(_ entity: Message) -> MessageDTO {
        .init(
            idOnExternalPlatform: entity.id,
            threadIdOnExternalPlatform: entity.threadId,
            messageContent: MessageContentMapper.map(entity.messageContent),
            createdAt: entity.createdAt,
            attachments: entity.attachments.map(AttachmentMapper.map),
            direction: entity.direction,
            userStatistics: .init(seenAt: entity.userStatistics.seenAt, readAt: entity.userStatistics.readAt),
            authorUser: entity.authorUser.map(AgentMapper.map),
            authorEndUserIdentity: entity.authorEndUserIdentity.map(CustomerIdentityMapper.map)
        )
    }
    
    static func map(_ entity: MessageDTO) -> Message {
        .init(
            id: entity.idOnExternalPlatform,
            threadId: entity.threadIdOnExternalPlatform,
            messageContent: MessageContentMapper.map(entity.messageContent),
            createdAt: entity.createdAt,
            attachments: entity.attachments.map(AttachmentMapper.map),
            direction: entity.direction,
            userStatistics: .init(seenAt: entity.userStatistics.seenAt, readAt: entity.userStatistics.readAt),
            authorUser: entity.authorUser.map(AgentMapper.map),
            authorEndUserIdentity: entity.authorEndUserIdentity.map(CustomerIdentityMapper.map)
        )
    }
}
