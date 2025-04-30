//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
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

import Combine
import Foundation

class SocketDelegateManager {
    
    class Reference {
        weak var value: CXoneChatDelegate?

        init(value: CXoneChatDelegate? = nil) {
            self.value = value
        }
    }

    // MARK: - Properties
    
    private var delegates = [Reference]()

    func add(delegate: CXoneChatDelegate) {
        LogManager.trace("Add a delegate - \(String(describing: delegate))")
        
        delegates.append(delegate)
    }

    func remove(delegate: CXoneChatDelegate) {
        LogManager.trace("Remove a delegate - \(String(describing: delegate))")
        
        delegates.remove(delegate)
    }
}

// MARK: - Extend Array for convenience

private extension Array where Element == SocketDelegateManager.Reference {
    
    func contains(_ value: CXoneChatDelegate) -> Bool {
        contains { element in
            element.value === value
        }
    }

    mutating func append(_ value: CXoneChatDelegate) {
        if contains(value) {
            LogManager.trace("Unable to add a delegate - already exists")
        } else {
            append(SocketDelegateManager.Reference(value: value))
            
            LogManager.trace("Delegate added")
        }
    }

    mutating func remove(_ value: CXoneChatDelegate) {
        self = filter { element in
            if let element = element.value {
                return element !== value
            } else {
                return false
            }
        }
    }

    func forEach(_ perform: (CXoneChatDelegate) -> Void) {
        forEach { (value: Element) in
            if let value = value.value {
                perform(value)
            }
        }
    }
}

// MARK: - Implement CXoneChatDelegate

extension SocketDelegateManager: CXoneChatDelegate {
    
    func onUnexpectedDisconnect() {
        delegates.forEach { $0.onUnexpectedDisconnect() }
    }

    func onChatUpdated(_ state: ChatState, mode: ChatMode) { 
        delegates.forEach { $0.onChatUpdated(state, mode: mode) }
    }

    func onThreadUpdated(_ chatThread: ChatThread) { 
        delegates.forEach { $0.onThreadUpdated(chatThread) }
    }

    func onThreadsUpdated(_ chatThreads: [ChatThread]) { 
        delegates.forEach { $0.onThreadsUpdated(chatThreads) }
    }

    func onCustomEventMessage(_ messageData: Data) { 
        delegates.forEach { $0.onCustomEventMessage(messageData) }
    }
    
    func onAgentTyping(_ isTyping: Bool, agent: Agent, threadId: UUID) {
        delegates.forEach { $0.onAgentTyping(isTyping, agent: agent, threadId: threadId) }
    }

    func onContactCustomFieldsSet() { 
        delegates.forEach { $0.onContactCustomFieldsSet() }
    }

    func onCustomerCustomFieldsSet() { 
        delegates.forEach { $0.onCustomerCustomFieldsSet() }
    }

    func onError(_ error: Error) { 
        delegates.forEach { $0.onError(error) }
    }

    func onTokenRefreshFailed() { 
        delegates.forEach { $0.onTokenRefreshFailed() }
    }

    func onProactivePopupAction(data: [String: Any], actionId: UUID) { 
        delegates.forEach { $0.onProactivePopupAction(data: data, actionId: actionId) }
    }
}
