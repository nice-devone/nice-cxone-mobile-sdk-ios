import Foundation


/// A satisfaction survey plugin message type.
public struct PluginMessageSatisfactionSurvey {
    
    // MARK: - Properties
    
    /// The unique identifier of the element.
    public let id: String
    
    /// The list of sub element components.
    ///
    /// In most cases, it will contain single ``PluginMessageButton`` element.
    /// However, it could also contain a ``PluginMessageText`` or ``PluginMessageTitle`` element
    /// to describe the content of the component.
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
