//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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
        let thread = ChatThreadMapper.map(MockData.getThread())
        threadsService.threads = [thread]
        
        try await CXoneChat.threads.messages.send(OutboundMessage(text: "message"), for: thread)
    }
    
    func testSendMessagesWithPropertiesNoThrow() async throws {
        socketService.accessToken = AccessTokenDTO(token: "token", expiresIn: .max, currentDate: Date.provide())
        
        let thread = ChatThreadMapper.map(MockData.getThread())
        threadsService.threads = [thread]
        
        try await CXoneChat.threads.messages.send(OutboundMessage(text: "message"), for: thread)
    }
    
    func testSendMessageWithAttachmentsThrowsNotConnected() async {
        CXoneChat.connection.disconnect()
        
        await XCTAssertAsyncThrowsError(
            try await CXoneChat.threads.messages.send(
                OutboundMessage(text: "message", attachments: [AttachmentUploadMapper.map(MockData.attachment)]),
                for: ChatThreadMapper.map(MockData.getThread())
            )
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
    
    func testSendMessageWithAttachmentsThrowsAttachmentError() async throws {
        CXoneChat.connection.disconnect()
        
        try await setUpConnection(
            channelConfiguration: MockData.getChannelConfiguration(
                fileRestrictions: FileRestrictionsDTO(allowedFileSize: 0, allowedFileTypes: [], isAttachmentsEnabled: false)
            )
        )
        
        try await URLProtocolMock.with(
            handlers: accept(
                url(equals: "\(self.channelURL)/\(self.channelId)/attachment"),
                body: string(preAttachmentResponse)
            )
        ) {
            socketService.accessToken = AccessTokenDTO(token: "token", expiresIn: .max, currentDate: Date.provide())
        
            let thread = ChatThreadMapper.map(MockData.getThread())
            threadsService.threads = [thread]
            
            await XCTAssertAsyncThrowsError(
                try await CXoneChat.threads.messages.send(
                    OutboundMessage(text: "message", attachments: [AttachmentUploadMapper.map(MockData.attachment)]),
                    for: thread
                )
            )
        }
    }
    
    func testSendMessageWithImageAttachmentNoThrow() async throws {
        try await URLProtocolMock.with(
            handlers: accept(
                url(equals: "\(self.channelURL)/\(self.channelId)/attachment"),
                body: string(preAttachmentResponse)
            )
        ) {
            socketService.accessToken = AccessTokenDTO(token: "token", expiresIn: .max, currentDate: Date.provide())

            guard let data = UIImage(systemName: "pencil")?.jpegData(compressionQuality: 0.8) else {
                throw CXoneChatError.attachmentError
            }
            
            let thread = ChatThreadMapper.map(MockData.getThread())
            threadsService.threads = [thread]
            
            try await CXoneChat.threads.messages.send(
                OutboundMessage(text: "message", attachments: [storeDataInDocuments(data, fileName: "image.jpg", mimeType: "image/jpeg")]),
                for: thread
            )
            
            try removeStoredFile(fileName: "image.jpg")
        }
    }
    
    func testSendMessageWithVideoAttachmentNoThrow() async throws {
        guard let videoUrl = Bundle.module.url(forResource: "sample_video", withExtension: "mov") else {
            throw XCTError("Video file not found")
        }
        
        let data = try Data(contentsOf: videoUrl)
        
        XCTAssertNotNil(data, "Failed to load video data")
        
        try await URLProtocolMock.with(
            handlers: accept(
                url(equals: "\(self.channelURL)/\(self.channelId)/attachment"),
                body: string(preAttachmentResponse)
            )
        ) {
            socketService.accessToken = AccessTokenDTO(token: "token", expiresIn: .max, currentDate: Date.provide())
            
            let thread = ChatThreadMapper.map(MockData.getThread())
            threadsService.threads = [thread]
            
            try await CXoneChat.threads.messages.send(
                OutboundMessage(text: "message", attachments: [storeDataInDocuments(data, fileName: "sample_video.mov", mimeType: "video/quicktime")]),
                for: thread
            )
            
            try removeStoredFile(fileName: "sample_video.mov")
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
        UserDefaultsService.shared.set("Hello {{customer.firstName|stranger}}!", for: .welcomeMessage)
        
        CXoneChat.connection.disconnect()
        
        let thread = ChatThreadMapper.map(MockData.getThread())
        threadsService.threads = [thread]
        
        do {
            try await CXoneChat.threads.messages.send(OutboundMessage(text: "test"), for: thread)
            XCTFail("Should throw `notConnected`")
        } catch {
            XCTAssertEqual(error as? CXoneChatError, CXoneChatError.notConnected)
        }
    }
    
    func testWelcomeMessageAppendsToNewThread() async throws {
        UserDefaultsService.shared.set("Hello {{customer.firstName|stranger}}!", for: .welcomeMessage)
        
        try await CXoneChat.threads.create(with: defaultAnswers)
        
        let eventData = try loadBundleData(from: "FireProactiveAction+WelcomeMessage", type: "json")
        CXoneChat.handle(message: eventData.utf8string!)
        
        guard let thread = CXoneChat.threads.get().last else {
            throw XCTError("Unable to retrieve required thread")
        }
        
        XCTAssertEqual(thread.messages.count, 1, "Thread should contain welcome message")
        
        guard let message = thread.messages.first, case .text(let payload) = message.contentType else {
            throw XCTError("Message is not a text message type")
        }
        XCTAssertEqual(payload.text, "Dear customer, we would like to offer you a discount of 5%.", "Thread should contain welcome message")
    }
    
    func testSendMessageWithExistingWelcomeMessageNoThrow() async throws {
        UserDefaultsService.shared.set("Hello {{customer.firstName|stranger}}!", for: .welcomeMessage)
        
        try await CXoneChat.threads.create(with: defaultAnswers)
        
        let eventData = try loadBundleData(from: "FireProactiveAction+WelcomeMessage", type: "json")
        CXoneChat.handle(message: eventData.utf8string!)
        
        guard let thread = CXoneChat.threads.get().last else {
            throw XCTError("Unable to retrieve required thread")
        }
        
        XCTAssertEqual(thread.messages.count, 1, "Thread should contain welcome message")
        
        try await CXoneChat.threads.messages.send(OutboundMessage(text: "Hello"), for: thread)
        
        guard let message = thread.messages.first, case .text(let payload) = message.contentType else {
            throw XCTError("Message is not a text message type")
        }
        
        XCTAssertEqual(payload.text, "Dear customer, we would like to offer you a discount of 5%.", "Thread should contain welcome message")
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
    
    func storeDataInDocuments(_ data: Data, fileName: String, mimeType: String) throws -> ContentDescriptor {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CXoneChatError.attachmentError
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
        
        return ContentDescriptor(url: fileURL, mimeType: mimeType, fileName: fileName, friendlyName: fileName)
    }
    
    func removeStoredFile(fileName: String) throws {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CXoneChatError.attachmentError
        }

        let filePath = documentsDirectory.appendingPathComponent(fileName).path
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: filePath) {
            try fileManager.removeItem(atPath: filePath)
        }
    }
}
