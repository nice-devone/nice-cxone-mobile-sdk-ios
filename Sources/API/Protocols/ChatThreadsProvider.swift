//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

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
    ///
    /// - Returns: List of chat threads if any exist.
    func get() -> [ChatThread]
    
    /// Creates a new thread by sending an initial message to the thread.
    ///
    /// - Warning: If attempted on a channel that only supports a single thread, this will fail once a thread is already created.
    /// - Warning: Channel might have configured dynamic pre-chat survey with required contact custom fields.
    ///     These identifiers and values must be sent. To fill in the parameters of the pre-chat survey, use the ``create(with:)`` method.
    ///     Otherwise; this method throws ``CXoneChatError/missingPreChatCustomFields``.
    ///
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/missingPreChatCustomFields`` if the prechat survey has missing required fields.
    func create() async throws
    
    /// Creates a new thread with custom fields by sending an initial message to the thread.
    ///
    /// Channel might have configured dynamic pre-chat survey with required contact custom fields.
    /// These values with its identifiers has to be sent in this method.
    /// Otherwise; this method throws ``CXoneChatError/missingPreChatCustomFields``.
    ///
    /// - Parameter customFields: The custom fields to be saved with thread creation.
    ///
    /// - Warning: If attempted on a channel that only supports a single thread, this will fail once a thread is already created.
    ///
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/missingPreChatCustomFields`` if the server requires to fill-up some contact custom fields before initializing chat thread.
    func create(with customFields: [String: String]) async throws
    
    /// Loads the a thread for the customer and gets messages.
    ///
    /// - Parameter id: The id of the thread to load. Optional, if omitted,
    ///     it will attempt to load the customer's active thread. If there is no active thread, this returns an error.
    ///
    /// - Warning: If method receives `UUID` for a non existing thread, it throws ``CXoneChatError/invalidThread`` error.
    /// - Warning: Should only be used when opening a thread for multithreaded channel configuration
        /// or to reconnect after returning from the background.
    ///
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func load(with id: UUID?) throws
    
    /// Updates the name for a thread.
    ///
    /// - Parameters:
    ///   - name: The new name for the thread.
    ///   - id: The unique identifier of the thread to load.
    ///
    /// - Warning: Should only be used on a channel configured for multiple threads.
    ///
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    func updateName(_ name: String, for id: UUID) throws
    
    /// Archives a thread from the list of all threads.
    ///
    /// - Parameter thread: The  thread to load.
    ///
    /// - Warning: Should only be used on a channel configured for multiple threads.
    ///
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/invalidThread`` if the provided ID for the thread was invalid, so the action could not be performed.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func archive(_ thread: ChatThread) throws
    
    /// Reports that the most recent message of the specified thread was read by the customer.
    ///
    /// - Parameter thread: The  thread to load.
    ///
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func markRead(_ thread: ChatThread) throws
    
    /// Invoke this when the customer wishes to end conversation.
    ///
    ///  - Parameter thread: The thread to be close.
    ///
    /// - Warning: Should only be used on a channel configured for live chat.
    ///
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/unsupportedChannelConfig`` if the method being called is not supported with the current channel configuration.
    /// - Throws: ``CXoneChatError/missingParameter(_:)`` if the `contactId` has not been set properly or it was unable to unwrap it as a required type.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func endContact(_ thread: ChatThread) throws
    
    /// Reports that the customer has started or finished typing in the specified chat thread.
    ///
    /// - Parameters:
    ///   - didStart: Indicator for start of finish typing.
    ///   - thread: The thread where typing was started.
    ///
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``CXoneChatError/illegalThreadState`` if the chat thread is not in the correct state.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func reportTypingStart(_ didStart: Bool, in thread: ChatThread) throws
}
