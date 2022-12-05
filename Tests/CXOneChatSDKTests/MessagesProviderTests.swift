@testable import CXoneChatSDK
import XCTest


class MessagesProviderTests: CXoneXCTestCase {
    
    // MARK: - Properties
    
    private let message = MessageDTO(
        idOnExternalPlatform: UUID(),
        threadIdOnExternalPlatform: UUID(),
        messageContent: .init(type: .text, payload: .init(text: "", elements: []), fallbackText: ""),
        createdAt: Date(),
        attachments: [],
        direction: .inbound,
        userStatistics: .init(seenAt: nil, readAt: nil),
        authorUser: nil,
        authorEndUserIdentity: nil
    )
    // swiftlint:disable:next force_unwrapping
    private let attachment = AttachmentUploadDTO(attachmentData: "attachment".data(using: .utf8)!, mimeType: "image/jpg", fileName: "file")
    
    
    // MARK: - Lifecycle
    
    override func setUp() async throws {
        try await super.setUp()
        
        try await setUpConnection()
    }
    
    
    // MARK: - Tests
    
    func testLoadMoreThrowsNoMoreMessages() {
        let thread = ChatThread(id: UUID())
        XCTAssertThrowsError(try CXoneChat.threads.messages.loadMore(for: thread))
    }
    
    func testLoadMoreThrowsInvalidOldestDate() {
        let thread = ChatThread(id: UUID(), scrollToken: "scroll_token")
        
        XCTAssertThrowsError(try CXoneChat.threads.messages.loadMore(for: thread))
    }
    
    func testLoadMoreNoThrows() async throws {
        var thread = ChatThread(id: UUID(), scrollToken: "scroll_token")
        thread.messages.append(MessageMapper.map(message))
        
        XCTAssertNoThrow(try CXoneChat.threads.messages.loadMore(for: thread))
    }
    
    func testSendMessageThrows() async {
        CXoneChat.connection.disconnect()
        
        let thread = ChatThread(id: UUID())
        
        do {
            try await CXoneChat.threads.messages.send("message", for: thread)
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testSendMessageNoThrow() async throws {
        let thread = ChatThread(id: UUID())
        
        try await CXoneChat.threads.messages.send("message", for: thread)
    }
    
    func testSnedMessagesWithPropertiesNoThrow() async throws {
        socketService.accessToken = AccessTokenDTO(token: "token", expiresIn: .max)
        let thread = ChatThread(id: UUID(), messages: [MessageMapper.map(message)])
        
        try await CXoneChat.threads.messages.send("message", for: thread)
    }
    
    func testSendMessageWithAttachmentsThrowsNotConnected() async {
        CXoneChat.connection.disconnect()
        
        let thread = ChatThread(id: UUID())
        
        do {
            try await CXoneChat.threads.messages.send("message", with: [], for: thread)
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testSendMessageWithAttachmentsThrowsMissingURL() async {
        let thread = ChatThread(id: UUID())
        
        (CXoneChat.threads.messages as? MessagesService)?.socketService.connectionContext.channelId = "\""
        
        do {
            try await CXoneChat.threads.messages.send("message", with: [], for: thread)
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testSendMessageWithAttachmentsNoThrow() async throws {
        socketService.accessToken = AccessTokenDTO(token: "token", expiresIn: .max)
        let thread = ChatThreadDTO(
            id: nil,
            idOnExternalPlatform: UUID(),
            threadName: nil,
            messages: [],
            threadAgent: nil,
            canAddMoreMessages: true,
            contactId: nil,
            scrollToken: ""
        )
        
        try await CXoneChat.threads.messages.send(
            "message",
            with: [AttachmentUploadMapper.map(attachment)],
            for: ChatThreadMapper.map(thread)
        )
    }
    
    func testAttachmentMapperMapsCorretly() {
        let attachment = AttachmentMapper
            .map(Attachment(url: "url", friendlyName: "friendlyName", mimeType: "mimeType", fileName: "fileName"))
        let attachmentDTO = AttachmentMapper
            .map(AttachmentDTO(url: "url", friendlyName: "friendlyName", mimeType: "mimeType", fileName: "fileName"))
        
        XCTAssertEqual(attachment.url, "url")
        XCTAssertEqual(attachment.friendlyName, "friendlyName")
        XCTAssertEqual(attachment.mimeType, "mimeType")
        XCTAssertEqual(attachment.fileName, "fileName")
        
        XCTAssertEqual(attachmentDTO.url, "url")
        XCTAssertEqual(attachmentDTO.friendlyName, "friendlyName")
        XCTAssertEqual(attachmentDTO.mimeType, "mimeType")
        XCTAssertEqual(attachmentDTO.fileName, "fileName")
    }
}
