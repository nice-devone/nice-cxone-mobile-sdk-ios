import Foundation

/// A title subelement.
public struct PluginMessageTitle {
    
    // MARK: - Properties
    
    /// The unique identifier of the subelement.
    public let id: String
    
    /// The content of the sub element.
    public let text: String
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique identifier of the subelement.
    ///   - text: The content of the sub element.
    public init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}
