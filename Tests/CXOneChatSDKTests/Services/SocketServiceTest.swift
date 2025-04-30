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

final class SocketServiceTest: XCTestCase {
    lazy var now = Date()
    lazy var connectionContext = MockConnectionContext()
    lazy var session = MockURLSessionProtocol()
    lazy var webTask = MockWebSocketProtocol()
    lazy var socketMessages = PassthroughSubject<URLSessionWebSocketTask.Message, WebSocketError>()
    lazy var socketService = SocketServiceImpl(connectionContext: connectionContext)

    override class func setUp() {
        Date.provider = DateProviderMock()
    }

    override func setUp() {
        given(connectionContext)
            .session.willReturn(session)
    }

    override func tearDown() {
        // Make sure the webtack can be cancelled
        given(webTask)
            .cancel(with: .any, reason: .any).willReturn()

        // Make sure the socketService gets cancelled after all tests are completed, otherwise
        // it may leave async tasks pending that can cause later unrelated failures.
        socketService.disconnect(unexpectedly: true)
    }

    func testIsConnectedThrowsIfClosed() {
        given(connectionContext)
            .chatState.willReturn(.closed)
            .session.willReturn(session)

        XCTAssertThrowsError(try socketService.checkForConnection())
    }

    func testIsConnectedThrowsIfNoSocket() {
        given(connectionContext)
            .chatState.willReturn(.connected)

        XCTAssertThrowsError(try socketService.checkForConnection())
    }

    func testConnect() {
        let url = URL(string: "https://some.where.com/path")!

        given(session)
            .webSocketProtocol(with: .any).willProduce { _ in self.webTask }

        given(webTask)
            .send(.any, completionHandler: .any).willReturn()
            .cancel(with: .any, reason: .any).willReturn()
            .resume().willReturn()
            .receive.willReturn(socketMessages)

        XCTAssertTrue(socketService.cancellables.isEmpty)
        
        socketService.connect(socketURL: url)

        XCTAssertFalse(socketService.cancellables.isEmpty)
        
        // should get a task from the session
        verify(session)
            .webSocketProtocol(with: .value(url)).called(1)

        // and resume the task
        verify(webTask)
            .resume().called(1)
        
        socketService.disconnect(unexpectedly: false)
        
        XCTAssertTrue(socketService.cancellables.isEmpty)
    }

    func testDisconnect() {
        let url = URL(string: "https://some.where.com/path")!

        given(session)
            .webSocketProtocol(with: .any).willProduce { _ in self.webTask }

        given(webTask)
            .resume().willReturn()
            .receive.willReturn(socketMessages)
            .cancel(with: .any, reason: .any).willReturn()

        socketService.connect(socketURL: url)

        socketService.disconnect(unexpectedly: true)

        verify(webTask)
            .cancel(with: .value(.goingAway), reason: .value(nil)).called(1)
    }

    func testSend() async throws {
        let url = URL(string: "https://some.where.com/path")!

        given(session)
            .webSocketProtocol(with: .any).willProduce { _ in self.webTask }

        given(webTask)
            .resume().willReturn()
            .receive.willReturn(socketMessages)
            .send(.any, completionHandler: .any).willReturn()

        socketService.connect(socketURL: url)

        try await socketService.send(data: "some message".data(using: .utf8)!, shouldCheck: false)

        verify(webTask)
            .send(
                .matching { $0 == .string("some message") },
                completionHandler: .any
            ).called(1)
    }

    func testTransfersEvents() async throws {
        let url = URL(string: "https://some.where.com/path")!

        given(session)
            .webSocketProtocol(with: .any).willProduce { _ in self.webTask }

        given(webTask)
            .resume().willReturn()
            .receive.willReturn(socketMessages)

        socketService.connect(socketURL: url)

        let archiveReceived = expectation(description: "Archive Received")

        let listener = socketService.events.sink { event in
            self.XCTAssertIs(event, GenericEventDTO.self)
            archiveReceived.fulfill()
        }

        socketMessages.send(.string(try loadBundleString(from: "ThreadArchived", type: "json")))

        await fulfillment(of: [archiveReceived])
        
        listener.cancel()
    }

    func testProcessEventInS3DownloadAndDecodeCorrectly() async throws {
        let url = URL(string: "https://some.where.com/path")!
        let requestData = try loadBundleString(from: "EventInS3+ThreadRecovered", type: "json")
        let responseData = try self.loadBundleData(from: "ThreadRecoveredEvent", type: "json")
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        var cancellables = [AnyCancellable]()

        guard let request = requestData.data(using: .utf8)!.toReceivedEvent() as? EventInS3DTO else {
            XCTFail("Can't load EventInS3 from data file")
            return
        }

        given(session)
            .webSocketProtocol(with: .any).willProduce { _ in self.webTask }
            .data(
                for: .matching { $0.url == request.url },
                delegate: .any
            ).willReturn((responseData, response))

        given(webTask)
            .resume().willReturn()
            .receive.willReturn(socketMessages)

        socketService.connect(socketURL: url)

        let threadRecoverReceived = expectation(description: "ThreadRecovered Received")

        // set up to make sure we receive the event we expect to.
        socketService.events.sink { event in
            if event is ThreadRecoveredEventDTO {
                threadRecoverReceived.fulfill()
            }
        }
        .store(in: &cancellables)

        socketMessages.send(.string(requestData))

        await fulfillment(of: [threadRecoverReceived])
    }
}
