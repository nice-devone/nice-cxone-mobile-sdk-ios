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
import Foundation
import Mockable
import XCTest

final class SocketDelegateManagerTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testAddDelegate() {
        let delegate = MockCXoneChatDelegate()
        given(delegate)
            .onUnexpectedDisconnect().willReturn()

        let manager = SocketDelegateManager()

        manager.add(delegate: delegate)

        manager.onUnexpectedDisconnect()

        verify(delegate)
            .onUnexpectedDisconnect()
            .called(1)
    }

    func testRemoveDelegate() {
        let delegate1 = MockCXoneChatDelegate()
        given(delegate1)
            .onUnexpectedDisconnect().willReturn()
        let delegate2 = MockCXoneChatDelegate()

        let manager = SocketDelegateManager()

        manager.add(delegate: delegate1)
        manager.add(delegate: delegate2)

        manager.remove(delegate: delegate2)

        manager.onUnexpectedDisconnect()

        verify(delegate1)
            .onUnexpectedDisconnect()
            .called(1)
    }

    func testUnexpectedDisconnect() {
        let delegate = MockCXoneChatDelegate(policy: .relaxed)
        let manager = SocketDelegateManager()

        manager.add(delegate: delegate)

        manager.onUnexpectedDisconnect()

        verify(delegate)
            .onUnexpectedDisconnect()
            .called(1)
    }

    func testChatUpdated() {
        let delegate = MockCXoneChatDelegate(policy: .relaxed)
        let manager = SocketDelegateManager()

        manager.add(delegate: delegate)

        manager.onChatUpdated(.closed, mode: .liveChat)

        verify(delegate)
            .onChatUpdated(.value(.closed), mode: .value(.liveChat))
            .called(1)
    }

    func testThreadUpdated() {
        let delegate = MockCXoneChatDelegate(policy: .relaxed)
        let manager = SocketDelegateManager()
        let expected = ChatThread(id: UUID(), state: .closed)

        manager.add(delegate: delegate)

        manager.onThreadUpdated(expected)

        verify(delegate)
            .onThreadUpdated(.matching { actual in
                expected.id == actual.id
            })
            .called(1)
    }

    func testThreadsUpdated() {
        let delegate = MockCXoneChatDelegate(policy: .relaxed)
        let manager = SocketDelegateManager()
        let expected = ChatThread(id: UUID(), state: .closed)

        manager.add(delegate: delegate)

        manager.onThreadsUpdated([expected])

        verify(delegate)
            .onThreadsUpdated(.matching { actual in
                expected.id == actual[0].id
            })
            .called(1)
    }

    func testCustomEventMessage() {
        let delegate = MockCXoneChatDelegate(policy: .relaxed)
        let manager = SocketDelegateManager()

        manager.add(delegate: delegate)

        manager.onCustomEventMessage(Data())

        verify(delegate)
            .onCustomEventMessage(.value(Data()))
            .called(1)
    }
    
    func testAgentTyping() {
        let delegate = MockCXoneChatDelegate(policy: .relaxed)
        let manager = SocketDelegateManager()
        let uuid = UUID()
        let agent = AgentMapper.map(MockData.agent)

        manager.add(delegate: delegate)

        manager.onAgentTyping(true, agent: agent, threadId: uuid)

        verify(delegate)
            .onAgentTyping (.value(true), agent: .matching { $0.id == agent.id }, threadId: .value(uuid))
            .called(1)
    }

    func testContactCustomFieldsSet() {
        let delegate = MockCXoneChatDelegate(policy: .relaxed)
        let manager = SocketDelegateManager()

        manager.add(delegate: delegate)

        manager.onContactCustomFieldsSet()

        verify(delegate)
            .onContactCustomFieldsSet()
            .called(1)
    }

    func testCustomerCustomFieldsSet() {
        let delegate = MockCXoneChatDelegate(policy: .relaxed)
        let manager = SocketDelegateManager()

        manager.add(delegate: delegate)

        manager.onCustomerCustomFieldsSet()

        verify(delegate)
            .onCustomerCustomFieldsSet()
            .called(1)
    }

    func testError() {
        let delegate = MockCXoneChatDelegate(policy: .relaxed)
        let manager = SocketDelegateManager()

        manager.add(delegate: delegate)

        manager.onError(CXoneChatError.attachmentError)

        verify(delegate)
            .onError(.matching { error in
                if let error = error as? CXoneChatError {
                    return error == .attachmentError
                } else {
                    return false
                }
            })
            .called(1)
    }

    func testTokenRefreshFailed() {
        let delegate = MockCXoneChatDelegate(policy: .relaxed)
        let manager = SocketDelegateManager()

        manager.add(delegate: delegate)

        manager.onTokenRefreshFailed()

        verify(delegate)
            .onTokenRefreshFailed()
            .called(1)
    }

    func testProactivePopupAction() {
        let delegate = MockCXoneChatDelegate(policy: .relaxed)
        let manager = SocketDelegateManager()
        let expect = [ "some": "data" ]
        let uuid = UUID()

        manager.add(delegate: delegate)

        manager.onProactivePopupAction(data: expect, actionId: uuid)

        verify(delegate)
            .onProactivePopupAction(
                data: .matching { actual in
                    if let actual = actual as? [String: String] {
                        return actual == expect
                    } else {
                        return false
                    }
                },
                actionId: .value(uuid)
            )
            .called(1)
    }
}
