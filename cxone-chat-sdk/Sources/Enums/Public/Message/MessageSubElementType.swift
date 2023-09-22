import Foundation

/// The different types of elements that can be present in the content of a rich message.
public enum MessageSubElementType {
    
    /// A reply button rich message sub element.
    case replyButton(MessageReplyButton)
}
