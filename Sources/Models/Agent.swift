import Foundation

// UserView

/// Represents all info about an agent.
public struct Agent: Codable {
    
    /// The id of the agent.
    public var id: Int
    
    /// The id of the agent in the inContact (CXone) system.
    public var inContactId: UUID?
    
    /// The email address of the agent.
    public var emailAddress: String?
    
    /// The username of the agent used to log in.
    public var loginUsername: String
    
    /// The first name of the agent.
    public var firstName: String
    
    /// The surname of the agent.
    public var surname: String
    
    /// The nickname of the agent.
    public var nickname: String?
    
    /// Whether the agent is a bot.
    public var isBotUser: Bool
    
    /// Whether the agent is for automated surveys.
    public var isSurveyUser: Bool
    
    /// The URL for the profile photo of the agent.
    public var imageUrl: String
    
    /// The full name of the agent (readonly).
    public var fullName: String {
        return "\(firstName) \(surname)"
    }
}
