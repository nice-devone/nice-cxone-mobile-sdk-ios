import Foundation


/// A button subelement.
public struct PluginMessageButton {
    
    // MARK: - Properties
    
    /// The unique identifier of the subelement.
    public let id: String
    
    /// The content of the sub element.
    public let text: String
    
    /// The postback of the sub element.
    public let postback: String?
    
    /// The URL which can lead to the external browser/webview or might contain a deeplink.
    ///
    /// Deeplink is associated with a specific application,
    /// for example you might want to use it to redirect the user directly to a Facebook profile or perform other similar action.
    public let url: URL?
    
    /// Determines if URL should be displayed in the current context of application.
    public let displayInApp: Bool
    
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique identifier of the subelement.
    ///   - text: The content of the sub element.
    ///   - postback: The postback of the sub element.
    ///   - url: The URL which can lead to the external browser/webview or contain deeplink.
    public init(id: String, text: String, postback: String?, url: URL?, displayInApp: Bool) {
        self.id = id
        self.text = text
        self.postback = postback
        self.url = url
        self.displayInApp = displayInApp
    }
}
