import Foundation


/// The different types of sub elements that can be present in the content of a message.
public enum PluginMessageSubElementType {
    
    /// A simple text subelement.
    case text(PluginMessageText)
    
    /// A button subelement.
    case button(PluginMessageButton)
    
    /// A file subelement.
    case file(PluginMessageFile)
    
    /// A title subelement.
    case title(PluginMessageTitle)
}
