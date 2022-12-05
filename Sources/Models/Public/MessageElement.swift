import Foundation


/// All info about a plugin element in a message.
public struct MessageElement {
    
    /// The unique identifier of the message element.
    public let id: String

    /// The type of the element.
    public let type: ElementType

    /// The actual value of the message.
    public let text: String

    /// The postback of the message element.
    public let postback: String?

    /// The URL of the message ``ElementType.file`` or other relevant types.
    public let url: String?
    
    /// The name of the file for ``ElementType.file`` or other relevant types.
    public let fileName: String?

    /// The MIME type of the file for ``ElementType.file`` or other relevant types
    public let mimeType: String?

    /// The set of subelements.
    public let elements: [MessageElement]?
}
