@testable import CXoneChatSDK
import XCTest


class CXoneChatDelegateTests: XCTestCase {
    
    // MARK: - Properties
    
    private let CXoneChat = CXoneChatSDK.CXoneChat(socketService: SocketServiceMock())
    private var currentExpectation = XCTestExpectation(description: "")
    
    private let chatThread = ChatThread(id: UUID())
    private let message = MessageDTO(
        idOnExternalPlatform: UUID(),
        threadIdOnExternalPlatform: UUID(),
        contentType: .text(""),
        createdAt: Date(),
        attachments: [],
        direction: .inbound,
        userStatistics: .init(seenAt: nil, readAt: nil),
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
