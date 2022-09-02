import XCTest
@testable import CXOneChatSDK

// Tests for the WebSocket
@available(iOS 13.0, *)
class CXOneChatTest: XCTestCase {
   
	// MARK: - Variables
    var webSocketClient: CXOneChat!
	var currentThreadId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4_061DFBEB-E8E4-4631-9F1A-4B257B10EE76"
    let uuid = UUID(uuidString: "3b89fa26-8cdb-4a5e-a012-41881fada590".uppercased()) ?? UUID()
    let socketService = SocketServiceMock()
    var configuration = URLSessionConfiguration.default
    
    var urlSession: URLSession!
	
	override func setUp() {
        //CXOneChat(socketService: SocketServiceMock())
        XCTAssertTrue(uuid.uuidString == "3b89fa26-8cdb-4a5e-a012-41881fada590".uppercased())
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession.init(configuration: configuration)
        MockURLProtocol.requestHandler = { _ in

            let response = HTTPURLResponse(url: URL(string: "https://channels-de-na1.niceincontact.com/chat/1.0/brand/1386/channel/chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4/attachment")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
          return (response, Data())
        }
        webSocketClient =  CXOneChatMock(socketService: socketService, session: urlSession) 
        webSocketClient.destinationId = UUID()
        
        webSocketClient.channelConfig = ChannelConfiguration(settings: ChannelSettings(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: false), isAuthorizationEnabled: false)
        try! self.webSocketClient.connect(environment: .NA1, brandId: 1386, channelId: "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4")
	}
    
    override func tearDownWithError() throws {
        webSocketClient.disconnect()
    }
    
	// MARK: - Tests
	func testCreateThreadThrowsWithoutConnected() {
        (webSocketClient as! CXOneChatMock).isConected = false
        XCTAssertThrowsError(try webSocketClient.createThread())
	}
    
    func testCreateThreadNotThrowError() {
        (webSocketClient as! CXOneChatMock).isConected = true
        XCTAssertNoThrow(try webSocketClient.createThread())
    }
    
    func testCreateThreadThrowunsUpportedChannelConfig() {
        webSocketClient.channelConfig = ChannelConfiguration(settings: ChannelSettings(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: true), isAuthorizationEnabled: false)
        webSocketClient.threads.append(ChatThread(idOnExternalPlatform: UUID()))
        XCTAssertThrowsError(try webSocketClient.createThread(), "error unsuported chanel config", { error in
            XCTAssertEqual(error.localizedDescription, CXOneChatError.unsupportedChannelConfig.localizedDescription)
        })
    }
    
    
    func testloadChannelConfigurationSuccess() {
        let expectation = expectation(description: "Expectation")
        let result:( (Result<ChannelConfiguration, Error>) -> Void) = { resp in
            switch resp {
            case .failure(let error):
                XCTFail(error.localizedDescription)
            case .success(let config):
                XCTAssertFalse(config.settings.hasMultipleThreadsPerEndUser)
                expectation.fulfill()
            }
        }
        let data = loadStubFromBundle(withName: "ChannelConfiguration", extension: "json")
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url == URL(string: "\(Environment.NA1.chatURL)/1.0/brand/\(1386)/channel/chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4") else {
            throw CXOneChatError.invalidRequest
          }

            let response = HTTPURLResponse(url: URL(string: "\(Environment.NA1.chatURL)/1.0/brand/\(1386)/channel/chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
          return (response, data)
        }
        XCTAssertNoThrow(try webSocketClient.getChannelConfiguration(environment: .NA1, brandId: 1386, channelId: "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4", completion: result))
        wait(for: [expectation], timeout: 1.0)
    }
    func testloadChannelConfigurationFailWithNotValidData() {
        let expectation = expectation(description: "Expectation")
        let result:( (Result<ChannelConfiguration, Error>) -> Void) = { resp in
            switch resp {
            case .failure:
                expectation.fulfill()
            case .success:
                XCTFail("unexpected success")
            }
        }
        let data = Data()
        MockURLProtocol.requestHandler = { request in
          let response = HTTPURLResponse(url: URL(string: "\(Environment.NA1.chatURL)/1.0/brand/\(1386)/channel/chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
          return (response, data)
        }
        XCTAssertNoThrow(try webSocketClient.getChannelConfiguration(environment: .NA1, brandId: 1386, channelId: "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4", completion: result))
        wait(for: [expectation], timeout: 1.0)
    }
    func testloadChannelConfigurationFailWith500Error() {
        let expectation = expectation(description: "Expectation")
        let result:( (Result<ChannelConfiguration, Error>) -> Void) = { resp in
            switch resp {
            case .failure:
                expectation.fulfill()
            case .success:
                XCTFail("unexpected success")
            }
        }
        let data = Data()
        MockURLProtocol.requestHandler = { request in
          let response = HTTPURLResponse(url: URL(string: "\(Environment.NA1.chatURL)/1.0/brand/\(1386)/channel/chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
          return (response, data)
        }
        XCTAssertNoThrow(try webSocketClient.getChannelConfiguration(environment: .NA1, brandId: 1386, channelId: "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4", completion: result))
        wait(for: [expectation], timeout: 1.0)
    }
    func testSetAuthCodeSuccess() {
        webSocketClient.setAuthCode(authCode: "Newcode")
        XCTAssertEqual(webSocketClient.authorizationCode, "Newcode")
        XCTAssertNotEqual(webSocketClient.authorizationCode, "")
    }
    func testSetAuthCodeFails() {
        webSocketClient.setAuthCode(authCode: "Newcode")
        XCTAssertNotEqual(webSocketClient.authorizationCode, "NewCode")
        XCTAssertNotEqual(webSocketClient.authorizationCode, "")
    }
    
    func testAuthCodeEmpty() {
        webSocketClient.authorizationCode = ""
        XCTAssertTrue(webSocketClient.authorizationCode.isEmpty)
    }
    
    func testCodeVerifier() {
        webSocketClient.setCodeVerifier(codeVerifier: "codeVeri")
        XCTAssertEqual(webSocketClient.codeVerifier, "codeVeri")
        XCTAssertNotEqual(webSocketClient.codeVerifier, "CodeVeri")
        XCTAssertFalse(webSocketClient.codeVerifier.isEmpty)
    }
    
    func testSetCustomerName() {
        let name = "Name"
        let lastname = "Lastname"
        webSocketClient.setCustomerName(firstName: name, lastName: lastname)
        XCTAssertEqual(webSocketClient.customer?.fullName, "\(name) \(lastname)")
    }
    
    func testSendping() {
        webSocketClient.ping()
        XCTAssertEqual((webSocketClient.socketService as! SocketServiceMock).pingNumber, 1)
    }
    
    func testLoadThreadsDoesNotThrows() {
        webSocketClient.channelConfig =  ChannelConfiguration(settings: ChannelSettings(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: false), isAuthorizationEnabled: false)
        let expectation = expectation(description: "closure Called")
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.loadThreads())
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadThreadThrowErrorWithSingleThreadConfig() {
        webSocketClient.channelConfig =  ChannelConfiguration(settings: ChannelSettings(hasMultipleThreadsPerEndUser: false, isProactiveChatEnabled: false), isAuthorizationEnabled: false)
        XCTAssertThrowsError(try webSocketClient.loadThreads(),"Error catched", { error in
            XCTAssertEqual(error.localizedDescription, CXOneChatError.unsupportedChannelConfig.localizedDescription)
        })
    }
    
    func testloadThread() {
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.loadThread())
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadThreadInfo() {
        let thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        webSocketClient.threads.append(thread)
        
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.loadThreadInfo(threadIdOnExternalPlatform: thread.idOnExternalPlatform))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    func testloadThreadFailsWithnewUUID() {
        let thread = ChatThread(idOnExternalPlatform: UUID())
        XCTAssertThrowsError(try webSocketClient.loadThreadInfo(threadIdOnExternalPlatform: thread.idOnExternalPlatform), "invalid thread", { error in
            XCTAssertEqual(error as! CXOneChatError, CXOneChatError.invalidThread)
        })
    }
    
    func testmarkThreadAsReadSuccess() {
        let thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        webSocketClient.threads.append(thread)
        
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.markThreadAsRead(threadIdOnExternalPlatform: thread.idOnExternalPlatform))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testReportTypingStarted() {
        let thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        webSocketClient.threads.append(thread)
        
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.reportTypingStart(threadIdOnExternalPlatform: thread.idOnExternalPlatform))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testReportTypingEnded() {
        let thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        webSocketClient.threads.append(thread)
        
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.reportTypingEnd(threadIdOnExternalPlatform: thread.idOnExternalPlatform))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    func testLoadMoreMessage() {
        var thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        let message = Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: thread.idOnExternalPlatform, messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "2022-07-31T21:22:47+00:00", attachments: [], direction: .inbound, userStatistics: UserStatistics())
        thread.messages.append(message)
        thread.scrollToken = "sdkfdg"
        webSocketClient.threads.append(thread)
        
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.loadMoreMessages(threadIdOnExternalPlatform: thread.idOnExternalPlatform))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    func testLoadMoreMessageFailsWithNoThread() {
        XCTAssertThrowsError(try webSocketClient.loadMoreMessages(threadIdOnExternalPlatform: UUID()), "error in load more Message", { error in
            XCTAssertTrue(error as! CXOneChatError == CXOneChatError.invalidThread)
        })
    }
    func testLoadMoreMessageFailsWithNotScrollToken() {
        let thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        webSocketClient.threads.append(thread)
        XCTAssertThrowsError(try webSocketClient.loadMoreMessages(threadIdOnExternalPlatform: thread.idOnExternalPlatform),"No more messages", { error in
            XCTAssertTrue(error as! CXOneChatError == CXOneChatError.noMoreMessages)
        })
    }
    func testLoadMoreMessageFailsWithNotValidDate() {
        var thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        thread.scrollToken = "scrollToken"
        webSocketClient.threads.append(thread)
        XCTAssertThrowsError(try webSocketClient.loadMoreMessages(threadIdOnExternalPlatform: thread.idOnExternalPlatform),"No more messages", { error in
            XCTAssertTrue(error as! CXOneChatError == CXOneChatError.invalidOldestDate)
        })
    }
    
    func testSendMessageSucced() {
        let thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        webSocketClient.threads.append(thread)
        
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.sendMessage(message: "an example message ", threadIdOnExternalPlatform: thread.idOnExternalPlatform))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testuploadAttachmentDoesNotThrow() async {
        let thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        webSocketClient.threads.append(thread)
        let data = loadStubFromBundle(withName: "AttachmentUpload", extension: "json")
        MockURLProtocol.requestHandler = { _ in

            let response = HTTPURLResponse(url: URL(string: "https://channels-de-na1.niceincontact.com/chat/1.0/brand/1386/channel/chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4/attachment")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
          return (response, data)
        }
        do {
            try await webSocketClient.sendMessageWithAttachments(message: "", at: thread.idOnExternalPlatform, with: [AttachmentUpload(attachmentData: Data(), mimeType: "image/jpg", fileName: "image1.jpg")])
        } catch {
            print(error.localizedDescription)
            XCTFail("unexpect thrown error")
        }
    }

    func testArchiveThreadThrowInvalidThreadError() {
        webSocketClient.channelConfig = ChannelConfiguration(settings: ChannelSettings(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true), isAuthorizationEnabled: true)
        XCTAssertThrowsError(try webSocketClient.archiveThread(threadIdOnExternalPlatform: UUID()), "invalid thread", { error in
            XCTAssertEqual(error as! CXOneChatError, .invalidThread)
        })
    }
    func testArchiveThreadRemoveFromList() {
        webSocketClient.channelConfig = ChannelConfiguration(settings: ChannelSettings(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true), isAuthorizationEnabled: true)
        var thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        thread.id = UUID().uuidString
        webSocketClient.threads.append(thread)
        var check = false
        let expectation = expectation(description: "archivedThread")
        socketService.messageSent = { _ in
            if !check {
                expectation.fulfill()
                check = true
            }
        }
        XCTAssertNoThrow(try webSocketClient.archiveThread(threadIdOnExternalPlatform: thread.idOnExternalPlatform))
        wait(for: [expectation], timeout: 1.0)

    }
    func testArchiveThreadSendToServerMessage() {
        webSocketClient.channelConfig = ChannelConfiguration(settings: ChannelSettings(hasMultipleThreadsPerEndUser: true, isProactiveChatEnabled: true), isAuthorizationEnabled: true)
        var thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        thread.id = UUID().uuidString        
        thread.messages.append(Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: thread.idOnExternalPlatform, messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "2022-07-31T21:22:47+00:00", attachments: [], direction: .inbound, userStatistics: UserStatistics()))
        webSocketClient.threads.append(thread)
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.archiveThread(threadIdOnExternalPlatform: thread.idOnExternalPlatform))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
	
		/// Sends a ping to the WebSocket
	
	
	var setCustomFieldsExpectation = XCTestExpectation()
	
	func testSetCustomerCustomFields() {
        let thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        webSocketClient.threads.append(thread)
        
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.setCustomerCustomFields(customFields: [CustomField(ident: "ident", value: "value")]))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
	}
	
     
	func testSetConsumerCustomFields() {
        let thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        webSocketClient.threads.append(thread)
        webSocketClient.contactId = "ContacId"
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.setContactCustomFields(customFields: [CustomField(ident: "ident", value: "value")], threadIdOnExternalPlatform: thread.idOnExternalPlatform))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
	}
    func testSetConsumerCustomFieldsWithoutContactIdThrowsError() {
        let thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        webSocketClient.threads.append(thread)
        XCTAssertThrowsError(try webSocketClient.setContactCustomFields(customFields: [CustomField(ident: "ident", value: "value")], threadIdOnExternalPlatform: thread.idOnExternalPlatform))
        
    }
    func testReportPageViewTitle() {
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.reportPageView(title: "PageView", uri: "uri"))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    func testReportChatWindowOpen() {
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.reportChatWindowOpen())
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    func testReportVisit() {
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.reportVisit())
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testReportConversion() {
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.reportConversion(conversionType: "", conversionValue: 2.0))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    func testReportCustomVisitorEvent() {
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.reportCustomVisitorEvent(eventType: "visitor", data: "Hi"))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    func testReportProActiveActionDisplay() {
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.reportProactiveActionDisplay(data: ProactiveActionDetails(actionId: UUID(), actionName: "Action1", actionType: .welcomeMessage)))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    func testReportProActiveActionClick() {
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.reportProactiveActionClick(data: ProactiveActionDetails(actionId: UUID(), actionName: "Action1", actionType: .welcomeMessage)))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    func testReportProActiveActionSuccess() {
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.reportProactiveActionSuccess(data: ProactiveActionDetails(actionId: UUID(), actionName: "Action1", actionType: .welcomeMessage)))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    func testReportProActiveActionFails() {
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.reportProactiveActionFail(data: ProactiveActionDetails(actionId: UUID(), actionName: "Action1", actionType: .customPopupBox)))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testExecuteTrigger() {
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        XCTAssertNoThrow(try webSocketClient.executeTrigger(triggerId: UUID()))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRegisterDeviceToken() {
        XCTAssertNoThrow(try webSocketClient.registerDeviceToken(deviceToken: Data()))
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
        let val: GenericEvent? = webSocketClient.decodeData(data)
        XCTAssertNil(val)
    }
    
    func testDidOpenConection() {
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        webSocketClient.didOpenConnection()
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
         
    }
    
    func testAssigneeChanged() {
        let thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        webSocketClient.threads.append(thread)
        let agentDidChangeExpectation = expectation(description: "Agent did Change")
        webSocketClient.onAgentChange = { _, _ in
            agentDidChangeExpectation.fulfill()
        }
        webSocketClient.assigneeDidChange(thread.idOnExternalPlatform, agent: Agent(id: 123, loginUsername: "kjoe", firstName: "", surname: "", isBotUser: false, isSurveyUser: false, imageUrl: ""))
        wait(for: [agentDidChangeExpectation], timeout: 1.0)
    }
    func testDidReceiveMessageWasRead() {
        let thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        webSocketClient.threads.append(thread)
        let agentDidReadMessagesExpectation = expectation(description: "agend read received message")
        webSocketClient.onAgentReadMessage = { _ in
            agentDidReadMessagesExpectation.fulfill()
        }
        webSocketClient.didReceiveMessageWasRead(thread.idOnExternalPlatform)
        wait(for: [agentDidReadMessagesExpectation], timeout: 1.0)
    }
    func testDidCloseConection() {
        let closeExpectation = expectation(description: "closed conecction")
        webSocketClient.onUnexpectedDisconnect = {
            closeExpectation.fulfill()
        }
        webSocketClient.didCloseConnection()
        wait(for: [closeExpectation], timeout: 1.0)
    }
    
    func testDidReceiveMessage() {
        let messageExpectation = expectation(description: "message")
        var thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        thread.id = UUID().uuidString
        webSocketClient.threads.append(thread)
        let message =  Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: thread.idOnExternalPlatform, messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "2022-07-31T21:22:47+00:00", attachments: [], direction: .inbound, userStatistics: UserStatistics())
        webSocketClient.onNewMessage = { _ in
            messageExpectation.fulfill()
        }
        let messageEvent = MessageCreatedEvent(eventId: UUID(), eventObject: EventObject(rawValue: "Message")!, eventType: .sendMessage, createdAt: "", data: MessageCreatedEventData(brand: Brand(id: 1386), channel: ChannelIdentifier(id: "1386"), case: Contact(id: UUID().uuidString, threadIdOnExternalPlatform: UUID(), status: .new, createdAt: ""), thread: Thread(idOnExternalPlatform: UUID()), message: message))
        webSocketClient.didReceiveMessage(message: messageEvent)
        wait(for: [messageExpectation], timeout: 1.0)
    }
    func testAddMessages() {
        let moreMessgeExpectation = expectation(description: "AddMore messages")
        let message =  Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: UUID(), messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "2022-07-31T21:22:47+00:00", attachments: [], direction: .inbound, userStatistics: UserStatistics())
        webSocketClient.onNewMessage = { _ in
            moreMessgeExpectation.fulfill()
        }
        webSocketClient.onLoadMoreMessages = { _ in
            moreMessgeExpectation.fulfill()
        }
        webSocketClient.addMessages(messages: [message], scrollToken: "asassd")
        wait(for: [moreMessgeExpectation], timeout: 1.0)
    }
    func testAddMessagesWithEmptyMessages() {
        let moreMessgeExpectation = expectation(description: "AddMore messages")
        
        webSocketClient.onNewMessage = { _ in
            moreMessgeExpectation.fulfill()
        }
        webSocketClient.onLoadMoreMessages = { _ in
            moreMessgeExpectation.fulfill()
        }
        webSocketClient.addMessages(messages: [], scrollToken: "asassd")
        wait(for: [moreMessgeExpectation], timeout: 1.0)
    }
    func testAddMessagesWithTwoMessages() {
        let moreMessgeExpectation = expectation(description: "AddMore messages")
        var thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        thread.id = UUID().uuidString
        webSocketClient.threads.append(thread)
        let message =  Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform:thread.idOnExternalPlatform, messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "2022-07-31T21:22:47+00:00", attachments: [], direction: .inbound, userStatistics: UserStatistics())
        let message2 = Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: thread.idOnExternalPlatform, messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "2022-07-31T21:22:57+00:00", attachments: [], direction: .inbound, userStatistics: UserStatistics())
        webSocketClient.onNewMessage = { _ in
            moreMessgeExpectation.fulfill()
        }
        webSocketClient.onLoadMoreMessages = { _ in
            moreMessgeExpectation.fulfill()
        }
        webSocketClient.addMessages(messages: [message,message2], scrollToken: "asassd")
        wait(for: [moreMessgeExpectation], timeout: 1.0)
    }
    func testThreadRecover() {
        let expectation = expectation(description: "loadthread exp")
        
        var thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        thread.id = UUID().uuidString
        webSocketClient.threads.append(thread)
        let message =  Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform:thread.idOnExternalPlatform, messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "2022-07-31T21:22:47+00:00", attachments: [], direction: .inbound, userStatistics: UserStatistics())
        let message2 = Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: thread.idOnExternalPlatform, messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "2022-07-31T21:22:57+00:00", attachments: [], direction: .inbound, userStatistics: UserStatistics())
        let event  = ThreadRecoveredEvent(eventId: UUID(), postback: ThreadRecoveredEventPostback(eventType: .recoverThread, data: ThreadRecoveredEventPostbackData(consumerContact: Contact(id: UUID().uuidString, threadIdOnExternalPlatform: UUID(), status: .new, createdAt: "2022-07-31T21:22:57+00:00"), messages: [message, message2], thread: ReceivedThreadData(id: UUID().uuidString, idOnExternalPlatform: thread.idOnExternalPlatform, channelId: "channel_1", threadName: "name", createdAt: "2022-07-31T21:22:57+00:00", updatedAt: "2022-07-31T21:22:57+00:00", canAddMoreMessages: true), messagesScrollToken: "toekn")))
        webSocketClient.onThreadLoad = { _ in
            expectation.fulfill()
        }
        webSocketClient.threadRecovered(event)
        wait(for: [expectation], timeout: 1.0)
    }
    func testDidReceiveErrorRecoveringThreadFaile() {
        let error = OperationError(errorCode: .recoveringThreadFailed, transactionId: "idsd", errorMessage: "RecoveringThreadFailed")
        let expectation = expectation(description: "Recovering Thread Failed")
        webSocketClient.onThreadLoadFail = {
            expectation.fulfill()
        }
        webSocketClient.didReceiveError(error)
        wait(for: [expectation], timeout: 1.0)
    }
    func testDidReceiveErrorReconnectFailed() {
        let error = OperationError(errorCode: .customerReconnectFailed, transactionId: "idsd", errorMessage: "reconnecFailed")
        let expectation = expectation(description: "Reconnect Failed")
        webSocketClient.onTokenRefreshFailed = {
            expectation.fulfill()
        }
        webSocketClient.didReceiveError(error)
        wait(for: [expectation], timeout: 1.0)
    }
    func testDidReceiveErrorTokenRefreshFailed() {
        let error = OperationError(errorCode: .tokenRefreshFailed, transactionId: "idsd", errorMessage: "token refresh Failed")
        let expectation = expectation(description: "Token Refresh Failed")
        webSocketClient.onTokenRefreshFailed = {
            expectation.fulfill()
        }
        webSocketClient.didReceiveError(error)
        wait(for: [expectation], timeout: 1.0)
    }
    func testDidReceiveError() {
        var check = false
        let error = CXOneChatError.serverError
        let expectation = expectation(description: "Error Received")
        webSocketClient.onError = { _ in
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        webSocketClient.didReceiveError(error)
        wait(for: [expectation], timeout: 1.0)
    }
    func testDidUploadAttachment() {
        let event = try! webSocketClient.createEvent(eventType: .sendMessage, eventData: EventData.sendMessageData(SendMessageEventData(thread: Thread(idOnExternalPlatform: UUID()), messageContent: MessageContent(type: .text, payload: MessagePayload(text: "message", elements: [])), idOnExternalPlatform: UUID(), consumer: CustomFieldsData(customFields: []), consumerContact: CustomFieldsData(customFields: []), attachments: [], browserFingerprint: BrowserFingerprint())))
        
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            XCTAssertTrue(!message.isEmpty)
            expectation.fulfill()
        }
        webSocketClient.didUploadAttachments(event)
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    func testAppendMessageToThreadDoesNotThrow() {
        var thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        thread.id = UUID().uuidString
        webSocketClient.threads.append(thread)
        XCTAssertEqual(webSocketClient.threads.count, 1)
        let message =  Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform:thread.idOnExternalPlatform, messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "2022-07-31T21:22:47+00:00", attachments: [], direction: .inbound, userStatistics: UserStatistics())
        XCTAssertNoThrow(try webSocketClient.appendMessageToThread(message: message))
        XCTAssertEqual(webSocketClient.threads.first?.messages.count, 1)
    }
    func testAddMessageToThreadThrows() {
        let message =  Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: UUID(), messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "2022-07-31T21:22:47+00:00", attachments: [], direction: .inbound, userStatistics: UserStatistics())
        XCTAssertThrowsError(try webSocketClient.appendMessageToThread(message: message))
    }
    func testSetThreadAgent() {
        var thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        thread.id = UUID().uuidString
        webSocketClient.threads.append(thread)
        XCTAssertEqual(webSocketClient.threads.count, 1)
        let agent = Agent(id: 123, loginUsername: "kjoe", firstName: "name", surname: "surname", isBotUser: false, isSurveyUser: false, imageUrl: "")
        webSocketClient.setThreadAgent(agent: agent, threadIdOnExternalPlatform: thread.idOnExternalPlatform)
        XCTAssertEqual(webSocketClient.threads.first?.threadAgent?.id, agent.id)
        XCTAssertEqual(webSocketClient.threads.first!.threadAgent!.fullName, agent.fullName)
    }
    func testSaveAccessToken() {
        let data = loadStubFromBundle(withName: "AccessToken", extension: "json")
        let decode = try! JSONDecoder().decode(AccessToken.self, from: data)
        let event = TokenRefreshedEvent(eventId: UUID(), postback: TokenRefreshedEventPostback(data: TokenRefreshedEventData(accessToken: decode)))
        webSocketClient.saveAccessToken(event)
        XCTAssertEqual(socketService.internalAccessTokenSetterCount, 1)
        XCTAssertNotNil(webSocketClient.socketService.accessToken)
        XCTAssertEqual(socketService.internalAccessTokenGetterCount, 1)
    }
    func testSaveAccessTokenWithNilEvent() {
        socketService.accessToken = nil
        socketService.internalAccessTokenGetterCount = 0
        socketService.internalAccessTokenSetterCount = 0
        webSocketClient.saveAccessToken(nil)
        XCTAssertEqual(socketService.internalAccessTokenSetterCount, 0)
        XCTAssertEqual(socketService.internalAccessTokenGetterCount, 0)
    }
    
    func testNotifyArchiveThreadEvent() {
        var check = false
        let expectation = expectation(description: "Thread Archive Event")
        webSocketClient.onThreadArchive = {
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        webSocketClient.notifyThreadArchivedEvent()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testProcessMoreMessagesEvent() {
        let event = MoreMessagesLoadedEvent(eventId: UUID(), postback: MoreMessagesLoadedEventPostback(eventType: .moreMessagesLoaded, data: MoreMessagesLoadedEventPostbackData(messages: [Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: UUID(), messageContent: MessageContent(type: .text, payload: MessagePayload(text: "message", elements: [])), createdAt: "", attachments: [], direction: .inbound, userStatistics: UserStatistics())], scrollToken: "token")))
        var check = false
        let expectation = expectation(description: "On Load More Messages")
        webSocketClient.onLoadMoreMessages = { _ in
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        webSocketClient.processMoreMessagesEvent(event)
        wait(for: [expectation], timeout: 1.0)
    }
    func testProcessMoreMessagesEventWithNil() {        
        var check = false
        let expectation = expectation(description: "On Load More Messages with nil Event")
        webSocketClient.onLoadMoreMessages = { _ in
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        webSocketClient.processMoreMessagesEvent(nil)
        wait(for: [expectation], timeout: 1.0)
    }
    func testProcessConsumerReconnect() {
        var check = false
        let expectation = expectation(description: "On connected Called From Test processCustomerReconnectEvent")
        webSocketClient.onConnect = {
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        webSocketClient.processCustomerReconnectEvent()
        wait(for: [expectation], timeout: 1.0)
    }
    func testProcessConsumerReconnectFails() {
        var check = false
        let expectation = expectation(description: "On connected Called From Test processCustomerReconnectEvent Fails")
        webSocketClient.onError = { error in
            if check == false {
                XCTAssertTrue(error as! CXOneChatError == CXOneChatError.notConnected)
                expectation.fulfill()
                check = true
            }
        }
        (webSocketClient as! CXOneChatMock).isConected = false
        XCTAssertFalse(webSocketClient.connected)
        webSocketClient.processCustomerReconnectEvent()
        wait(for: [expectation], timeout: 1.0)
    }
    func testNotifyAgentTypingStartedEvent() {
        let event = AgentTypingEvent(eventId: UUID(), eventObject: .message, eventType: .senderTypingStarted, createdAt: "", data: AgentTypingEventData(brand: Brand(id: 1386), channel: ChannelIdentifier(id: "chanel_id"), thread: Thread.init(idOnExternalPlatform: UUID())))
        var check = false
        let expectation = expectation(description: "On Agent typing started")
        webSocketClient.onAgentTypingStart = { _ in
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        webSocketClient.notifyAgentTypingStartedEvent(event)
        wait(for: [expectation], timeout: 1.0)
    }
    func testNotifyAgentTypingEndedEvent() {
        let event = AgentTypingEvent(eventId: UUID(), eventObject: .message, eventType: .senderTypingStarted, createdAt: "", data: AgentTypingEventData(brand: Brand(id: 1386), channel: ChannelIdentifier(id: "chanel_id"), thread: Thread.init(idOnExternalPlatform: UUID())))
        var check = false
        let expectation = expectation(description: "On Agent typing Ended")
        webSocketClient.onAgentTypingEnd = { _ in
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        webSocketClient.notifyAgentTypingEndEvent(event)
        wait(for: [expectation], timeout: 1.0)
    }
    func testProcessMessageCreatedEvent() {
        var thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID.init(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7")!)
        thread.id = UUID().uuidString
        webSocketClient.threads.append(thread)
        let data = loadStubFromBundle(withName: "MessageCreatedEvent", extension: "json")
        var check = false
        let expectation = expectation(description: "On newMessage")
        webSocketClient.onNewMessage = { _ in
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        webSocketClient.processMessageCreatedEvent(data)
        wait(for: [expectation], timeout: 1.0)
    }
    func testProcessMessageCreatedEventWithCustomMessage() {
        var thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID.init(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7")!)
        thread.id = UUID().uuidString
        webSocketClient.threads.append(thread)
        let data = loadStubFromBundle(withName: "CustomMessageCreatedEvent", extension: "json")
        var check = false
        let expectation = expectation(description: "On newMessage")
        webSocketClient.onCustomPluginMessage = { data in
            let object = data.first as! [String: Any]
            XCTAssertEqual(object["text"] as! String, "See this page")
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        webSocketClient.processMessageCreatedEvent(data)
        wait(for: [expectation], timeout: 1.0)
    }
    func testProcessMessageCreatedEventWitherError() {
        var thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID.init(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7")!)
        thread.id = UUID().uuidString
        webSocketClient.threads.append(thread)
        let data = loadStubFromBundle(withName: "ServerError", extension: "json")
        var check = false
        let expectation = expectation(description: "On newMessage With Error")
        webSocketClient.onError = { _ in
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        webSocketClient.processMessageCreatedEvent(data)
        wait(for: [expectation], timeout: 1.0)
    }
    func testProcessThreadLoad() {
        var check = false
        let expectation = expectation(description: "On Thread Load from Process")
        webSocketClient.onThreadLoad = { _ in
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        webSocketClient.processThreadRecoverEvent(ThreadRecoveredEvent(eventId: UUID(), postback: ThreadRecoveredEventPostback(eventType: .recoverThread, data: ThreadRecoveredEventPostbackData(consumerContact: Contact(id: UUID().uuidString, threadIdOnExternalPlatform: UUID(), status: .open, createdAt: ""), messages: [], thread: ReceivedThreadData(id: "asd", idOnExternalPlatform: UUID(), channelId: "", threadName: "", createdAt: "", updatedAt: "", canAddMoreMessages: true), messagesScrollToken: "asdasda"))))
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testProcessMessageReadEvent() {
        var thread = ChatThread(idOnExternalPlatform: UUID(uuidString: "100C8CB2-672B-4A43-AE1A-89B7C8410D42")!)
        thread.id = UUID().uuidString
        
        var check = false
        let expectation = expectation(description: "On AgentRead Message from Process Message Read Event")
        webSocketClient.onAgentReadMessage = { _ in
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        let data = loadStubFromBundle(withName: "MessageReadEventByAgent", extension: "json")
        let event = try! JSONDecoder().decode(MessageReadByAgentEvent.self, from: data)
        thread.messages.append(event.data.message)
        webSocketClient.threads.append(thread)
        webSocketClient.processMessageReadChangeEvent(event)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testProcessThreadLastMessage() {
        var thread = ChatThread(idOnExternalPlatform: UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7")!)
        thread.id = UUID().uuidString
        
        var check = false
        let expectation = expectation(description: "On ThreadInfo load ")
        webSocketClient.onThreadInfoLoad = { _ in
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        let data = loadStubFromBundle(withName: "ThreadMetadataLoadedEvent", extension: "json")
        let event = try! JSONDecoder().decode(ThreadMetadataLoadedEvent.self, from: data)
        webSocketClient.threads.append(thread)
        webSocketClient.processThreadLastMessage(event.postback.data.lastMessage)
        wait(for: [expectation], timeout: 1.0)
    }
    func testProcessThreadLastMessageFailsWithError() {
        var check = false
        let expectation = expectation(description: "On ThreadInfo load ")
        webSocketClient.onError = { _ in
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        let data = loadStubFromBundle(withName: "ThreadMetadataLoadedEvent", extension: "json")
        let event = try! JSONDecoder().decode(ThreadMetadataLoadedEvent.self, from: data)
        webSocketClient.processThreadLastMessage(event.postback.data.lastMessage)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testProcessThreadAgent() {
        var thread = ChatThread(idOnExternalPlatform: UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7")!)
        thread.id = UUID().uuidString
        let data = loadStubFromBundle(withName: "ThreadMetadataLoadedEvent", extension: "json")
        let event = try! JSONDecoder().decode(ThreadMetadataLoadedEvent.self, from: data)
        webSocketClient.threads.append(thread)
        webSocketClient.processThreadAgent(event.postback.data.lastMessage, event.postback.data.ownerAssignee!)
        XCTAssertNotNil(webSocketClient.threads.last?.threadAgent)
    }
    func testProcessInboxAsigneeChangeEvent() {
        var thread = ChatThread(idOnExternalPlatform: UUID(uuidString: "7D17EA7C-412E-486B-AD42-58D85E83D4DE")!)
        thread.id = UUID().uuidString
        
        var check = false
        let expectation = expectation(description: "On Agent Change")
        webSocketClient.onAgentChange = { _, _ in
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        let data = loadStubFromBundle(withName: "CaseInboxAssigneeChanged", extension: "json")
        let event = try! JSONDecoder().decode(ContactInboxAssigneeChangedEvent.self, from: data)
        
        webSocketClient.threads.append(thread)
        webSocketClient.processInboxAssigneeChangeEvent(event)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchThreadList() {
        var check = false
        let expectation = expectation(description: "On Thread list load ")
        webSocketClient.onThreadsLoad = { _ in
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        let data = loadStubFromBundle(withName: "ThreadListFetchedEvent", extension: "json")
        let event = try! JSONDecoder().decode(GenericEvent.self, from: data)
        webSocketClient.processThreadListFetchedEvent(event: event)
        wait(for: [expectation], timeout: 1.0)
    }
    func testUpdatethreadNameNoEmptyMessageArray() {
        var thread = ChatThread(idOnExternalPlatform: UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7")!)
        thread.id = UUID().uuidString
        var check = false
        let expectation = expectation(description: "On update threadName ")
        let config = ChannelConfiguration(settings: ChannelSettings(hasMultipleThreadsPerEndUser: true,
                                                                    isProactiveChatEnabled: true),
                                          isAuthorizationEnabled: false)
        webSocketClient.channelConfig = config
        let message = Message(idOnExternalPlatform: UUID(), threadIdOnExternalPlatform: UUID(), messageContent: MessageContent(type: .text, payload: MessagePayload(text: "", elements: [])), createdAt: "", attachments: [], direction: .inbound, userStatistics: UserStatistics())
        thread.messages.append(message)
        socketService.messageSend = 0
        socketService.messageSent = {  [weak self] sendMessage in
            if check == false {
                if sendMessage.contains("UpdateThread") {
                    let index = self?.webSocketClient.threads.firstIndex(where: {
                        $0.idOnExternalPlatform == thread.idOnExternalPlatform
                    })
                    XCTAssertNotNil(index)
                    XCTAssertFalse(self?.webSocketClient.threads[index!].threadName?.isEmpty ?? true)
                    XCTAssertEqual(self?.webSocketClient.threads[index!].threadName, "Thread Name")
                    expectation.fulfill()
                    check = true
                }
            }
        }
        webSocketClient.threads.append(thread)
        XCTAssertNoThrow(try webSocketClient.updateThreadName(threadName: "Thread Name", threadIdOnExternalPlatform: thread.idOnExternalPlatform))
        wait(for: [expectation], timeout: 1.0)
    }
    func testUpdatethreadNameWithEmptyMessageArray() {
        var thread = ChatThread(idOnExternalPlatform: UUID(uuidString: "3118D0DF-99AA-49E9-A115-C5B98736DEE7")!)
        thread.id = UUID().uuidString
        var check = false
        let expectation = expectation(description: "On update threadName ")
        let config = ChannelConfiguration(settings: ChannelSettings(hasMultipleThreadsPerEndUser: true,
                                                                    isProactiveChatEnabled: true),
                                          isAuthorizationEnabled: false)
        webSocketClient.channelConfig = config
        webSocketClient.onThreadUpdate = {  [weak self] in
            if check == false {
                let index = self?.webSocketClient.threads.firstIndex(where: {
                    $0.idOnExternalPlatform == thread.idOnExternalPlatform
                })
                XCTAssertNotNil(index)
                XCTAssertFalse(self?.webSocketClient.threads[index!].threadName?.isEmpty ?? true)
                XCTAssertEqual(self?.webSocketClient.threads[index!].threadName, "Thread Name")
                expectation.fulfill()
                check = true
            }
        }

        webSocketClient.threads.append(thread)
        XCTAssertNoThrow(try webSocketClient.updateThreadName(threadName: "Thread Name", threadIdOnExternalPlatform: thread.idOnExternalPlatform))
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testProcessActionProactiveActionWithWelcomeMessage() {
        var check = false
        let expectation = expectation(description: "On welcome Message Received ")
        webSocketClient.onWelcomeMessageReceived = {
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        let data = loadStubFromBundle(withName: "WelcomeMessage", extension: "json")
        let event = try! JSONDecoder().decode(ProactiveActionEvent.self, from: data)
        webSocketClient.processProactiveAction(decode: event, data: data)
        wait(for: [expectation], timeout: 1.0)
    }
    func testSendOutBoundMessage() {
        let thread = ChatThread(id: UUID().uuidString, idOnExternalPlatform: UUID())
        webSocketClient.threads.append(thread)
        
        let expectation = expectation(description: "closure Called")
        socketService.messageSend = 0
        socketService.messageSent = { message in
            if message.contains("SendOutbound") {
                XCTAssertTrue(!message.isEmpty)
                expectation.fulfill()
            }
        }
        XCTAssertNoThrow(try webSocketClient.sendOutboundMessage(message: "an example message ", threadIdOnExternalPlatform: thread.idOnExternalPlatform))
        XCTAssertEqual(socketService.messageSend, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    
   
    
    func testProcessActionProactiveActionWithCustomPopup() {
        var check = false
        let expectation = expectation(description: "On custom popup Received ")
        webSocketClient.onProactivePopupAction = { _,_ in
            if check == false {
                expectation.fulfill()
                check = true
            }
        }
        let data = loadStubFromBundle(withName: "CustomPopup", extension: "json")
        let event = try! JSONDecoder().decode(ProactiveActionEvent.self, from: data)
        webSocketClient.processProactiveAction(decode: event, data: data)
        wait(for: [expectation], timeout: 1.0)
    }
}




