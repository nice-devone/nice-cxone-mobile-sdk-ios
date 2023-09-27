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

class CXoneChatDelegateTests: XCTestCase {
    
    // MARK: - Properties
    
    private let socketService = SocketServiceMock()
    private lazy var CXoneChat = CXoneChatSDK.CXoneChat(socketService: socketService)
    private var currentExpectation = XCTestExpectation(description: "")
    
    private let chatThread = ChatThread(id: UUID())
    private lazy var message = MessageDTO(
        idOnExternalPlatform: UUID(),
        threadIdOnExternalPlatform: UUID(),
        contentType: .text(MessagePayloadDTO(text: "", postback: nil)),
        createdAt: socketService.dateProvider.now,
        attachments: [],
        direction: .inbound,
        userStatistics: UserStatisticsDTO(seenAt: nil, readAt: nil),
        authorUser: nil,
        authorEndUserIdentity: nil
    )
    let agent = AgentDTO(
        id: 123,
        inContactId: "",
        emailAddress: nil,
        loginUsername: "kjoe",
        firstName: "name",
        surname: "surname",
        nickname: nil,
        isBotUser: false,
        isSurveyUser: false,
        imageUrl: ""
    )
    
    // MARK: - Tests
    
    func testOnConnectDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onConnect()
    }
    
    func testOnUnexpectedDisconnectDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onUnexpectedDisconnect()
    }
    
    func testOnThreadLoadDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onThreadLoad(chatThread)
    }
    
    func testOnThreadArchiveDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onThreadArchive()
    }
    
    func testOnThreadsLoadDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onThreadsLoad([])
    }
    
    func testOnThreadInfoLoadDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onThreadInfoLoad(chatThread)
    }
    
    func testOnThreadUpdateDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onThreadUpdate()
    }
    
    func testOnLoadMoreMessagesDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onLoadMoreMessages([])
    }
    
    func testOnNewMessageDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onNewMessage(MessageMapper.map(message))
    }
    
    func testOnCustomPluginMessageDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onCustomPluginMessage([])
    }
    
    func testOnAgentChangeDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onAgentChange(AgentMapper.map(agent), for: UUID())
    }
    
    func testOnAgentReadMessageDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onAgentReadMessage(threadId: UUID())
    }
    
    func testOnAgentTypingDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onAgentTyping(true, threadId: UUID())
    }
    
    func testOnContactCustomFieldsSetDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onContactCustomFieldsSet()
    }
    
    func testOnCustomerCustomFieldsSetDefaultImplementationCalled() { 
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onCustomerCustomFieldsSet()
    }
    
    func testOnErrorDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onError(CXoneChatError.attachmentError)
    }
    
    func testOnTokenRefreshFailedDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onTokenRefreshFailed()
    }
    
    func testOnWelcomeMessageReceivedDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onWelcomeMessageReceived()
    }
    
    func testOnProactivePopupActionDefaultImplementationCalled() {
        CXoneChat.delegate = self
        
        CXoneChat.delegate?.onProactivePopupAction(data: [:], actionId: UUID())
    }
}

// MARK: - CXoneChatDelegate

extension CXoneChatDelegateTests: CXoneChatDelegate {
    
}
