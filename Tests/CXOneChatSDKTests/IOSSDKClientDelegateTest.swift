//
//  IOSSDKClienteDelegateTest.swift
//  
//
//  Created by kjoe on 1/10/22.
//

import XCTest
@testable import CXOneChatSDK
@available(iOS 13.0, *)
class IOSSDKClientDelegateTest: XCTestCase, CXOneChatController {
    func onMessageReceivedFromOtherThread(message: Message) {
    }
    func didReceiveMetaData() {
    }
    
    func didReceiveThreads(threads: [ThreadObject]) {
        assert(threads.isEmpty == false)
    }
    
    func clientAuthorized() {
        print("authorized")
    }


    
    func configurationLoaded(config: ChannelConfiguration) {
    }
    
    func configurationLoaded() { }
        
    func loadedMoreMessage() {
    }
    
    func recoverThreadFailed() {}

    func archivedThread() {
    }
    
    func didReceiveData(data: Data) {
        dataExpectation.fulfill()
    }
    
    
    var threadAddedExpectation = XCTestExpectation()
    var messageAddedToThreadExpectation = XCTestExpectation()
    var messageAddedToChatViewExpectation = XCTestExpectation()
    var typingDidStartExpectation = XCTestExpectation()
    var typingDidEndExpectation = XCTestExpectation()
    var agentDidReadMessagesExpectation = XCTestExpectation()
    var agentDidChangeExpectation = XCTestExpectation()
    var dataExpectation = XCTestExpectation()

    
    var webSocketClient = CXOneChat.shared
    var currentThreadId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4_061DFBEB-E8E4-4631-9F1A-4B257B10EE76"

    override func setUpWithError() throws {
//        self.webSocketClient.brand =  1386
//        self.webSocketClient.channelId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
//        self.webSocketClient.user = Customer(senderId: "3b89fa26-8cdb-4a5e-a012-41881fada590", displayName: "")
        self.webSocketClient.connect(environment: .NA1, brandId: 1386, channelId: "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4")
       // webSocketClient.delegate = self
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
//    func testAssigneeChanged() {
//        let user = User(senderId: "idis", displayName: "yj")
//        agentDidChangeExpectation = expectation(description: "Agent did Change")
//        webSocketClient.createThread( threadName: "my thread", postId: "id")
//        webSocketClient.assigneeDidChange(currentThreadId, user: user)
//        wait(for: [agentDidChangeExpectation], timeout: 3.0)
//    }
    
//    func testDidReceiveMessageWasRead() {
//        agentDidReadMessagesExpectation = expectation(description: "agend read received message")
//        webSocketClient.didReceiveMessageWasRead("currentThread")
//        wait(for: [agentDidReadMessagesExpectation], timeout: 1.0)
//    }
    func testAvatarWith0000ID() {
        let customer = Customer(senderId: "000000", displayName: "YJ")
        let avatar = webSocketClient.getAvatarFor(sender: customer)
        XCTAssertNotNil(avatar)
        XCTAssertTrue(avatar.initials == "SS")
    }
    func testAvatarWith000000IDISNotDifferentFromSS() {
        let customer = Customer(senderId: "000000", displayName: "YJ")
        let avatar = webSocketClient.getAvatarFor(sender: customer)
        XCTAssertNotNil(avatar)
        XCTAssertFalse(avatar.initials == "YJ")
    }
    
    func testAvatarStringIDEqualsDisplayNameInitials() {
        let customer = Customer(senderId: "asdas", displayName: "YJ")
        let avatar = webSocketClient.getAvatarFor(sender: customer)
        XCTAssertNotNil(avatar)
        XCTAssertTrue(avatar.initials == "YY", avatar.initials)
    }

    func threadAdded() {
        threadAddedExpectation.fulfill()
    }
    
    func messageAddedToThread(_ message: Message) {
        messageAddedToThreadExpectation.fulfill()
    }
    
    func messageAddedToChatView(_ message: Message) {
        messageAddedToChatViewExpectation.fulfill()
    }
    
    func typingDidStart() {
        typingDidStartExpectation.fulfill()
    }
    
    func typingDidEnd() {
        typingDidEndExpectation.fulfill()
    }
    
    func agentDidReadMessage(thread: String) {
        agentDidChangeExpectation = expectation(description: "agend read received message")
        agentDidReadMessagesExpectation.fulfill()
    }
    
    func agentDidChange() {
        agentDidChangeExpectation.fulfill()
    }
    
    func contactFieldsWereSet() {
        
    }
    
    func customFieldsWereSet() {
        
    }
    
    func didReceiveError() {
        
    }

}
