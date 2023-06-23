import Foundation


/// The provider for thread related properties and methods.
public protocol ChatThreadsProvider {
    
    /// The dynamic pre-chat survey element with title and custom fields.
    ///
    /// To fill in the parameters of the pre-chat survey, use the ``create(with:)`` method.
    var preChatSurvey: PreChatSurvey? { get }
    
    /// The provider for message related properties and methods.
    var messages: MessagesProvider { get }
    
    /// The provider for chat fields related properties and methods.
    var customFields: ContactCustomFieldsProvider { get }
    
    /// The list of all chat threads.
    func get() -> [ChatThread]
    
    /// Creates a new thread by sending an initial message to the thread.
    ///
    /// - Warning: If attempted on a channel that only supports a single thread, this will fail once a thread is already created.
    /// - Warning: Channel might have configured dynamic pre-chat survey with required contact custom fields.
    ///     These identifiers and values must be sent. To fill in the parameters of the pre-chat survey, use the ``create(with:)`` method.
    ///     Otherwise; this method throws ``CXoneChatError/missingPreChatCustomFields``.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/missingPreChatCustomFields`` if the prechat survey has missing required fields.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` customer
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Returns: Returns `id` of a new created thread.
    func create() throws -> UUID
    
    /// Creates a new thread with custom fields by sending an initial message to the thread.
    ///
    /// Channel might have configured dynamic pre-chat survey with required contact custom fields.
    ///     These values with its identifiers has to be sent in this method.
    ///     Otherwise; this method throws ``CXoneChatError/missingPreChatCustomFields``.
    /// - Parameter customFields: The custom fields to be saved with thread creation.
    /// - Warning: If attempted on a channel that only supports a single thread, this will fail once a thread is already created.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/missingPreChatCustomFields`` if the server requires to fill-up some contact custom fields before initializing chat thread.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` customer
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Returns: Returns `id` of a new created thread.
    func create(with customFields: [String: String]) throws -> UUID
    
    /// Loads all of the threads for the current customer.
    ///
    /// Triggers fetch of all available threads. Not usable for a single-thread channel configuration.
    /// - Warning: Should only be used on a channel configured for multiple threads.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func load() throws
    
    /// Loads the a thread for the customer and gets messages.
    /// - Parameter id: The id of the thread to load. Optional, if omitted,
    ///     it will attempt to load the customer's active thread. If there is no active thread, this returns an error.
    /// - Warning: If method receives `UUID` for a non existing thread, it throws ``CXoneChatError/invalidThread`` error.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func load(with id: UUID?) throws
    
    /// Loads information about the thread. This will provide the most recent message for the thread.
    /// - Parameter thread: The  thread to load.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func loadInfo(for thread: ChatThread) throws
    
    /// Updates the name for a thread.
    /// - Parameters:
    ///   - name: The new name for the thread.
    ///   - id: The unique identifier of the thread to load.
    /// - Warning: Should only be used on a channel configured for multiple threads.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func updateName(_ name: String, for id: UUID) throws
    
    /// Archives a thread from the list of all threads.
    /// - Parameter thread: The  thread to load.
    /// - Warning: Should only be used on a channel configured for multiple threads.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func archive(_ thread: ChatThread) throws
    
    /// Reports that the most recent message of the specified thread was read by the customer.
    /// - Parameter thread: The  thread to load.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func markRead(_ thread: ChatThread) throws
    
    /// Reports that the customer has started or finished typing in the specified chat thread.
    /// - Parameters:
    ///   - didStart: Indicator for start of finish typing.
    ///   - thread: The thread where typing was started.
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func reportTypingStart(_ didStart: Bool, in thread: ChatThread) throws
}
