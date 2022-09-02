import Foundation

/// All info about a plugin element in a message.
public struct MessageElement: Codable {
    public var id: String
    public var type: ElementType
    public var text: String
    public var postback: String?
    public var url: String?
    public var fileName: String?
    public var mimeType: String?
    public var elements: [MessageElement]?
    // TODO: Add variables
//    public var variables: Any
}
