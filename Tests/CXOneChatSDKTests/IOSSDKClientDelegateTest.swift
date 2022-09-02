import XCTest
@testable import CXOneChatSDK
@available(iOS 13.0, *)
class IOSSDKClientDelegateTest: XCTestCase {
    func onMessageReceivedFromOtherThread(message: Message) {
    }
    func didReceiveMetaData() {
    }
    
    func didReceiveThreads(threads: [ChatThread]) {
        assert(threads.isEmpty == false)
    }
    
    func customerAuthorized() {
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
        try! self.webSocketClient.connect(environment: .NA1, brandId: 1386, channelId: "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4")
       // webSocketClient.delegate = self
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
//    func testAssigneeChanged() {
//        let user = User(senderId: "idis", displayName: "yj")
//        agentDidChangeExpectation = expectation(description: "Agent did Change")
//        webSocketClient.createThread( threadName: "my thread")
//        webSocketClient.assigneeDidChange(currentThreadId, user: user)
//        wait(for: [agentDidChangeExpectation], timeout: 3.0)
//    }
    
//    func testDidReceiveMessageWasRead() {
//        agentDidReadMessagesExpectation = expectation(description: "agend read received message")
//        webSocketClient.didReceiveMessageWasRead("currentThread")
//        wait(for: [agentDidReadMessagesExpectation], timeout: 1.0)
//    }
//    func testAvatarStringIDEqualsDisplayNameInitials() {
//        let customer = Customer(senderId: "asdas", displayName: "YJ")
//        let avatar = webSocketClient.getAvatarFor(sender: customer)
//        XCTAssertNotNil(avatar)
//        XCTAssertTrue(avatar.initials == "YY", avatar.initials)
//    }



}
