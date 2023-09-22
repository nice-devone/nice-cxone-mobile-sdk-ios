import Foundation

/// The provider for report related properties and methods.
public protocol AnalyticsProvider {
    
    /// The id for the visitor.
    var visitorId: UUID? { get }
    
    /// Reports to CXone that a some page/screen in the app has been viewed by the visitor.
    /// - Parameters:
    ///   - title: The title or description of the page that was viewed.
    ///   - url: A URL uniquely identifying the page.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func viewPage(title: String, url: String) async throws

    /// CXone reporting that a visitor has left a certain page/screen in the application.
    /// - Parameters:
    ///   - title: The title or description of the page that was left.
    ///   - url: A URL uniquely identifying the page.
    /// - Throws: ``CXoneChatError/pageViewNotCalled`` if an attempt was made to use a method without first reporting the screen as viewed.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func viewPageEnded(title: String, url: String) async throws
    
    /// Reports to CXone that the chat window/view has been opened by the visitor.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func chatWindowOpen() async throws
    
    /// Reports to CXone that a conversion has occurred.
    /// - Parameters:
    ///   - type: The type of conversion. Can be any value.
    ///   - value: The value associated with the conversion (for example, unit amount). Can be any number.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func conversion(type: String, value: Double) async throws

    /// Reports to CXone that a proactive action was displayed to the visitor.
    /// - Parameter data: The proactive action that was displayed.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func proactiveActionDisplay(data: ProactiveActionDetails) async throws
    
    /// Reports to CXone that a proactive action was clicked or acted upon by the visitor.
    /// - Parameter data: The proactive action that was clicked.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func proactiveActionClick(data: ProactiveActionDetails) async throws
    
    /// Reports to CXone that a proactive action was successful or fails and lead to a conversion.
    /// - Parameter data: The proactive action that was successful or fails.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/channelConfigFailure``` if the URL cannot be parsed, most likely because
    ///     environment.chatURL is not a valid URL.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func proactiveActionSuccess(_ isSuccess: Bool, data: ProactiveActionDetails) async throws

    /// Reports to CXone that some event occurred with the visitor.
    ///
    /// This can be used to report any custom event that may not be covered by other existing methods.
    /// - Parameter data: Any data associated with the event.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func customVisitorEvent(data: VisitorEventDataType) throws
}
