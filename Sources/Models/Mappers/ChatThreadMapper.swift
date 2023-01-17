import Foundation


enum ChatThreadMapper {
    
    static func map(_ entity: ChatThread) throws -> ChatThreadDTO {
        .init(
            id: entity._id,
            idOnExternalPlatform: entity.id,
            threadName: entity.name,
            messages: try entity.messages.map(MessageMapper.map),
            threadAgent: entity.assignedAgent.map(AgentMapper.map),
            canAddMoreMessages: entity.canAddMoreMessages,
            contactId: entity.contactId,
            scrollToken: entity.scrollToken
        )
    }
    
    static func map(_ entity: ChatThreadDTO) -> ChatThread {
        .init(
            _id: entity.id,
            id: entity.idOnExternalPlatform,
            name: entity.threadName,
            messages: entity.messages.map(MessageMapper.map),
            assignedAgent: entity.threadAgent.map(AgentMapper.map),
            canAddMoreMessages: entity.canAddMoreMessages,
            contactId: entity.contactId,
            scrollToken: entity.scrollToken
        )
    }
}
