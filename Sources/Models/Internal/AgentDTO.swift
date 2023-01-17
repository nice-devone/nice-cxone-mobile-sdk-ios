import Foundation


// UserView

/// Represents all info about an agent.
struct AgentDTO: Codable {
    
    /// The id of the agent.
    let id: Int

    /// The id of the agent in the inContact (CXone) system.
    let inContactId: String?

    /// The email address of the agent.
    let emailAddress: String?

    /// The username of the agent used to log in.
    let loginUsername: String

    /// The first name of the agent.
    let firstName: String

    /// The surname of the agent.
    let surname: String

    /// The nickname of the agent.
    let nickname: String?

    /// Whether the agent is a bot.
    let isBotUser: Bool

    /// Whether the agent is for automated surveys.
    let isSurveyUser: Bool

    /// The URL for the profile photo of the agent.
    let imageUrl: String

    /// The full name of the agent (readonly).
    var fullName: String {
        "\(firstName) \(surname)"
    }
}
