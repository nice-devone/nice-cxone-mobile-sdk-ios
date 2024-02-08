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

class MessagesProviderTests: CXoneXCTestCase {
    
    // MARK: - Properties
    
    private let defaultAnswers = [
        "email": "john@doe.com",
        "broken_device": "140232dc-8168-4f5c-9f5e-b709adbf8ab1"
    ]
    
    private lazy var preAttachmentResponse = """
    {
        "fileUrl": "https://dummyserver.local/chat/attachments/6477/c98738d0-e335-4389-a2e4-34ac4b4d132a.jpeg"
    }
    """
    
    // MARK: - Lifecycle
    
    override func setUp() async throws {
        try await super.setUp()
        
        try await setUpConnection()
    }
    
    // MARK: - Tests
    
    func testLoadMoreThrowsNoMoreMessages() {
        XCTAssertThrowsError(try CXoneChat.threads.messages.loadMore(for: ChatThreadMapper.map(MockData.getThread(scrollToken: ""))))
    }
    
    func testLoadMoreThrowsInvalidOldestDate() {
        XCTAssertThrowsError(try CXoneChat.threads.messages.loadMore(for: ChatThreadMapper.map(MockData.getThread(withMessages: false))))
    }
    
    func testLoadMoreNoThrow() throws {
        var thread = ChatThreadMapper.map(MockData.getThread())
        thread.messages.append(MessageMapper.map(MockData.getMessage(threadId: thread.id, isSenderAgent: false)))
        
        XCTAssertNoThrow(try CXoneChat.threads.messages.loadMore(for: thread))
    }
    
    func testSendMessageThrows() async {
        CXoneChat.connection.disconnect()
        
        await XCTAssertAsyncThrowsError(
            try await CXoneChat.threads.messages.send(OutboundMessage(text: "message"), for: ChatThreadMapper.map(MockData.getThread()))
        )
    }
    
    func testSendMessageNoThrow() async throws {
        try await CXoneChat.threads.messages.send(OutboundMessage(text: "message"), for: ChatThreadMapper.map(MockData.getThread()))
    }
    
    func testSenddMessagesWithPropertiesNoThrow() async throws {
        socketService.accessToken = AccessTokenDTO(token: "token", expiresIn: .max)
        
        try await CXoneChat.threads.messages.send(OutboundMessage(text: "message"), for: ChatThreadMapper.map(MockData.getThread()))
    }
    
    func testSendMessageWithAttachmentsThrowsNotConnected() async {
        CXoneChat.connection.disconnect()
        
        await XCTAssertAsyncThrowsError(
            try await CXoneChat.threads.messages.send(OutboundMessage(text: "message", attachments: []), for: ChatThreadMapper.map(MockData.getThread()))
        )
    }
    
    func testSendMessageWithAttachmentsThrowsMissingURL() async {
        let thread = ChatThread(id: UUID(), state: .ready)
        
        connectionContext.channelId = ""
        
        await XCTAssertAsyncThrowsError(
            try await CXoneChat.threads.messages.send(
                OutboundMessage(text: "message", attachments: [AttachmentUploadMapper.map(MockData.attachment)]),
                for: thread
            )
        )
    }
    
    // TODO: - Remote `XCTSkip` when the bug on the BE side is resolved
    func testSendMessageWithAttachmentsNoThrow() async throws {
        throw XCTSkip("Upload attachment test unavailable – contains an error on the BE side")
        
        try await URLProtocolMock.with(
            handlers: accept(
                url(equals: "\(self.chatURL)/1.0/brand/\(self.brandId)/channel/\(self.channelId)/attachment"),
                body: string(preAttachmentResponse)
            )
        ) {
            socketService.accessToken = AccessTokenDTO(token: "token", expiresIn: .max)

            try await CXoneChat.threads.messages.send(
                OutboundMessage(text: "message", attachments: [AttachmentUploadMapper.map(MockData.attachment)]),
                for: ChatThreadMapper.map(MockData.getThread())
            )
        }
    }
    
    func testAttachmentMapperMapsCorretly() {
        let attachment = AttachmentMapper.map(Attachment(url: "url", friendlyName: "friendlyName", mimeType: "mimeType", fileName: "fileName"))
        let attachmentDTO = AttachmentMapper.map(AttachmentDTO(url: "url", friendlyName: "friendlyName", mimeType: "mimeType", fileName: "fileName"))
        
        XCTAssertEqual(attachment.url, attachmentDTO.url)
        XCTAssertEqual(attachment.friendlyName, attachmentDTO.friendlyName)
        XCTAssertEqual(attachment.mimeType, attachmentDTO.mimeType)
        XCTAssertEqual(attachment.fileName, attachmentDTO.fileName)
    }
    
    func testWelcomeMessageThrowsNoConnection() async {
        UserDefaults.standard.set("Hello {{customer.firstName|stranger}}!", forKey: "welcomeMessage")
        
        CXoneChat.connection.disconnect()
        
        do {
            try await CXoneChat.threads.messages.send(OutboundMessage(text: "test"), for: ChatThreadMapper.map(MockData.getThread()))
            XCTFail("Should throw `notConnected`")
        } catch {
            XCTAssertEqual(error as? CXoneChatError, CXoneChatError.notConnected)
        }
    }
    
    func testWelcomeMessageAppendsToNewThread() async throws {
        UserDefaults.standard.set("Hello {{customer.firstName|stranger}}!", forKey: "welcomeMessage")
        
        let threadId = try CXoneChat.threads.create(with: defaultAnswers)
        let thread = try getThread(by: threadId)
        
        XCTAssertEqual(thread.messages.count, 1, "Thread should contain welcome message")
        
        guard let message = thread.messages.first, case .text(let payload) = message.contentType else {
            throw XCTError("Message is not a text message type")
        }
        XCTAssertEqual(payload.text, "Hello stranger!", "Thread should contain welcome message")
    }
    
    func testSendMessageWithExistingWelcomeMessageNoThrow() async throws {
        UserDefaults.standard.set("Hello {{customer.firstName|stranger}}!", forKey: "welcomeMessage")
        
        let threadId = try CXoneChat.threads.create(with: defaultAnswers)
        var thread = try getThread(by: threadId)
        
        XCTAssertEqual(thread.messages.count, 1, "Thread should contain welcome message")
        
        try await CXoneChat.threads.messages.send(OutboundMessage(text: "Hello"), for: thread)
        
        guard let message = thread.messages.first, case .text(let payload) = message.contentType else {
            throw XCTError("Message is not a text message type")
        }
        
        thread = try getThread(by: threadId)
        XCTAssertEqual(payload.text, "Hello stranger!", "Thread should contain welcome message")
        XCTAssertEqual(
            socketService.messageSend, 4,
            "Socket should send 4 events - AuthorizeCustomer, Recover, OutboundMessage – welcome message, InboundMessage - customer message"
        )
    }
}

// MARK: - Helpers

private extension MessagesProviderTests {

    func getThread(by id: UUID) throws -> ChatThread {
        guard let thread = CXoneChat.threads.get().first(where: { $0.id == id }) else {
            throw XCTError("Thread does not exist")
        }
        
        return thread
    }
}
