import Foundation

/// A gallery plugin message type. It contains list of other ``PluginMessageType`` elements.
public struct PluginMessageMenu {
    
    // MARK: - Properties
    
    /// The unique identifier of the element.
    public let id: String
    
    /// The array of sub elements of any type.
    ///
    /// It can contain every available ``PluginMessageSubElementType`` element in any count.
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
