import Foundation


/// Text message with buttons. After the customer clicks on one of the buttons, its content is sent as a reply.
///
/// Usually, when a reply is sent, it is no more possible to click again on any button.
/// You can have between two and five (depending on the channel) customizable choices,
/// and the user can select only a single item.
///
/// When a quick reply is tapped, the buttons are dismissed,
///  and the title of the tapped button is posted to the conversation as a message.
public struct MessageQuickReplies {
    
    /// Title of the Quick Replies in the conversation
    public let title: String
    
    /// The quick replies button options.
    public let buttons: [MessageReplyButton]
}
