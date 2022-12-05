import Foundation


enum ProactiveActionDataMessageContentMapper {
    
    static func map(_ entity: ProactiveActionDataMessageContent) -> ProactiveActionDataMessageContentDTO {
        .init(
            bodyText: entity.bodyText,
            headlineText: entity.headlineText,
            headlineSecondaryText: entity.headlineSecondaryText,
            image: entity.image
        )
    }
}
