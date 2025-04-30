//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
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

import Combine
@testable import CXoneChatSDK
import Mockable
import XCTest

@available(iOS 16.0, *)
final class ChatThreadServiceTest: XCTestCase {
    
    // MARK: - Properties
    
    private let contactFields = MockContactCustomFieldsProvider()
    private let customerFields = MockCustomerCustomFieldsProvider()
    private let socketService = MockSocketService()
    private let connectionContext = MockConnectionContext()
    private let welcomeMessageManager = WelcomeMessageManager()
    private let dateProvider = DateProviderMock()
    private let uuidProvider = MockUUIDProvider()
    private let subject = PassthroughSubject<ReceivedEvent, Never>()
    private let delegate = MockCXoneChatDelegate()

    private lazy var events = subject.eraseToAnyPublisher()
    private lazy var eventsService = EventsService(connectionContext: connectionContext)
    
    private static let brandId = 1386
    private static let channelId = "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
    private static let chatURL = "https://channels-de-na1.niceincontact.com/chat"
    private static let channelURL = "https://channels-de-na1.niceincontact.com/chat/1.0/brand/1386/channel"
    private static let socketURL = "wss://chat-gateway-de-na1.niceincontact.com"
    private static let visitorId = UUID()
    private static let accessToken = AccessTokenDTO(token: "token", expiresIn: .max, currentDate: Date.provide())
    
    var service: ChatThreadListService?

    // MARK: - Lifecycle
    
    override func setUp() {
        given(socketService)
            .accessToken.willReturn(Self.accessToken)
            .cancellables.willReturn([])
            .events.willReturn(events)
            .connectionContext.willReturn(connectionContext)

        given(connectionContext)
            .brandId.willReturn(Self.brandId)
            .channelId.willReturn(Self.channelId)
            .visitorId.willReturn(Self.visitorId)
            .deviceToken.willReturn(nil)
            .session.willReturn(URLSession.shared)
            .accessToken.willReturn(Self.accessToken)
            .customer.willReturn(MockData.customerIdentity)

        service = ChatThreadListService(
            contactCustomFields: contactFields,
            customerCustomFields: customerFields,
            socketService: socketService,
            eventsService: eventsService,
            welcomeMessageManager: welcomeMessageManager,
            delegate: delegate
        )
        
        UUID.provider = uuidProvider
    }

    // MARK: - Tests
    
    func testArchiveThreadSuccess() async throws {
        let eventId = UUID()
        let thread = ChatThread(
            id: UUID(),
            state: .ready
        )
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                self.subject.send(
                    GenericEventDTO(
                        eventId: eventId,
                        eventType: .threadArchived,
                        postback: nil
                    )
                )
            }
            .disconnect(unexpectedly: .any).willReturn()
            .checkForConnection().willReturn()

        given(delegate)
            .onThreadUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }

        service!.threads = [thread]

        try await service!.provider(for: thread).archive()

        await fulfillment(of: [expectation], timeout: 10.0)

        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(1)

        verify(delegate)
            .onThreadUpdated(.matching {
                $0.id == thread.id && $0.state == .closed
            })
            .called(1)
    }

    func testArchiveNewThreadSuccess() async throws {
        let thread = ChatThread(
            id: UUID(),
            state: .pending
        )
        let expectation = expectation(description: "Service Complete")

        given(socketService)
            .checkForConnection().willReturn()
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(delegate)
            .onThreadUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }

        service!.threads = [thread]

        try await service!.provider(for: thread).archive()

        await fulfillment(of: [expectation], timeout: 10.0)

        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(0)

        verify(delegate)
            .onThreadUpdated(.matching {
                $0.id == thread.id && $0.state == .closed
            })
            .called(1)
    }


    func testArchiveThreadFailure() async throws {
        let eventId = UUID()
        let thread = ChatThread(
            id: UUID(),
            state: .ready
        )
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                self.subject.send(
                    OperationError(
                        eventId: UUID.provide(),
                        errorCode: .inconsistentData,
                        transactionId: eventId.asLowerCaseUUID,
                        errorMessage: "Unknown Event"
                    )
                )
            }
            .disconnect(unexpectedly: .any).willReturn()
            .checkForConnection().willReturn()

        service!.threads = [thread]
        
        let provider = try service!.provider(for: thread)
        
        await XCTAssertAsyncThrowsError(try await provider.archive())
        
        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(1)
    }

    func testArchiveClosedThreadThrows() async throws {
        let eventId = UUID()
        let thread = ChatThread(
            id: UUID(),
            state: .closed
        )
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .checkForConnection().willReturn()

        service!.threads = [thread]

        await XCTAssertAsyncThrowsError(try await service!.provider(for: thread).archive()) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
        }
    }
    
    func testProcessLoadMoreMessagesSuccess() async throws {
        let eventId = UUID()
        let thread = MockData.getThread(withMessages: true)
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                self.subject.send(
                    MoreMessagesLoadedEventDTO(
                        eventId: eventId,
                        eventType: .moreMessagesLoaded,
                        postback: MoreMessagesLoadedEventPostbackDTO(
                            eventType: .moreMessagesLoaded,
                            data: MoreMessagesLoadedEventPostbackDataDTO(
                                messages: [MockData.getMessage(threadId: thread.id, isSenderAgent: false)],
                                scrollToken: ""
                            )
                        )
                    )
                )
            }
            .disconnect(unexpectedly: .any).willReturn()
            .checkForConnection().willReturn()

        given(delegate)
            .onThreadUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }

        service!.threads = [thread]
        
        try await service!.provider(for: thread).loadMoreMessages()

        await fulfillment(of: [expectation], timeout: 10.0)

        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(1)

        verify(delegate)
            .onThreadUpdated(.matching {
                $0.id == thread.id && $0.messages.count == 2
            })
            .called(1)
    }
    
    func testLoadMoreMessagesThrowNoMoreMessages() async throws {
        let eventId = UUID()
        let thread = MockData.getThread(scrollToken: "")
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        service!.threads = [thread]

        await XCTAssertAsyncThrowsError(try await service!.provider(for: thread).loadMoreMessages()) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, CXoneChatError.noMoreMessages)
        }
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testLoadMoreMessagesThrowInvalidOldestDate() async throws {
        let eventId = UUID()
        let thread = MockData.getThread(withMessages: false)
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        service!.threads = [thread]

        await XCTAssertAsyncThrowsError(try await service!.provider(for: thread).loadMoreMessages()) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, CXoneChatError.invalidOldestDate)
        }
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testSendMessageSuccess() async throws {
        let eventId = UUID()
        let thread = ChatThread(id: UUID(), state: .ready)
        
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                self.subject.send(
                    GenericEventDTO(eventId: eventId, eventType: nil, postback: nil)
                )
            }
            .disconnect(unexpectedly: .any).willReturn()
            .checkForConnection().willReturn()

        given(delegate)
            .onThreadUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }

        service!.threads = [thread]

        try await service!.provider(for: thread).send(OutboundMessage(text: "Test"))

        await fulfillment(of: [expectation], timeout: 10.0)

        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(1)

        verify(delegate)
            .onThreadUpdated(.matching { $0.id == thread.id })
            .called(1)
    }
    
    func testSendMessageThrowsNotConnected() async throws {
        let eventId = UUID()
        let thread = MockData.getThread(withMessages: false)
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willProduce {
                throw CXoneChatError.notConnected
            }
        
        service!.threads = [thread]

        await XCTAssertAsyncThrowsError(try await service!.provider(for: thread).send(OutboundMessage(text: "Test"))) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, CXoneChatError.notConnected)
        }
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testSendMessageWithExistingWelcomeMessageNoThrow() async throws {
        let eventId = UUID()
        let thread = ChatThread(id: UUID(), state: .ready)
        
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                self.subject.send(
                    GenericEventDTO(eventId: eventId, eventType: nil, postback: nil)
                )
            }
            .disconnect(unexpectedly: .any).willReturn()
            .checkForConnection().willReturn()

        given(delegate)
            .onThreadUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }

        let eventData = try loadBundleData(from: "FireProactiveAction+WelcomeMessage", type: "json")
        let event = try JSONDecoder().decode(ProactiveActionEventDTO.self, from: eventData)
        try service!.processProactiveAction(event)

        service!.threads = [thread]
        
        try await service!.provider(for: thread).send(OutboundMessage(text: "Test"))

        await fulfillment(of: [expectation], timeout: 10.0)

        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(1)

        verify(delegate)
            .onThreadUpdated(.matching { $0.id == thread.id })
            .called(1)
    }
    
    func testSendMessageWithAttachmentThrowsAttachmentError() async throws {
        let eventId = UUID()
        let thread = MockData.getThread(withMessages: false)
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .environment.willReturn(CustomEnvironment(chatURL: Self.chatURL, socketURL: Self.socketURL))
            .channelConfig.willReturn(
                MockData.getChannelConfiguration(
                    fileRestrictions: FileRestrictionsDTO(allowedFileSize: 0, allowedFileTypes: [], isAttachmentsEnabled: false)
                )
            )
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        service!.threads = [thread]
        
        let message = OutboundMessage(text: "message", attachments: [MockData.attachment])
        
        await XCTAssertAsyncThrowsError(try await service!.provider(for: thread).send(message)) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, CXoneChatError.attachmentError)
        }
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testSendMessageWithAttachmentThrowsMissingURL() async throws {
        let eventId = UUID()
        let thread = MockData.getThread(withMessages: false)
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration())
            .environment.willReturn(CustomEnvironment(chatURL: "", socketURL: ""))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        service!.threads = [thread]
        
        let message = OutboundMessage(text: "message", attachments: [MockData.attachment])
        
        await XCTAssertAsyncThrowsError(try await service!.provider(for: thread).send(message)) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, CXoneChatError.missingParameter("url"))
        }
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testSendMessageWithImageAttachmentThrowsInvalidType() async throws {
        let eventId = UUID()
        let thread = MockData.getThread(withMessages: false)
        
        let fileRestrictions = FileRestrictionsDTO(allowedFileSize: 40, allowedFileTypes: [], isAttachmentsEnabled: true)
        
        given(uuidProvider)
            .next.willReturn(eventId)

        given(connectionContext)
            .environment.willReturn(CustomEnvironment(chatURL: Self.chatURL, socketURL: Self.socketURL))
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true, fileRestrictions: fileRestrictions))
        
        given(socketService)
            .checkForConnection().willReturn()
        
        let response = try loadBundleData(from: "AttachmentUploadFailResponse", type: "json")
        
        try await URLProtocolMock.with(
            handlers: accept(
                url(equals: "\(Self.channelURL)/\(Self.channelId)/attachment"),
                body: data(response)
            )
        ) {
            guard let data = UIImage(systemName: "pencil")?.jpegData(compressionQuality: 0.8) else {
                throw CXoneChatError.attachmentError
            }
            
            service!.threads = [thread]
            
            let message = OutboundMessage(text: "message", attachments: [try storeDataInDocuments(data, fileName: "image.jpg", mimeType: "image/jpeg")])
            
            await XCTAssertAsyncThrowsError(try await service!.provider(for: thread).send(message)) { [weak self] error in
                self?.XCTAssertIs(error, CXoneChatError.self)
                XCTAssertEqual(error as! CXoneChatError, .invalidFileType)
            }
            
            verify(socketService)
                .send(data: .any, shouldCheck: .value(true))
                .called(0)

            verify(delegate)
                .onThreadUpdated(.any)
                .called(0)
            
            try removeStoredFile(fileName: "image.jpg")
        }
    }
    
    func testSendMessageWithImageAttachmentSuccess() async throws {
        let eventId = UUID()
        let thread = MockData.getThread(withMessages: false)
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(eventId)

        given(connectionContext)
            .environment.willReturn(CustomEnvironment(chatURL: Self.chatURL, socketURL: Self.socketURL))
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                self.subject.send(
                    GenericEventDTO(eventId: eventId, eventType: nil, postback: nil)
                )
            }
            .checkForConnection().willReturn()

        given(delegate)
            .onThreadUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }
        
        let data = try loadBundleData(from: "AttachmentUploadSuccessResponse", type: "json")
        let response = try JSONDecoder().decode(AttachmentUploadSuccessResponseDTO.self, from: data)
        
        try await URLProtocolMock.with(
            handlers: accept(
                url(equals: "\(Self.channelURL)/\(Self.channelId)/attachment"),
                body: string(response.fileUrl)
            )
        ) {
            guard let data = UIImage(systemName: "pencil")?.jpegData(compressionQuality: 0.8) else {
                throw CXoneChatError.attachmentError
            }
            
            service!.threads = [thread]
            
            try await service!
                .provider(for: thread)
                .send(OutboundMessage(text: "message", attachments: [storeDataInDocuments(data, fileName: "image.jpg", mimeType: "image/jpeg")]))

            await fulfillment(of: [expectation], timeout: 10.0)
            
            verify(socketService)
                .send(data: .any, shouldCheck: .value(true))
                .called(1)

            verify(delegate)
                .onThreadUpdated(.matching { $0.id == thread.id })
                .called(1)
            
            try removeStoredFile(fileName: "image.jpg")
        }
    }
    
    func testSendMessageWithVideoAttachmentSuccess() async throws {
        let eventId = UUID()
        let thread = MockData.getThread(withMessages: false)
        let expectation = expectation(description: "Service Complete")
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .environment.willReturn(CustomEnvironment(chatURL: Self.chatURL, socketURL: Self.socketURL))
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                self.subject.send(
                    GenericEventDTO(eventId: eventId, eventType: nil, postback: nil)
                )
            }
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }
        
        let data = try loadBundleData(from: "AttachmentUploadSuccessResponse", type: "json")
        let response = try JSONDecoder().decode(AttachmentUploadSuccessResponseDTO.self, from: data)
        
        try await URLProtocolMock.with(
            handlers: accept(
                url(equals: "\(Self.channelURL)/\(Self.channelId)/attachment"),
                body: string(response.fileUrl)
            )
        ) {
            guard let videoUrl = Bundle.module.url(forResource: "sample_video", withExtension: "mov") else {
                throw XCTError("Video file not found")
            }
            
            let data = try Data(contentsOf: videoUrl)
            
            XCTAssertNotNil(data, "Failed to load video data")
            
            service!.threads = [thread]
            
            try await service!
                .provider(for: thread)
                .send(OutboundMessage(text: "message", attachments: [storeDataInDocuments(data, fileName: "sample_video.mov", mimeType: "video/quicktime")]))
            
            await fulfillment(of: [expectation], timeout: 10.0)
            
            verify(socketService)
                .send(data: .any, shouldCheck: .value(true))
                .called(1)
            
            verify(delegate)
                .onThreadUpdated(.matching { $0.id == thread.id })
                .called(1)
            
            try removeStoredFile(fileName: "sample_video.mov")
        }
    }
    
    func testAttachmentMapperMapsCorretly() {
        let attachment = Attachment(url: "url", friendlyName: "friendlyName", mimeType: "mimeType", fileName: "fileName")
        let attachmentDTO = AttachmentMapper.map(AttachmentDTO(url: "url", friendlyName: "friendlyName", mimeType: "mimeType", fileName: "fileName"))
        
        XCTAssertEqual(attachment.url, attachmentDTO.url)
        XCTAssertEqual(attachment.friendlyName, attachmentDTO.friendlyName)
        XCTAssertEqual(attachment.mimeType, attachmentDTO.mimeType)
        XCTAssertEqual(attachment.fileName, attachmentDTO.fileName)
    }
    
    func testTypingStartStartThrowsNotConnected() async throws {
        let eventId = UUID()
        let thread = MockData.getThread()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willThrow(CXoneChatError.notConnected)
        
        service!.threads = [thread]

        await XCTAssertAsyncThrowsError(try await service!.provider(for: thread).loadMoreMessages()) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, CXoneChatError.notConnected)
        }
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testTypingStartStartThrowsIlegalChatThreadState() async throws {
        let eventId = UUID()
        let thread = MockData.getThread(state: .closed)
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willThrow(CXoneChatError.illegalThreadState)
        
        service!.threads = [thread]

        await XCTAssertAsyncThrowsError(try await service!.provider(for: thread).loadMoreMessages()) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, CXoneChatError.illegalThreadState)
        }
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }

    func testReportTypingNoThrow() async throws {
        let eventId = UUID()
        let thread = MockData.getThread()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        service!.threads = [thread]
        let provider = try service!.provider(for: thread)
        
        try await provider.reportTypingStart(true)
        try await provider.reportTypingStart(false)
    }
    
    func testMarkReadThrowsNotConnected() async {
        let eventId = UUID()
        let thread = MockData.getThread()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willThrow(CXoneChatError.notConnected)
        
        service!.threads = [thread]

        await XCTAssertAsyncThrowsError(try await service!.provider(for: thread).markRead()) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, CXoneChatError.notConnected)
        }
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testUpdateNameThrowsNotConnected() async {
        let eventId = UUID()
        let thread = MockData.getThread()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willThrow(CXoneChatError.notConnected)
        
        service!.threads = [thread]

        await XCTAssertAsyncThrowsError(try await service!.provider(for: thread).updateName("New name")) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, CXoneChatError.notConnected)
        }
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testUpdateNameThrowsUnsupportedChannelConfig() async {
        let eventId = UUID()
        let thread = MockData.getThread()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: false))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        service!.threads = [thread]

        await XCTAssertAsyncThrowsError(try await service!.provider(for: thread).updateName("New name")) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, CXoneChatError.unsupportedChannelConfig)
        }
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testUpdateNameThrowsIllegalThreadState() async {
        let eventId = UUID()
        let thread = MockData.getThread(state: .closed)
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        service!.threads = [thread]

        await XCTAssertAsyncThrowsError(try await service!.provider(for: thread).updateName("New name")) { error in
            self.XCTAssertIs(error, CXoneChatError.self)
            XCTAssertEqual(error as! CXoneChatError, CXoneChatError.illegalThreadState)
        }
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(0)
    }
    
    func testUpdateNameForLocallyCreatedThreadSuccessfully() async throws {
        let eventId = UUID()
        let thread = MockData.getThread(state: .pending)
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
        
        service!.threads = [thread]

        try await service!.provider(for: thread).updateName("New name")
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
        
        verify(socketService)
            .send(data: .any, shouldCheck: .any)
            .called(0)
    }
    
    func testUpdateNameSuccess() async throws {
        let eventId = UUID()
        let thread = MockData.getThread()
        
        given(uuidProvider)
            .next.willReturn(eventId)
        
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
        
        given(socketService)
            .send(data: .any, shouldCheck: .any).willReturn()
            .checkForConnection().willReturn()
        
        given(delegate)
            .onThreadUpdated(.any).willReturn()
        
        service!.threads = [thread]

        try await service!.provider(for: thread).updateName("New name")
        
        verify(delegate)
            .onThreadUpdated(.any)
            .called(1)
        
        verify(socketService)
            .send(data: .any, shouldCheck: .any)
            .called(1)
    }
}

// MARK: - Helpers


@available(iOS 16.0, *)
private extension ChatThreadServiceTest {
    
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
