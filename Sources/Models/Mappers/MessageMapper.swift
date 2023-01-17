import Foundation


enum MessageMapper {
    
    static func map(_ entity: Message) throws -> MessageDTO {
        .init(
            idOnExternalPlatform: entity.id,
            threadIdOnExternalPlatform: entity.threadId,
            contentType: try MessageContentTypeMapper.map(entity.contentType),
            createdAt: entity.createdAt,
            attachments: entity.attachments.map(AttachmentMapper.map),
            direction: Self.map(entity.direction),
            userStatistics: .init(seenAt: entity.userStatistics.seenAt, readAt: entity.userStatistics.readAt),
            authorUser: entity.authorUser.map(AgentMapper.map),
            authorEndUserIdentity: entity.authorEndUserIdentity.map(CustomerIdentityMapper.map)
        )
    }
    
    static func map(_ entity: MessageDTO) -> Message {
        .init(
            id: entity.idOnExternalPlatform,
            threadId: entity.threadIdOnExternalPlatform,
            contentType: MessageContentTypeMapper.map(entity.contentType),
            createdAt: entity.createdAt,
            attachments: entity.attachments.map(AttachmentMapper.map),
            direction: Self.map(entity.direction),
            userStatistics: .init(seenAt: entity.userStatistics.seenAt, readAt: entity.userStatistics.readAt),
            authorUser: entity.authorUser.map(AgentMapper.map),
            authorEndUserIdentity: entity.authorEndUserIdentity.map(CustomerIdentityMapper.map)
        )
    }
}


// MARK: - MessageDirection mapper

private extension MessageMapper {
    
    static func map(_ direction: MessageDirectionType) -> MessageDirection {
        switch direction {
        case .inbound:
            return .toAgent
        case .outbound:
            return .toClient
        }
    }
    
    static func map(_ direction: MessageDirection) -> MessageDirectionType {
        switch direction {
        case .toAgent:
            return .inbound
        case .toClient:
            return .outbound
        }
    }
}
