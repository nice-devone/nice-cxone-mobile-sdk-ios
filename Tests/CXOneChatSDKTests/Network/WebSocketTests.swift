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

@testable import CXoneChatSDK
import Mockable
import XCTest

class WebSocketTests: XCTestCase {
    typealias MockTask = MockURLSessionWebSocketTaskProtocol
    typealias ReceiveProc = (Result<URLSessionWebSocketTask.Message, Error>) -> Void

    override class func setUp() {
        Matcher.register(URLSessionTaskDelegate?.self) { expect, actual in
            expect === actual
        }
    }

    func testCreation() {
        let task = MockTask()

        given(task)
            .receive(completionHandler: .any)
            .willReturn()

        let webTask = WebSocket(task: task)

        verify(task)
            .delegate(newValue: .value(webTask)).setCalled(1)
            .receive(completionHandler: .any).called(1)
    }

    private func webTask() async -> (MockTask, WebSocket, ReceiveProc?) {
        let task = MockURLSessionWebSocketTaskProtocol()
        var handler: ReceiveProc?

        given(task)
            .receive(completionHandler: .matching {
                handler = $0
                return true
            }).willReturn()

        let webTask = WebSocket(task: task)

        given(task)
            .resume().willProduce {
                webTask.sessionDidOpen()
                return ()
            }

        await webTask.resume()

        return (task, webTask, handler)
    }

    func testResume() async {
        let (task, _, _) = await webTask()

        verify(task)
            .resume().called(1)
    }

    func testReceive() async {
        let (_, webTask, onReceive) = await webTask()
        let expect = Data()
        let expectation = expectation(description: "data received")

        let cancellable = webTask.receive.sink { completion in
            XCTFail("Unexpected task completion")
        } receiveValue: { message in
            XCTAssertEqual(.data(expect), message)
            expectation.fulfill()
        }

        onReceive?(.success(.data(expect)))

        await fulfillment(of: [expectation], timeout: 1.0)

        cancellable.cancel()
    }

    func testCloseReceived() async {
        let (_, webTask, _) = await webTask()
        let expectation = expectation(description: "close received")

        let cancellable = webTask.receive.sink { completion in
            XCTAssertEqual(completion, .finished)
            expectation.fulfill()
        } receiveValue: { message in
            XCTFail("Unexpected value received")
        }

        webTask.sessionDidClose(with: .normalClosure)

        await fulfillment(of: [expectation], timeout: 1.0)

        cancellable.cancel()
    }

    func testErrorReceived() async {
        let (_, webTask, _) = await webTask()
        let expectation = expectation(description: "error received")

        let cancellable = webTask.receive.sink { completion in
            XCTAssertEqual(completion, .failure(.serverError(.abnormalClosure)))
            expectation.fulfill()
        } receiveValue: { message in
            XCTFail("Unexpected value received")
        }

        webTask.sessionDidClose(with: .abnormalClosure)

        await fulfillment(of: [expectation], timeout: 1.0)

        cancellable.cancel()
    }
}
