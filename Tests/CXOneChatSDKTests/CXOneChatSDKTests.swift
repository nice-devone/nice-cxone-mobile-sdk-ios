import XCTest
@testable import CXOneChatSDK

// Tests for the WebSocket
@available(iOS 13.0, *)
class CXOneChatSDKTests: XCTestCase, CXOneChatDelegate {
   
	// MARK: - Variables
	var webSocketClient = CXOneChat.shared
	var currentThreadId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4_061DFBEB-E8E4-4631-9F1A-4B257B10EE76"
    let uuid = UUID(uuidString: "3b89fa26-8cdb-4a5e-a012-41881fada590".uppercased()) ?? UUID()
    
    var configuration = URLSessionConfiguration.default
    
    var urlSession: URLSession!
	
	override func setUp() {
        XCTAssertTrue(uuid.uuidString == "3b89fa26-8cdb-4a5e-a012-41881fada590".uppercased())
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession.init(configuration: configuration)
        self.webSocketClient.connect(environment: .NA1, brandId: 1386, channelId: "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4")
		self.webSocketClient.socketService.delegate = self
	}
    
    override func tearDownWithError() throws {
        webSocketClient.disconnect()
    }

	// MARK: - Expectations
	var createThreadExpectation = XCTestExpectation()
	var uploadImageExpecation = XCTestExpectation()
	var typingDidStartExpectation = XCTestExpectation()
	var typingDidEndExpectation = XCTestExpectation()
	var sendChatExpecation = XCTestExpectation()
	var retrieveThreadMessagesExpectation = XCTestExpectation()
	var pingExpectation = XCTestExpectation()
	var readMessageExpectation = XCTestExpectation()
	var assigneeDidChangeExpectation = XCTestExpectation()
    var closeConnectionExpectation = XCTestExpectation()
    var configSuccessExpectation = XCTestExpectation()
    var configFailExpectation = XCTestExpectation()
    var pingfulfilled = false
    var closeFullfilled = false

	// MARK: - Tests
//	func testCreateThread() {
//        retrieveThreadMessagesExpectation = expectation(description: "ThreadWasCreatedSuccessfully")
//		DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//            try! self.webSocketClient.createThread()
//		})
//		wait(for: [retrieveThreadMessagesExpectation], timeout: TimeInterval(5))
//	}
	
//	func testMessageRead() {
//		readMessageExpectation = expectation(description: "Message was read")
//		DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//			self.webSocketClient.messageWasRead(thread: self.currentThreadId)
//		})
//		wait(for: [readMessageExpectation], timeout: TimeInterval(20))
//	}
	
//	func testUploadImage() {
//		uploadImageExpecation = expectation(description: "Image was uploaded successfully")
//        let image = UIImage(named: "placeholder", in: .module, with: nil)
//        let nImage = try! XCTUnwrap(image)
//        self.webSocketClient.send(message: "HELLO WORLD!",
//                                  with: [nImage],
//                                  in: currentThreadId)
//		wait(for: [uploadImageExpecation], timeout: TimeInterval(20))
//	}
	
//	func testTypingDidStart() {
//		typingDidStartExpectation = expectation(description: "Typing did start")
//		self.webSocketClient.textDidBeginEditing()
//		wait(for: [typingDidStartExpectation], timeout: .XCTEST_DEFAULT_WAIT_TIMEOUT)
//	}
	
//	func testTypingDidEnd() {
//		typingDidEndExpectation = expectation(description: "Typing did end")
//		DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//			self.webSocketClient.textDidEndEditing()
//		})
//		wait(for: [typingDidEndExpectation], timeout: .XCTEST_DEFAULT_WAIT_TIMEOUT)
//	}
	
	// Send a message to a new thread.
//	func testSendChat() {
//		sendChatExpecation = expectation(description: "Message was sent successfully")
//		DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//			try! self.webSocketClient.sendMessage(message: "Hello World")
//		})
//		wait(for: [sendChatExpecation], timeout: TimeInterval(.XCTEST_DEFAULT_WAIT_TIMEOUT))
//	}
	
    // TODO: Re-enable and fix this test
	// Retrieves a thread.
//	func testRetrieveThreadMessages() {
//		retrieveThreadMessagesExpectation = expectation(description: "Thread was retrieve successfully")
//		DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {

//			self.webSocketClient.retrieveThread(threadId: self.currentThreadId)

//            self.webSocketClient.retrieveThread(threadId: self.uuid.uuidString)

//		})
//		wait(for: [retrieveThreadMessagesExpectation], timeout: TimeInterval(.XCTEST_DEFAULT_WAIT_TIMEOUT))
//	}
	
		/// Sends a ping to the WebSocket
	
	
	var setCustomFieldsExpectation = XCTestExpectation()
	
//	func testSetContactCustomFields() {
//		setCustomFieldsExpectation = expectation(description: "Custom field has been set")
//		DispatchQueue.main.async {
//           try! self.webSocketClient.setCustomerCustomFields(customFields: [CustomField(ident: "email", value: "hello@gmail.com"),
//                                                                CustomField(ident: "firstname", value: "hello"),
//                                                                CustomField(ident: "state", value: "CA|California")])
//		}
//		wait(for: [setCustomFieldsExpectation], timeout: .XCTEST_DEFAULT_WAIT_TIMEOUT)
//	}
//	
    // TODO: Re-enable and fix this test
//	func testSetConsumerCustomFields() {
//		setCustomFieldsExpectation = expectation(description: "Custom field has been set")
//		DispatchQueue.main.async {
//			self.webSocketClient.setConsumerCustomFields(customFields: [CustomField(ident: "test", value: "Davidson")])
//		}
//		wait(for: [setCustomFieldsExpectation], timeout: .XCTEST_DEFAULT_WAIT_TIMEOUT)
//	}
    
//    func testCloseConnection(){
//        closeConnectionExpectation = expectation(description: "connection Closed")
//        self.webSocketClient.disconnect()
//        
//        wait(for: [closeConnectionExpectation], timeout: .XCTEST_DEFAULT_WAIT_TIMEOUT)
//    }
    
    func testGetDataFromValidCodable() {
        let jsonString = """
        {
        "eventId": "String",
        "eventType": null,
        "postback": {
        "eventType": "AuthorizeConsumer"
        }
        }
        """
        guard let data = jsonString.data(using: .utf8) else {return}
        let val: GenericPost? = webSocketClient.decodeData(data)
        let newVal = try! XCTUnwrap(val)
        XCTAssertTrue(newVal.eventId == "String")
    }
    
    func testGetDataFromInvalidCodable() {
        let jsonString = """
        {
        "eventId": null,
        "eventType": "string",
        "postback": null
        }
        """
        guard let data = jsonString.data(using: .utf8) else {return}
        let val: GenericPost? = webSocketClient.decodeData(data)
        XCTAssertNil(val)
    }
    
//    func testHandleMessage() {
//        let dataMessage = loadStubFromBundle(withName: "MessageReadEventByAgent", extension: "json")
//        let json = String(data: dataMessage, encoding: .utf8)
//        let jsonString = """
//        {
//            "eventId": "string",
//            "eventType": null,
//            "postback": {
//                    "eventType": "MessageReadChanged"
//            }
//        }
//        """
//
//        let data = jsonString.data(using: .utf8)
//        let message = try! JSONDecoder().decode(GenericPost.self, from: data!)
//        XCTAssertNotNil(message)
//        readMessageExpectation = expectation(description: "receiveMessageExpectation")
//        //XCTAssertTrue(self.webSocketClient.sdkService?.delegate == self)
//        let jsonObject = try! JSONDecoder().decode(MessageReadEventByAgent.self, from: dataMessage )
//        XCTAssertNotNil(jsonObject)
//        self.webSocketClient.handleMessage(message: json!)
//        wait(for: [readMessageExpectation], timeout: 1)
//    }
//    func testHandleMessageCaseInboxAsigneeChanged() {
//        let dataMessage = loadStubFromBundle(withName: "CaseInboxAssigneeChanged", extension: "json")
//        let json = String(data: dataMessage, encoding: .utf8)
//        let jsonString = """
//        {
//            "eventId": "string",
//            "eventType": null,
//            "postback": {
//                    "eventType": "CaseInboxAssigneeChanged"
//            }
//        }
//        """
//        
//        let data = jsonString.data(using: .utf8)
//        let message = try! JSONDecoder().decode(GenericPost.self, from: data!)
//        assigneeDidChangeExpectation = expectation(description: "assigneeDidChangeExpectation")
//        //XCTAssertTrue(self.webSocketClient.sdkService?.delegate == self)
//        self.webSocketClient.sdkService?.handleMessage(event: message, message: json!)
//        wait(for: [assigneeDidChangeExpectation], timeout: 1)
//    }
    
    func testloadChannelConfigurationSuccess() {
        let data = loadStubFromBundle(withName: "loadConfigResponse", extension: "json")
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url == URL(string: "\(Environment.NA1.chatURL)/1.0/brand/\(1386)/channel/chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4") else {
            throw CXOneChatError.invalidRequest
          }

            let response = HTTPURLResponse(url: URL(string: "\(Environment.NA1.chatURL)/1.0/brand/\(1386)/channel/chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
          return (response, data)
        }
//        webSocketClient.loadChannelConfiguration(session: urlSession)
//        XCTAssertNotNil(webSocketClient.channelConfig)
    }
    
    func testloadChannelConfigurationFail() {
        let data = Data()
        MockURLProtocol.requestHandler = { request in
          let response = HTTPURLResponse(url: URL(string: "\(Environment.NA1.chatURL)/1.0/brand/\(1386)/channel/chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
          return (response, data)
        }
//        webSocketClient.loadChannelConfiguration(session: urlSession)
//        XCTAssertNil(webSocketClient.channelConfig)
    }
		
	// MARK: -  Delegate Functions
	
	func didOpenConnection() {
	}
	
	func didCloseConnection() {
        if !closeFullfilled {
            closeFullfilled = true
            closeConnectionExpectation.fulfill()
        }        
	}
	
	func didReceiveMessage(_ message: MessagePostSuccess) {
		var fulfilled = false
		if !fulfilled {
			fulfilled = true
			sendChatExpecation.fulfill()
		}
	}
	
	func didReceiveData(_ message: Data) {
	}
	
	func didReceiveThread(_ thread: RetrievePostSuccess) {
		var fulfilled = false
		if !fulfilled {
			fulfilled = true
			retrieveThreadMessagesExpectation.fulfill()
		}
	}
	
	func didReceiveError(_ error: Error) {
	}
	
	func didSendMessage(_ message: Event) {
	}
	
	func didReceiveThreads(_ threads: [ThreadObject]) {
	}
	
	func typingDidStart() {
		
	}
	
	func typingDidEnd() {
		
	}
	
	func clientTypingDidStart() {
        var fulfilled = false
        if !fulfilled {
            fulfilled = true
            typingDidStartExpectation.fulfill()
        }
	}
	
	func clientTypingDidEnd() {
        var fulfilled = false
        if !fulfilled {
            fulfilled = true
            typingDidEndExpectation.fulfill()
        }
	}
	
	func didSendPing() {
		
		if !pingfulfilled {
            pingfulfilled = true
			pingExpectation.fulfill()
		}
	}
	
	func didUploadAttachments(_ message: Event, _ attachments: [Attachment]) {
        uploadImageExpecation.fulfill()
	}
	
	func imageDidUpload(_ url: String, _ error: Bool?) {
		var fulfilled = false
		if error != nil {
            
		} else {
			if !fulfilled {
				fulfilled = true
				uploadImageExpecation.fulfill()
			}
		}
	}
	
	func didSendMessageWasRead(_ thread: ThreadCodable) {
        readMessageExpectation = expectation(description: "Message was read")
		readMessageExpectation.fulfill()
	}
	
	func assigneeDidChange(_ thread: String, customer: Customer) {
        assigneeDidChangeExpectation = expectation(description: "assigneeDidChangeExpectation")
		assigneeDidChangeExpectation.fulfill()
	}
	
	func didReceiveMessageWasRead(_ thread: String) {
		readMessageExpectation.fulfill()
	}
    
    func refreshToken() {
    }
    
    func handleMessage(message: String) {
        print("message:", message)
        let event: GenericPost? = self.decodeData( Data(message.utf8))
        guard let event = event else {
            return
        }
        if let error = event.error {
            self.didReceiveError(error)
        }
        
        let messageData: Data = Data(message.utf8)
        let usePostBack: Bool = event.eventType == nil ? true : false
        switch usePostBack ? event.postback?.eventType : event.eventType {
        case .senderTypingEnded:
            self.typingDidEnd()
        case .senderTypingStarted:
            self.typingDidStart()
        case .messageCreated:
            retrieveThreadMessagesExpectation.fulfill()
        case .threadRecovered, .livechatRecovered:
            let decode: RetrievePostSuccess? = decodeData(messageData)
            self.didReceiveThread(decode!)
        case .messageReadChanged:
            let decoded: MessageReadEventByAgent? = decodeData(messageData)
            guard let decoded = decoded else { return }
            self.didReceiveMessageWasRead(decoded.data.message.threadId)
        case .contactInboxAssigneeChanged:
            let decoded: ContactInboxAssigneeChanged? = decodeData(messageData)
            guard let decoded = decoded else {    return  }
            let user = Customer(senderId: decoded.data.inboxAssignee.incontactId,
                            displayName: decoded.data.inboxAssignee.firstName + " " + decoded.data.inboxAssignee.surname)
            self.assigneeDidChange(decoded.data.case.threadId, customer: user)
        case .threadListFetched:
            let threads = event.postback?.data?.threads?.map({
                ThreadObject(id: $0.id ?? "", idOnExternalPlatform: UUID(uuidString: $0.idOnExternalPlatform ?? "") ?? UUID(), messages: [], threadAgent: Customer(senderId: $0.author?.id ?? "", displayName: $0.author?.name ?? ""))
            })
            self.didReceiveThreads(threads ?? [])
        case .customerAuthorized:
            self.clientAuthorized()
        case .moreMessagesLoaded:
            let decode: LoadMoreMessagesResponse? = decodeData(messageData)
            self.addMessages(messages: decode?.postback.data.messages ?? [])
        case .archiveThread:
            self.threadArchived()
        case .tokenRefreshed:
            break
        case .threadMetadataLoaded:
            let decode: LoadMetadatPost? = decodeData(messageData)
            guard let lastMessage = decode?.postback?.data?.lastMessage else {return}
            self.addlastMessageToThread(message: lastMessage)
        default:
            break
        }
    }
    
    func addlastMessageToThread(message: LastMessage) {
    }
    
    func threadArchived() {}
    
    
    func configurationLoaded(config: ChannelConfiguration) {
        configSuccessExpectation.fulfill()
    }
    
    func consumerContactFieldsWereSet() { }

    
    func addMessages(messages: [MessagePostback]) { }
    
    func contactFieldsWereSet() {}
    
    func clientAuthorized() {}
    
    func customFieldsWereSet() {
        setCustomFieldsExpectation.fulfill()
    }
	
    internal func decodeData<T>(_ data: Data) -> T? where T: Codable {
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
                let anotherError = try? JSONDecoder().decode(ServerError.self, from: data)
                guard let anotherError = anotherError else {return nil}
            self.didReceiveError(anotherError)
            return nil
        }
    }
}

extension TimeInterval {
	static let XCTEST_DEFAULT_WAIT_TIMEOUT = Self(10)
}

