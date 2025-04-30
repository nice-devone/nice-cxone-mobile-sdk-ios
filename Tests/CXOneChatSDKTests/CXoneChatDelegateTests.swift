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

@testable import CXoneChatSDK
import XCTest

class CXoneChatDelegateTests: CXoneXCTestCase {
    
    func testUnexpectedDisconnectCalled() async {
        currentExpectation = XCTestExpectation(description: "`UnexpectedDisconnect` delegate method called properly")
        
        CXoneChat.socketDelegateManager.onUnexpectedDisconnect()

        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testChatUpdatedCalled() async {
        currentExpectation = XCTestExpectation(description: "")
        
        CXoneChat.socketDelegateManager.onChatUpdated(.connected, mode: .singlethread)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testThreadUpdatedCalled() async {
        currentExpectation = XCTestExpectation(description: "")
        
        CXoneChat.socketDelegateManager.onThreadUpdated(MockData.getThread())

        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testThreadsUpdatedCalled() async {
        currentExpectation = XCTestExpectation(description: "")
        
        CXoneChat.socketDelegateManager.onThreadsUpdated([MockData.getThread()])

        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testCustomEventMessageCalled() async {
        currentExpectation = XCTestExpectation(description: "")
        
        CXoneChat.socketDelegateManager.onCustomEventMessage(Data())
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testProactivePopupActionCalled() async {
        currentExpectation = XCTestExpectation(description: "")
        
        CXoneChat.socketDelegateManager.onProactivePopupAction(data: [:], actionId: UUID())
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testOnAgentTypingInvokesDefaultImplementation() async {
        currentExpectation = XCTestExpectation(description: "")
        
        CXoneChat.socketDelegateManager.onAgentTyping(true, agent: AgentMapper.map(MockData.agent), threadId: UUID())
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testOnContactCustomFieldsSetDefaultImplementationCalled() async {
        currentExpectation = XCTestExpectation(description: "")
        
        CXoneChat.socketDelegateManager.onContactCustomFieldsSet()
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testOnCustomerCustomFieldsSetDefaultImplementationCalled() async {
        currentExpectation = XCTestExpectation(description: "")
        
        CXoneChat.socketDelegateManager.onCustomerCustomFieldsSet()
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testOnErrorDefaultImplementationCalled() async {
        currentExpectation = XCTestExpectation(description: "")
        
        CXoneChat.socketDelegateManager.onError(CXoneChatError.attachmentError)
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testOnTokenRefreshFailedDefaultImplementationCalled() async {
        currentExpectation = XCTestExpectation(description: "")
        
        CXoneChat.socketDelegateManager.onTokenRefreshFailed()
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
    
    func testOnProactivePopupActionDefaultImplementationCalled() async {
        currentExpectation = XCTestExpectation(description: "")
        
        CXoneChat.socketDelegateManager.onProactivePopupAction(data: [:], actionId: UUID())
        
        await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
}
