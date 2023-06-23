import Foundation


/// The different types of elements that can be present in the content of a message.
enum ElementType: String, Codable {
    
    // MARK: - Content Type
    
    /// Basic text.
    case text = "TEXT"

    /// A plugin message content type.
    case plugin = "PLUGIN"
    
    /// A rich link message content type.
    case richLink = "RICH_LINK"
    
    /// A list picker message content type.
    case listPicker = "LIST_PICKER"
    
    
    // MARK: - Plugins
    
    /// A menu plugin to display.
    case menu = "MENU"

    /// A text and buttons plugin to display.
    case textAndButtons = "TEXT_AND_BUTTONS"
    
    /// A plugin element to display a satisfaction survey.
    case satisfactionSurvey = "SATISFACTION_SURVEY"
    
    /// A custom plugin that is displayed.
    case custom = "CUSTOM"
    
    
    // MARK: - Shared
    
    /// A quick reply plugin/rich message to display.
    case quickReplies = "QUICK_REPLIES"
    
    
    // MARK: - SubElements
    
    /// A button that the customer can press.
    case button = "BUTTON"

    /// A file that the customer can view.
    case file = "FILE"

    /// A title to display.
    case title = "TITLE"
    
    /// An iframe button that the custome can press.
    case iFrameButton = "IFRAME_BUTTON"
    
    /// A reply button that the customer can press and send its text as a chat reply.
    case replyButton = "REPLY_BUTTON"
}
