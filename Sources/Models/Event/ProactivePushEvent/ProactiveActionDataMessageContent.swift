
import Foundation

public struct ProactiveActionDataMessageContent: Codable {
    public init(bodyText: String? = nil, headlineText: String? = nil, headlineSecondaryText: String? = nil, image: String? = nil) {
        self.bodyText = bodyText
        self.headlineText = headlineText
        self.headlineSecondaryText = headlineSecondaryText
        self.image = image
    }
    
    var bodyText: String?
    var headlineText: String?
    var headlineSecondaryText: String?
    var image: String?
    
}
