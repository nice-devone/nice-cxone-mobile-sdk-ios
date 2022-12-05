import Foundation


enum ProactiveActionDataMapper {
    
    static func map(with content: ProactiveActionDataMessageContent) -> ProactiveActionDataDTO {
        .init(
            content: ProactiveActionDataMessageContentMapper.map(content),
            customFields: [],
            templateType: nil,
            call2action: nil,
            design: nil,
            position: nil,
            customJs: nil
        )
    }
}
