import Foundation


/// Represents all info about an agent.
public struct Agent {
    
    /// The id of the agent.
    public let id: Int

    /// The id of the agent in the inContact (CXone) system.
    public let inContactId: UUID?

    /// The email address of the agent.
    public let emailAddress: String?

    /// The username of the agent used to log in.
    public let loginUsername: String

    /// The first name of the agent.
    public let firstName: String

    /// The surname of the agent.
    public let surname: String

    /// The nickname of the agent.
    public let nickname: String?

    /// Whether the agent is a bot.
    public let isBotUser: Bool

    /// Whether the agent is for automated surveys.
    public let isSurveyUser: Bool

    /// The URL for the profile photo of the agent.
    public let imageUrl: String

    /// The full name of the agent (readonly).
    public var fullName: String {
        "\(firstName) \(surname)"
    }
}
