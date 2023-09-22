import Foundation

enum AgentMapper {
    
    static func map(_ entity: Agent) -> AgentDTO {
        AgentDTO(
            id: entity.id,
            inContactId: entity.inContactId,
            emailAddress: entity.emailAddress,
            loginUsername: entity.loginUsername,
            firstName: entity.firstName,
            surname: entity.surname,
            nickname: entity.nickname,
            isBotUser: entity.isBotUser,
            isSurveyUser: entity.isSurveyUser,
            imageUrl: entity.imageUrl
        )
    }
    
    static func map(_ entity: AgentDTO) -> Agent {
        Agent(
            id: entity.id,
            inContactId: entity.inContactId,
            emailAddress: entity.emailAddress,
            loginUsername: entity.loginUsername,
            firstName: entity.firstName,
            surname: entity.surname,
            nickname: entity.nickname,
            isBotUser: entity.isBotUser,
            isSurveyUser: entity.isSurveyUser,
            imageUrl: entity.imageUrl
        )
    }
}
