import Foundation


/// A text and buttons plugin message type.
public struct PluginMessageTextAndButtons {
    
    // MARK: - Properties
    
    /// The unique identifier of the element.
    public let id: String
    
    /// List with ``PluginMessageText`` and at least one ``PluginMessageButton`` element.
    public let elements: [PluginMessageSubElementType]
    
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique identifier of the element.
    ///   - elements: The array of sub elements.
    public init(id: String, elements: [PluginMessageSubElementType]) {
        self.id = id
        self.elements = elements
    }
}
