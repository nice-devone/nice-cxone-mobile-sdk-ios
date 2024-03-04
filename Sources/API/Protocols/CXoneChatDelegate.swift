//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

/// The handler for the chat events.
public protocol CXoneChatDelegate: AnyObject {
    
    /// Callback to be called when the connection has successfully been established.
    @available(*, deprecated, message: "Replaced with `onChatUpdated(_:mode:)` delegate method in version 1.3.0")
    func onConnect()
    
    /// Callback to be called when the connection unexpectedly drops.
    func onUnexpectedDisconnect()
    
    /// Callback to be called when the chat state has been updated.
    ///
    /// - Parameters:
    ///   - chatState: Current state of the chat
    ///   - mode: Mode of the chat based on the channel configuration
    func onChatUpdated(_ state: ChatState, mode: ChatMode)
    
    /// Callback to be called when the thread has been updated.
    ///
    /// It can reflect any updated property of the thread – messages, name, assigned agent etc.
    /// - Parameter chatThread: The updated chat thread
    func onThreadUpdated(_ chatThread: ChatThread)
    
    /// Callback to be called when threads have been updated.
    ///
    /// It can reflect any updated property of the thread – messages, name, assigned agent etc.
    /// - Parameter chatThread: The updated chat threads
    func onThreadsUpdated(_ chatThreads: [ChatThread])
    
    /// Callback to be called when a thread has been loaded/recovered.
    ///
    /// - Parameter thread: The loaded thread.
    @available(*, deprecated, message: "Replaced with `onThreadUpdated(_:)` delegate method in version 1.3.0")
    func onThreadLoad(_ thread: ChatThread)
    
    /// Callback to be called when a thread has been archived.
    @available(*, deprecated, message: "Replaced with `onThreadUpdated(_:)` delegate method in version 1.3.0")
    func onThreadArchive()
    
    /// Callback to be called when all of the threads for the customer have loaded.
    ///
    /// - Parameter threads: The thread to load.
    @available(*, deprecated, message: "Replaced with `onThreadsUpdated(_:)` delegate method in version 1.3.0")
    func onThreadsLoad(_ threads: [ChatThread])
    
    /// Callback to be called when thread info has loaded.
    ///
    /// - Parameter thread: The thread with loaded info.
    @available(*, deprecated, message: "Replaced with `onThreadUpdated(_:)` delegate method in version 1.3.0")
    func onThreadInfoLoad(_ thread: ChatThread)
    
    /// Callback to be called when the thread has been updates (thread name changed).
    @available(*, deprecated, message: "Replaced with `onThreadUpdated(_:)` delegate method in version 1.3.0")
    func onThreadUpdate()
    
    /// Callback to be called when a new page of message has been loaded.
    ///
    /// - Parameter messages: Loaded messages.
    @available(*, deprecated, message: "Replaced with `onThreadUpdated(_:)` delegate method in version 1.3.0")
    func onLoadMoreMessages(_ messages: [Message])
    
    /// Callback to be called when a new message arrives.
    ///
    /// - Parameter message: New message.
    @available(*, deprecated, message: "Replaced with `onThreadUpdated(_:)` delegate method in version 1.3.0")
    func onNewMessage(_ message: Message)
    
    /// Callback to be called when a custom plugin message is received.
    ///
    /// - Parameter messageData: The data of the custom plugin message.
    func onCustomPluginMessage(_ messageData: [Any])
    
    /// Callback to be called when the agent for the contact has changed.
    ///
    /// - Parameters:
    ///   - agent: Changed agent for the thread.
    ///   - threadId: The unique identifier of thread where agent changed.
    @available(*, deprecated, message: "Replaced with `onThreadUpdated(_:)` delegate method in version 1.3.0")
    func onAgentChange(_ agent: Agent, for threadId: UUID)
    
    /// Callback to be called when the agent has read a message.
    ///
    /// - Parameter threadId: The unique identifier of thread where message read state changed.
    @available(*, deprecated, message: "Replaced with `onThreadUpdated(_:)` delegate method in version 1.3.0")
    func onAgentReadMessage(threadId: UUID)
    
    /// Callback to be called when the agent has stopped typing.
    ///
    /// - Parameter isTyping: An agent has started or ended typing.
    /// - Parameter threadId: The unique identifier of thread where typing state changed.
    func onAgentTyping(_ isTyping: Bool, threadId: UUID)
    
    /// Callback to be called when the custom fields are set for a contact.
    func onContactCustomFieldsSet()
    
    /// Callback to be called when the custom fields are set for a customer.
    func onCustomerCustomFieldsSet()
    
    /// Callback to be called when an error occurs.
    ///
    /// - Parameter error: The error.
    func onError(_ error: Error)
    
    /// Callback to be called when refreshing the token has failed.
    func onTokenRefreshFailed()
    
    /// Callback to be called when a welcome message proactive action has been received.
    func onWelcomeMessageReceived()
    
    /// Callback to be called when a custom popup proactive action is received.
    /// 
    /// - Parameters:
    ///   -  data: The proactive popup action data
    ///   - actionId: The unique identifier of the action.
    func onProactivePopupAction(data: [String: Any], actionId: UUID)
}

// MARK: - Default Implementation

public extension CXoneChatDelegate {
    
    func onConnect() { }
    func onUnexpectedDisconnect() { }
    func onChatUpdated(_ state: ChatState, mode: ChatMode) { }
    func onThreadUpdated(_ chatThread: ChatThread) { }
    func onThreadsUpdated(_ chatThreads: [ChatThread]) { }
    func onThreadLoad(_ thread: ChatThread) { }
    func onThreadArchive() { }
    func onThreadsLoad(_ threads: [ChatThread]) { }
    func onThreadInfoLoad(_ thread: ChatThread) { }
    func onThreadUpdate() { }
    func onLoadMoreMessages(_ messages: [Message]) { }
    func onNewMessage(_ message: Message) { }
    func onCustomPluginMessage(_ messageData: [Any]) { }
    func onAgentChange(_ agent: Agent, for threadId: UUID) { }
    func onAgentReadMessage(threadId: UUID) { }
    func onAgentTyping(_ isTyping: Bool, threadId: UUID) { }
    func onContactCustomFieldsSet() { }
    func onCustomerCustomFieldsSet() { }
    func onError(_ error: Error) { }
    func onTokenRefreshFailed() { }
    func onWelcomeMessageReceived() { }
    func onProactivePopupAction(data: [String: Any], actionId: UUID) { }
}
