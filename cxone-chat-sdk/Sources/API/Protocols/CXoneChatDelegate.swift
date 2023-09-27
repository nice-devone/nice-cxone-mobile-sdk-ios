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
    func onConnect()
    
    /// Callback to be called when the connection unexpectedly drops.
    func onUnexpectedDisconnect()
    
    /// Callback to be called when a thread has been loaded/recovered.
    /// - Parameter thread: The loaded thread.
    func onThreadLoad(_ thread: ChatThread)
    
    /// Callback to be called when a thread has been archived.
    func onThreadArchive()
    
    /// Callback to be called when all of the threads for the customer have loaded.
    /// - Parameter threads: The thread to load.
    func onThreadsLoad(_ threads: [ChatThread])
    
    /// Callback to be called when thread info has loaded.
    /// - Parameter thread: The thread with loaded info.
    func onThreadInfoLoad(_ thread: ChatThread)
    
    /// Callback to be called when the thread has been updates (thread name changed).
    func onThreadUpdate()
    
    /// Callback to be called when a new page of message has been loaded.
    /// - Parameter messages: Loaded messages.
    func onLoadMoreMessages(_ messages: [Message])
    
    /// Callback to be called when a new message arrives.
    /// - Parameter message: New message.
    func onNewMessage(_ message: Message)
    
    /// Callback to be called when a custom plugin message is received.
    /// - Parameter messageData: The data of the custom plugin message.
    func onCustomPluginMessage(_ messageData: [Any])
    
    /// Callback to be called when the agent for the contact has changed.
    /// - Parameters:
    ///   - agent: Changed agent for the thread.
    ///   - threadId: The unique identifier of thread where agent changed.
    func onAgentChange(_ agent: Agent, for threadId: UUID)
    
    /// Callback to be called when the agent has read a message.
    /// - Parameter threadId: The unique identifier of thread where message read state changed.
    func onAgentReadMessage(threadId: UUID)
    
    /// Callback to be called when the agent has stopped typing.
    /// - Parameter isTyping: An agent has started or ended typing.
    /// - Parameter threadId: The unique identifier of thread where typing state changed.
    func onAgentTyping(_ isTyping: Bool, threadId: UUID)
    
    /// Callback to be called when the custom fields are set for a contact.
    func onContactCustomFieldsSet()
    
    /// Callback to be called when the custom fields are set for a customer.
    func onCustomerCustomFieldsSet()
    
    /// Callback to be called when an error occurs.
    /// - Parameter error: The error.
    func onError(_ error: Error)
    
    /// Callback to be called when refreshing the token has failed.
    func onTokenRefreshFailed()
    
    /// Callback to be called when a welcome message proactive action has been received.
    func onWelcomeMessageReceived()
    
    /// Callback to be called when a custom popup proactive action is received.
    /// - Parameters:
    ///   -  data: The proactive popup action data
    ///   - actionId: The unique identifier of the action.
    func onProactivePopupAction(data: [String: Any], actionId: UUID)
}

// MARK: - Default Implementation

public extension CXoneChatDelegate {
    
    func onConnect() { }
    func onUnexpectedDisconnect() { }
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
