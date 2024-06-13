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

/// The handler for the chat events.
public protocol CXoneChatDelegate: AnyObject {
    
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
    
    /// Callback to be called when a custom message is received.
    ///
    /// - Parameter messageData: The data of the custom plugin message.
    func onCustomEventMessage(_ messageData: Data)
    
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
    
    /// Callback to be called when a custom popup proactive action is received.
    /// 
    /// - Parameters:
    ///   -  data: The proactive popup action data
    ///   - actionId: The unique identifier of the action.
    func onProactivePopupAction(data: [String: Any], actionId: UUID)
}

// MARK: - Default Implementation

public extension CXoneChatDelegate {
    
    func onUnexpectedDisconnect() { }
    func onChatUpdated(_ state: ChatState, mode: ChatMode) { }
    func onThreadUpdated(_ chatThread: ChatThread) { }
    func onThreadsUpdated(_ chatThreads: [ChatThread]) { }
    func onCustomEventMessage(_ messageData: Data) { }
    func onAgentTyping(_ isTyping: Bool, threadId: UUID) { }
    func onContactCustomFieldsSet() { }
    func onCustomerCustomFieldsSet() { }
    func onError(_ error: Error) { }
    func onTokenRefreshFailed() { }
    func onProactivePopupAction(data: [String: Any], actionId: UUID) { }
}
