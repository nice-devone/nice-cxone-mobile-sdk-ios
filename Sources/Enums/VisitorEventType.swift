import Foundation

/// The different types of visitor events.
enum VisitorEventType: String, Codable {
    
    /// Event for the visitor starting a new page visit.
    case visitorVisit = "VisitorVisit"
    
    /// Event for the visitor viewing a page.
    case pageView = "PageView"
    
    /// Event that the chat window was opened by the visitor.
    case chatWindowOpened = "ChatWindowOpened"
    
    /// Event that the visitor has followed a proactive action to start a chat.
    case conversion = "Conversion"
    
    /// Event that the proactive action was successfully displayed to the visitor.
    case proactiveActionDisplayed = "ProactiveActionDisplayed"
    
    /// Event that the proactive action was clicked by the visitor.
    case proactiveActionClicked = "ProactiveActionClicked"
    
    /// Event that the proactive action has successfully led to a conversion.
    case proactiveActionSuccess = "ProactiveActionSuccess"
    
    /// Event that the proactive action has not led to a conversion within a certain time span.
    case proactiveActionFailed = "ProactiveActionFailed"
    
    /// A custom visitor event to send any additional data.
    case custom = "Custom"
}
