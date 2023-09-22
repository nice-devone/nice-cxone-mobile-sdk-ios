@testable import CXoneChatSDK
import XCTest

class MessagesProviderTests: CXoneXCTestCase {
    
    // MARK: - Properties
    
    private lazy var message = MessageDTO(
        idOnExternalPlatform: UUID(),
        threadIdOnExternalPlatform: UUID(),
        contentType: .text(MessagePayloadDTO(text: "", postback: nil)),
        createdAt: dateProvider.now,
        attachments: [],
        direction: .inbound,
        userStatistics: UserStatisticsDTO(seenAt: nil, readAt: nil),
        authorUser: nil,
        authorEndUserIdentity: nil
    )
    // swiftlint:disable:next force_unwrapping
    private let attachment = AttachmentUploadDTO(
        attachmentData: "attachment".data(using: .utf8)!,
        mimeType: "image/jpg",
        fileName: "file",
        friendlyName: "friendly"
    )
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
        let thread = ChatThread(id: UUID())
        XCTAssertThrowsError(try CXoneChat.threads.messages.loadMore(for: thread))
    }
    
    func testLoadMoreThrowsInvalidOldestDate() {
        let thread = ChatThread(id: UUID(), scrollToken: "scroll_token")
        
        XCTAssertThrowsError(try CXoneChat.threads.messages.loadMore(for: thread))
    }
    
    func testLoadMoreNoThrow() throws {
        var thread = ChatThread(id: UUID(), scrollToken: "scroll_token")
        thread.messages.append(MessageMapper.map(message))
        
        XCTAssertNoThrow(try CXoneChat.threads.messages.loadMore(for: thread))
    }
    
    func testSendMessageThrows() async {
        CXoneChat.connection.disconnect()
        
        let thread = ChatThread(id: UUID())
        
        do {
            try await CXoneChat.threads.messages.send(OutboundMessage(text: "message"), for: thread)
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testSendMessageNoThrow() async throws {
        let thread = ChatThread(id: UUID())
        
        try await CXoneChat.threads.messages.send(OutboundMessage(text: "message"), for: thread)
    }
    
    func testSnedMessagesWithPropertiesNoThrow() async throws {
        socketService.accessToken = AccessTokenDTO(token: "token", expiresIn: .max)
        let thread = ChatThread(id: UUID(), messages: [MessageMapper.map(message)])
        
        try await CXoneChat.threads.messages.send(OutboundMessage(text: "message"), for: thread)
    }
    
    func testSendMessageWithAttachmentsThrowsNotConnected() async {
        CXoneChat.connection.disconnect()
        
        let thread = ChatThread(id: UUID())
        
        do {
            try await CXoneChat.threads.messages.send(OutboundMessage(text: "message", attachments: []), for: thread)
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }
    
    func testSendMessageWithAttachmentsThrowsMissingURL() async {
        let thread = ChatThread(id: UUID())
        
        (CXoneChat.threads.messages as? MessagesService)?.socketService.connectionContext.channelId = ""
        
        do {
            try await CXoneChat.threads.messages.send(OutboundMessage(text: "message"), for: thread)
            XCTFail("Should throw an error.")
        } catch {
            return
        }
    }

    func testSendMessageWithAttachmentsNoThrow() async throws {
        try await URLProtocolMock.with(
            handlers: accept(
                url(equals: "\(self.chatURL)/1.0/brand/\(self.brandId)/channel/\(self.channelId)/attachment"),
                body: string(preAttachmentResponse)
            )
        ) {
            socketService.accessToken = AccessTokenDTO(token: "token", expiresIn: .max)
            let thread = ChatThreadDTO(
                idOnExternalPlatform: UUID(),
                threadName: nil,
                messages: [],
                threadAgent: nil,
                canAddMoreMessages: true,
                contactId: nil,
                scrollToken: ""
            )

            try await CXoneChat.threads.messages.send(
                OutboundMessage(text: "message", attachments: [AttachmentUploadMapper.map(attachment)]),
                for: ChatThreadMapper.map(thread)
            )
        }
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
