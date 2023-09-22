import Foundation

/// Represents info abount a content of a proactive action data message.
public struct ProactiveActionDataMessageContent {

    // MARK: - Properties

    /// Message content body
    public let bodyText: String?

    /// Message content headline
    public let headlineText: String?

    /// Message content secondary headline
    public let headlineSecondaryText: String?

    /// Message content image uri
    public let image: String?

    // MARK: - Init

    /// - Parameters:
    ///    - bodyText: The body.
    ///    - headlineText: The headline.
    ///    - headlineSecondaryText: The secondary headline.
    ///    - image: The image.
    public init(bodyText: String? = nil, headlineText: String? = nil, headlineSecondaryText: String? = nil, image: String? = nil) {
        self.bodyText = bodyText
        self.headlineText = headlineText
        self.headlineSecondaryText = headlineSecondaryText
        self.image = image
    }
}
