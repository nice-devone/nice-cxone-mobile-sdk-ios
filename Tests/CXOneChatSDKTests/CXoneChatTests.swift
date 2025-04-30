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
import CXoneGuideUtility
import Mockable
import XCTest

class CXoneChatTests: XCTestCase {

    // MARK: - Properties

    private var currentExpectation = XCTestExpectation(description: "")

    // MARK: - Tests

    func testSingletonDelegateSet() {
        XCTAssertNotNil((CXoneChat.shared.connection as? ConnectionService)?.socketService.delegate)
    }

    func testSignOutResetProperly() {
        (CXoneChat.shared.threads as? ChatThreadListService)?.threads.append(MockData.getThread(state: .ready))
        XCTAssertFalse(CXoneChat.shared.threads.get().isEmpty)

        CXoneChat.signOut()

        XCTAssertTrue(CXoneChat.shared.threads.get().isEmpty)
    }

    func testLogManagerFatal() {
        let logWriter = MockLogWriter(policy: .relaxed)

        CXoneChat.logWriter = logWriter
        defer { CXoneChat.logWriter = nil }

        LogManager.fatal("")

        verify(logWriter)
            .log(record: .matching { $0.level == .fatal })
            .called(1)
    }

    func testLogManagerError() {
        let logWriter = MockLogWriter(policy: .relaxed)

        CXoneChat.logWriter = logWriter
        defer { CXoneChat.logWriter = nil }

        LogManager.error("")

        verify(logWriter)
            .log(record: .matching { $0.level == .error })
            .called(1)
    }

    func testLogManagerWarning() {
        let logWriter = MockLogWriter(policy: .relaxed)

        CXoneChat.logWriter = logWriter
        defer { CXoneChat.logWriter = nil }

        LogManager.warning("")

        verify(logWriter)
            .log(record: .matching { $0.level == .warning })
            .called(1)
    }

    func testLogManagerInfo() {
        let logWriter = MockLogWriter(policy: .relaxed)

        CXoneChat.logWriter = logWriter
        defer { CXoneChat.logWriter = nil }

        LogManager.info("")

        verify(logWriter)
            .log(record: .matching { $0.level == .info })
            .called(1)
    }

    func testLogManagerDebug() {
        let logWriter = MockLogWriter(policy: .relaxed)

        CXoneChat.logWriter = logWriter
        defer { CXoneChat.logWriter = nil }

        LogManager.debug("")

        verify(logWriter)
            .log(record: .matching { $0.level == .debug })
            .called(1)
    }

    func testLogManagerTrace() {
        let logWriter = MockLogWriter(policy: .relaxed)

        CXoneChat.logWriter = logWriter
        defer { CXoneChat.logWriter = nil }

        LogManager.trace("")

        verify(logWriter)
            .log(record: .matching { $0.level == .trace })
            .called(1)
    }
}
