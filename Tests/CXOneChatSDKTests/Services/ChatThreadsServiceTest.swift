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

import Combine
@testable import CXoneChatSDK
import Mockable
import XCTest

@available(iOS 16.0, *)
final class ChatThreadsServiceTest: XCTestCase {
    private let messagesProvider = MockMessagesProvider()
    private let contactFields = MockContactCustomFieldsProvider()
    private let customerFields = MockCustomerCustomFieldsProvider()
    private let socketService = MockSocketService()
    private let connectionContext = MockConnectionContext()
    private lazy var eventsService = EventsService(connectionContext: connectionContext)
    private let dateProvider = DateProviderMock()
    private let uuidProvider = MockUUIDProvider()
    private let subject = PassthroughSubject<ReceivedEvent, Never>()
    private lazy var events = subject.eraseToAnyPublisher()
    private let delegate = MockCXoneChatDelegate()

    var service: ChatThreadsService?

    override func setUp() {
        given(socketService)
            .events.willReturn(events)
            .connectionContext.willReturn(connectionContext)

        given(connectionContext)
            .brandId.willReturn(4077)
            .channelId.willReturn("M*A*S*H")
            .visitorId.willReturn(UUID())
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: true))
            .customer.willReturn(MockData.customerIdentity)

        service = ChatThreadsService(
            messagesProvider: messagesProvider,
            contactFields: contactFields,
            customerFields: customerFields,
            socketService: socketService,
            eventsService: eventsService,
            delegate: delegate
        )
    }

    func testArchiveThreadSuccess() async throws {
        let eventId = UUID()
        let thread = ChatThread(
            id: UUID(),
            state: .ready
        )
        let expectation = expectation(description: "Service Complete")

        UUID.provider = uuidProvider
        given(uuidProvider)
            .next.willReturn(eventId)

        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                self.subject.send(
                    GenericEventDTO(
                        eventId: eventId.asLowerCaseUUID,
                        eventType: .threadArchived,
                        postback: nil,
                        error: nil,
                        internalServerError: nil
                    )
                )
            }
            .checkForConnection().willReturn()

        given(delegate)
            .onThreadUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }

        given(connectionContext)
            .threads.willProduce { [thread] }

        try service?.archive(thread)

        await fulfillment(of: [expectation], timeout: 10.0)

        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(1)

        verify(delegate)
            .onThreadUpdated(.matching {
                $0.id == thread.id // TODO: - Add state check back when the MessageService is refactored to the ChatThreadService (&& $0.state == .closed)
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

        given(delegate)
            .onThreadUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }

        given(connectionContext)
            .threads.willReturn([thread])

        try service?.archive(thread)

        await fulfillment(of: [expectation], timeout: 10.0)

        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(0)

        verify(delegate)
            .onThreadUpdated(.matching {
                $0.id == thread.id // TODO: - Add state check back when the MessageService is refactored to the ChatThreadService (&& $0.state == .closed)
            })
            .called(1)
    }


    func testArchiveThreadFailure() async throws {
        let eventId = UUID()
        let thread = ChatThread(
            id: UUID(),
            state: .ready
        )
        let expectation = expectation(description: "Service Complete")

        UUID.provider = uuidProvider
        given(uuidProvider)
            .next.willReturn(eventId)

        given(socketService)
            .send(data: .any, shouldCheck: .any).willProduce { _, _ in
                self.subject.send(
                    OperationError(
                        errorCode: .inconsistentData,
                        transactionId: eventId.asLowerCaseUUID,
                        errorMessage: "Unknown Event"
                    )
                )
            }
            .checkForConnection().willReturn()

        given(delegate)
            .onThreadUpdated(.any).willProduce { _ in
                expectation.fulfill()
                return ()
            }
            .onError(.any).willReturn()

        given(connectionContext)
            .threads.willReturn([thread])

        try service?.archive(thread)

        await fulfillment(of: [expectation], timeout: 10.0)

        verify(socketService)
            .send(data: .any, shouldCheck: .value(true))
            .called(1)

        verify(delegate)
            .onThreadUpdated(.matching {
                $0.id == thread.id && $0.state == .ready
            })
            .called(1)
            .onError(.any)
            .called(1)
    }

    func testArchiveUnknownThreadThrows() async throws {
        let eventId = UUID()
        let thread = ChatThread(
            id: UUID(),
            state: .ready
        )

        UUID.provider = uuidProvider
        given(uuidProvider)
            .next.willReturn(eventId)

        given(socketService)
            .checkForConnection().willReturn()

        given(connectionContext)
            .threads.willReturn([])

        XCTAssertThrowsError(try service?.archive(thread)) { error in
            XCTAssertIs(error, CXoneChatError.self)
        }
    }

    func testArchiveClosedThreadThrows() async throws {
        let eventId = UUID()
        let thread = ChatThread(
            id: UUID(),
            state: .closed
        )

        UUID.provider = uuidProvider
        
        given(uuidProvider)
            .next.willReturn(eventId)

        given(socketService)
            .checkForConnection().willReturn()
        
        given(connectionContext)
            .threads.willReturn([thread])

        XCTAssertThrowsError(try service?.archive(thread)) { error in
            XCTAssertIs(error, CXoneChatError.self)
        }
    }

    func testArchiveSingleThreadModeThrows() async throws {
        given(connectionContext)
            .channelConfig.willReturn(MockData.getChannelConfiguration(isMultithread: false))

        let eventId = UUID()
        let thread = ChatThread(
            id: UUID(),
            state: .ready
        )

        UUID.provider = uuidProvider
        given(uuidProvider)
            .next.willReturn(eventId)

        given(socketService)
            .checkForConnection().willReturn()

        given(connectionContext)
            .threads.willReturn([])

        XCTAssertThrowsError(try service?.archive(thread)) { error in
            XCTAssertIs(error, CXoneChatError.self)
        }
    }
}
