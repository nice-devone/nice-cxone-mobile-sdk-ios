import Foundation

public struct MessagePayload: Codable {
    public var text: String
    public var elements: [MessageElement]
    
    public init(text: String, elements: [MessageElement]) {
        self.text = text
        self.elements = elements
    }
}
