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

@testable import CXoneChatSDK
import XCTest

class CXoneChatDelegateTests: CXoneXCTestCase {
    
    func testOnConnectDefaultImplementationCalled() {
        CXoneChat.delegate?.onConnect()
    }
    
    func testOnUnexpectedDisconnectDefaultImplementationCalled() {
        CXoneChat.delegate?.onUnexpectedDisconnect()
    }
    
    func testOnThreadLoadDefaultImplementationCalled() {
        CXoneChat.delegate?.onThreadLoad(ChatThreadMapper.map(MockData.getThread()))
    }
    
    func testOnThreadArchiveDefaultImplementationCalled() {
        CXoneChat.delegate?.onThreadArchive()
    }
    
    func testOnThreadsLoadDefaultImplementationCalled() {
        CXoneChat.delegate?.onThreadsLoad([])
    }
    
    func testOnThreadInfoLoadDefaultImplementationCalled() {
        CXoneChat.delegate?.onThreadInfoLoad(ChatThreadMapper.map(MockData.getThread()))
    }
    
    func testOnThreadUpdateDefaultImplementationCalled() {
        CXoneChat.delegate?.onThreadUpdate()
    }
    
    func testOnLoadMoreMessagesDefaultImplementationCalled() {
        CXoneChat.delegate?.onLoadMoreMessages([])
    }
    
    func testOnNewMessageDefaultImplementationCalled() {
        CXoneChat.delegate?.onNewMessage(MessageMapper.map(MockData.getMessage(threadId: UUID(), isSenderAgent: false)))
    }
    
    func testOnCustomPluginMessageDefaultImplementationCalled() {
        CXoneChat.delegate?.onCustomPluginMessage([])
    }
    
    func testOnAgentChangeDefaultImplementationCalled() {
        CXoneChat.delegate?.onAgentChange(AgentMapper.map(MockData.agent), for: UUID())
    }
    
    func testOnAgentReadMessageDefaultImplementationCalled() {
        CXoneChat.delegate?.onAgentReadMessage(threadId: UUID())
    }
    
    func testOnAgentTypingDefaultImplementationCalled() {
        CXoneChat.delegate?.onAgentTyping(true, threadId: UUID())
    }
    
    func testOnContactCustomFieldsSetDefaultImplementationCalled() {
        CXoneChat.delegate?.onContactCustomFieldsSet()
    }
    
    func testOnCustomerCustomFieldsSetDefaultImplementationCalled() {
        CXoneChat.delegate?.onCustomerCustomFieldsSet()
    }
    
    func testOnErrorDefaultImplementationCalled() {
        CXoneChat.delegate?.onError(CXoneChatError.attachmentError)
    }
    
    func testOnTokenRefreshFailedDefaultImplementationCalled() {
        CXoneChat.delegate?.onTokenRefreshFailed()
    }
    
    func testOnWelcomeMessageReceivedDefaultImplementationCalled() {
        CXoneChat.delegate?.onWelcomeMessageReceived()
    }
    
    func testOnProactivePopupActionDefaultImplementationCalled() {
        CXoneChat.delegate?.onProactivePopupAction(data: [:], actionId: UUID())
    }
}
