
import Foundation

public struct ProactiveActionData: Codable {
    public init(content: ProactiveActionDataMessageContent) {
        self.content = content
        self.handover = Handover(customFields: [])
    }
    
    var content: ProactiveActionDataMessageContent
    var handover: Handover
    var template: Template?
    var call2action: CallToAction?
    var design: Design?
    var position: Position?
    var customization: Customization?
}
