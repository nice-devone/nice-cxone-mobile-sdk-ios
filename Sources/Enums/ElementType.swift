import Foundation

/// The different types of elements that can be present in the content of a message.
public enum ElementType: String, Codable {
    
    /// Basic text.
    case text = "TEXT"
    
    /// A button that the customer can press.
    case button = "BUTTON"
    
    /// A file that the customer can view.
    case file = "FILE"
    
    /// A title to display.
    case title = "TITLE"
    
    /// A menu plugin to display.
    case menu = "MENU"
    
    /// A quick reply plugin to display.
    case quickReplies = "QUICK_REPLIES"
    
    /// A countdown plugin.
    case countdown = "COUNTDOWN"
    
    /// A plugin to display when the customer is inactive.
    case inactivityPopup = "INACTIVITY_POPUP"
    
    /// A custom plugin that is displayed.
    case custom = "CUSTOM"
    
    ///  An element type to display a button that opens a WebView for a satisfaction survey. 
    case iFrameButton = "IFRAME_BUTTON"
    
    /// A plugin element to display a satisfaction survey.
    case satisfactionSurvey = "SATISFACTION_SURVEY"
}
