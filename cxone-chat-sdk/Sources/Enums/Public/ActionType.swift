import Foundation

/// Supported proactive action types.
public enum ActionType: String, Codable {
    
    /// Proactive action Welcome message.
    case welcomeMessage = "WelcomeMessage"

    /// Proactive action Custom popup box.
    case customPopupBox = "CustomPopupBox"
}
