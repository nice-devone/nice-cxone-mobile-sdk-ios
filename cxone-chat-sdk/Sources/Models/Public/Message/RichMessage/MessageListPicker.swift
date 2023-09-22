import Foundation

/// A list picker displays a list of items, and information about the items.
///
/// It is a list of options, that customers can choose multiple times and are persistent in the conversation.
/// The options/items are usually shown in overlay with richer formatting capabilities (icon, title, subtitle, sections, etc. in future)
/// and with a bigger count than buttons or quick replies.
public struct MessageListPicker {
    
    /// Title of the List Picker in the conversation
    public let title: String
    
    /// Additional text to be displayed after clicking on the picker list
    public let text: String
    
    /// The sub elements of the list picker.
    public let elements: [MessageSubElementType]
}
