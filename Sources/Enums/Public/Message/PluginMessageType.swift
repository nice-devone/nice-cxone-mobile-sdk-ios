import Foundation


/// The different types of elements that can be present in the content of a message.
public enum PluginMessageType {
    
    /// A gallery plugin message type. It contains list of other plugin message elements.
    case gallery([PluginMessageType])
    
    /// A menu plugin message type.
    case menu(PluginMessageMenu)
    
    /// A text and buttons plugin message type.
    case textAndButtons(PluginMessageTextAndButtons)
    
    /// A quick replies plugin message type.
    case quickReplies(PluginMessageQuickReplies)
    
    /// A satisfaction survey plugin message type.
    case satisfactionSurvey(PluginMessageSatisfactionSurvey)
    
    /// A custom plugin message type.
    case custom(PluginMessageCustom)
    
    /// A plugin with directly used sub elements, e.g. buttons, files etc.
    case subElements([PluginMessageSubElementType])
}
