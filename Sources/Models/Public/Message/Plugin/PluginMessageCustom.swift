import Foundation


/// A custom  plugin message type.
public struct PluginMessageCustom {
    
    // MARK: - Properties
    
    /// The unique identifier of the element.
    public let id: String
    
    /// Text to display in place of the UI element.
    public let text: String?
    
    /// Key-value pairs with content of the element.
    public let variables: [String: Any]
    
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique identifier of the element.
    ///   - text: Text to display in place of the UI element.
    ///   - variables: Key-value pairs with content of the element.
    public init(id: String, text: String?, variables: [String: Any]) {
        self.id = id
        self.text = text
        self.variables = variables
    }
}
