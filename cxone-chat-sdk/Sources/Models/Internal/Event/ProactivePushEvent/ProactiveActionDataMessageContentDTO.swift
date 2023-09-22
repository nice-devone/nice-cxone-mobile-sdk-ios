import Foundation

/// Represents info abount a content of a proactive action data message.
struct ProactiveActionDataMessageContentDTO: Codable {

    // MARK: - Properties

    let bodyText: String?

    let headlineText: String?

    let headlineSecondaryText: String?

    let image: String?

    // MARK: - Init

    /// - Parameters:
    ///    - bodyText: The body.
    ///    - headlineText: The headline.
    ///    - headlineSecondaryText: The secondary headline.
    ///    - image: The image.
    init(bodyText: String?, headlineText: String?, headlineSecondaryText: String?, image: String?) {
        self.bodyText = bodyText
        self.headlineText = headlineText
        self.headlineSecondaryText = headlineSecondaryText
        self.image = image
    }
}
