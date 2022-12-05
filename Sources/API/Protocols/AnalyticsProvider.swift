import Foundation


/// The provider for report related properties and methods.
public protocol AnalyticsProvider {
    
    /// The id for the visitor.
    var visitorId: UUID? { get }
    
    /// Reports to CXone that a some page/screen in the app has been viewed by the visitor.
    /// - Parameters:
    ///   - title: The title or description of the page that was viewed.
    ///   - uri: A URI uniquely identifying the page. This can be any unique identifier.
    func viewPage(title: String, uri: String) throws
    
    /// Reports to CXone that the chat window/view has been opened by the visitor.
    func chatWindowOpen() throws
    
    /// Reports to CXone that the visitor has visited the app.
    func visit() throws
    
    /// Reports to CXone that a conversion has occurred.
    /// - Parameters:
    ///   - type: The type of conversion. Can be any value.
    ///   - value: The value associated with the conversion (for example, unit amount). Can be any number.
    func conversion(type: String, value: Double) throws
    
    /// Reports to CXone that some event occurred with the visitor.
    ///
    /// This can be used to report any custom event that may not be covered by other existing methods.
    /// - Parameters:
    ///   - data: Any data associated with the event.
    func customVisitorEvent(data: VisitorEventDataType) throws
    
    /// Reports to CXone that a proactive action was displayed to the visitor.
    /// - Parameter data: The proactive action that was displayed.
    func proactiveActionDisplay(data: ProactiveActionDetails) throws
    
    /// Reports to CXone that a proactive action was clicked or acted upon by the visitor.
    /// - Parameter data: The proactive action that was clicked.
    func proactiveActionClick(data: ProactiveActionDetails) throws
    
    /// Reports to CXone that a proactive action was successful or fails and lead to a conversion.
    /// - Parameter data: The proactive action that was successful or fails.
    func proactiveActionSuccess(_ isSuccess: Bool, data: ProactiveActionDetails) throws
}
