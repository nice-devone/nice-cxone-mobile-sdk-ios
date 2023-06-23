import Foundation


/// The provider for report related properties and methods.
public protocol AnalyticsProvider {
    
    /// The id for the visitor.
    var visitorId: UUID? { get }
    
    /// Reports to CXone that a some page/screen in the app has been viewed by the visitor.
    /// - Parameters:
    ///   - title: The title or description of the page that was viewed.
    ///   - uri: A URI uniquely identifying the page. This can be any unique identifier.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func viewPage(title: String, uri: String) throws
    
    /// Reports to CXone that the chat window/view has been opened by the visitor.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func chatWindowOpen() throws
    
    /// Reports to CXone that the visitor has visited the app.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerVisitorAssociationFailure`` if the customer could not be associated with a visitor.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func visit() throws
    
    /// Reports to CXone that a conversion has occurred.
    /// - Parameters:
    ///   - type: The type of conversion. Can be any value.
    ///   - value: The value associated with the conversion (for example, unit amount). Can be any number.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func conversion(type: String, value: Double) throws
    
    /// Reports to CXone that some event occurred with the visitor.
    ///
    /// This can be used to report any custom event that may not be covered by other existing methods.
    /// - Parameter data: Any data associated with the event.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func customVisitorEvent(data: VisitorEventDataType) throws
    
    /// Reports to CXone that a proactive action was displayed to the visitor.
    /// - Parameter data: The proactive action that was displayed.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func proactiveActionDisplay(data: ProactiveActionDetails) throws
    
    /// Reports to CXone that a proactive action was clicked or acted upon by the visitor.
    /// - Parameter data: The proactive action that was clicked.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func proactiveActionClick(data: ProactiveActionDetails) throws
    
    /// Reports to CXone that a proactive action was successful or fails and lead to a conversion.
    /// - Parameter data: The proactive action that was successful or fails.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func proactiveActionSuccess(_ isSuccess: Bool, data: ProactiveActionDetails) throws
}
