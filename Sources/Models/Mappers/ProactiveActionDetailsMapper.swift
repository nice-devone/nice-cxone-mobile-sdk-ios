import Foundation


enum ProactiveActionDetailsMapper {
    
    static func map(_ entity: ProactiveActionDetails) -> ProactiveActionDetailsDTO {
        ProactiveActionDetailsDTO(
            actionId: LowerCaseUUID(uuid: entity.id),
            actionName: entity.name,
            actionType: entity.type,
            data: entity.content.map(ProactiveActionDataMapper.map)
        )
    }
}
