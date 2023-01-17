import Foundation


/// The different types of elements that can be present in the content of a message.
enum ElementType: String, Codable {
    
    /// Basic text.
    case text = "TEXT"

    /// A button that the customer can press.
    case button = "BUTTON"

    /// A file that the customer can view.
    case file = "FILE"

    /// A title to display.
    case title = "TITLE"
    
    /// An iframe button that the custome can press.
    case iFrameButton = "IFRAME_BUTTON"
    
    /// A menu plugin to display.
    case menu = "MENU"

    /// A quick reply plugin to display.
    case quickReplies = "QUICK_REPLIES"

    /// A text and buttons plugin to display.
    case textAndButtons = "TEXT_AND_BUTTONS"
    
    /// A plugin element to display a satisfaction survey.
    case satisfactionSurvey = "SATISFACTION_SURVEY"
    
    /// A custom plugin that is displayed.
    case custom = "CUSTOM"
}
