import Foundation


/// A reply button rich message sub element.
public struct MessageReplyButton {
    
    /// The text displayed in the button
    public let text: String
    
    /// The postback of the button.
    ///
    /// Postback functionality should be used only for some extra automation processing (usually bots)
    /// in a way that the bot is not considering the content of the message but postback of the message
    /// where he can inject some better (more automatically readable) identifiers than what customer/agent
    /// can see in the UI as the content of the message.
    public let postback: String?
    
    /// A more detailed description of the option
    public let description: String?
    
    /// The name of an image that will be displayed as part of the options​ (256 KiB)
    public let iconName: String?
    
    /// The URL of an image that will be displayed as part of the options​ (256 KiB)
    public let iconUrl: URL?
    
    /// The MIME type of an image that will be displayed as part of the options​ (256 KiB)
    public let iconMimeType: String?
}
