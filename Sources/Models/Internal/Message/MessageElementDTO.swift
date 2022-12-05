import Foundation


/// All info about a plugin element in a message.
struct MessageElementDTO: Codable {
    
    /// The unique identifier of the message element.
    let id: String

    /// The type of the element.
    let type: ElementType

    /// The actual value of the message.
    let text: String

    /// The postback of the message element.
    let postback: String?

    /// The URL of the message ``ElementType.file`` or other relevant types.
    let url: String?
    
    /// The name of the file for ``ElementType.file`` or other relevant types.
    let fileName: String?

    /// The MIME type of the file for ``ElementType.file`` or other relevant types
    let mimeType: String?

    /// The set of subelements.
    let elements: [MessageElementDTO]?
}
