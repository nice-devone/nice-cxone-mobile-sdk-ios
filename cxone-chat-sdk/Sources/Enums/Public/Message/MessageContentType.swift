import Foundation

/// The different types of elements of message content.
public enum MessageContentType {
    
    /// A basic text message.
    case text(MessagePayload)
    
    /// A plugin message content type.
    case plugin(MessagePlugin)
    
    /// It is a URL link with an image preview and a defined title.
    ///
    /// The customer is able to click on it to be forwarded to the particular page.
    case richLink(MessageRichLink)
    
    /// Text message with buttons. After the customer clicks on one of the buttons, its content is sent as a reply.
    ///
    /// Usually, when a reply is sent, it is no more possible to click again on any button.
    case quickReplies(MessageQuickReplies)
    
    /// A list picker displays a list of items, and information about the items.
    ///
    /// It is a list of options, that customers can choose multiple times and are persistent in the conversation.
    /// The options/items are usually shown in overlay with richer formatting capabilities (icon, title, subtitle, sections, etc. in future)
    /// and with a bigger count than buttons or quick replies.
    case listPicker(MessageListPicker)
    
    /// An unknown content type.
    case unknown
}
