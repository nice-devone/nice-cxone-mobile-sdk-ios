import Foundation


/// The provider for message related properties and methods.
public protocol MessagesProvider {
    
    /// Loads additional messages in the specified thread.
    /// - Parameter chatThread: The thread for which to load more messages.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/noMoreMessages`` if there aren't any other messages, so additional messages could not be loaded.
    /// - Throws: ``CXoneChatError/invalidOldestDate`` if Thread is missing the timestamp of when the message was created.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.``
    func loadMore(for chatThread: ChatThread) throws
    
    /// Sends a message in the specified chat thread through CXone chat.
    /// - Parameters:
    ///   - message: The message text to send.
    ///   - chatThread: The thread in which the message is to be sent.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    @available(*, deprecated, message: "This method has been replaced with `func send(_ message: OutboundMessage, for chatThread: ChatThread)` in 1.1.0")
    func send(_ message: String, for chatThread: ChatThread) async throws
    
    /// Sends a message with attachments in the current thread through CXone chat.
    /// - Parameters:
    ///   - message: The message text to send along with the attachments (optional).
    ///   - attachments: The attachments to send.
    ///   - chatThread: The thread in which the message and attachments are to be sent.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if attachments upload `url` has not been set properly or attachment uploaded data object is missing.
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    /// - Throws: ``CXoneChatError/attachmentError`` if the provided attachment was unable to be sent.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    @available(*, deprecated, message: "This method has been replaced with `func send(_ message: OutboundMessage, for chatThread: ChatThread)` in 1.1.0")
    func send(_ message: String, with attachments: [ContentDescriptor], for chatThread: ChatThread) async throws
    
    /// Sends a message in the specified chat thread through CXone chat.
    ///
    /// - Parameters:
    ///   - message: The content of the message.
    ///   - chatThread: The thread in which the message is to be sent.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/serverError`` if the server experienced an internal error and was unable to perform the action.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if attachments upload `url` has not been set properly or attachment uploaded data object is missing.
    /// - Throws: ``CXoneChatError/attachmentError`` if the provided attachment was unable to be sent.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    /// - Throws: An error in the Cocoa domain, if `url` cannot be read.
    @discardableResult
    func send(_ message: OutboundMessage, for chatThread: ChatThread) async throws -> Message
}
