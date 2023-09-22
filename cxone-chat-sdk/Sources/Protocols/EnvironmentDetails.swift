import Foundation

/// Details required about an environment.
protocol EnvironmentDetails {
    
    /// The location of the environment.
    var location: String { get }

    /// The URL used for chat requests (channel config and attachment upload).
    var chatURL: String { get }

    /// The URL used for the WebSocket connection.
    var socketURL: String { get }
}
