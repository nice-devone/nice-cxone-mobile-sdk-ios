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

class CXoneChatTests: XCTestCase {
    
    // MARK: - Properties
    
    private var currentExpectation = XCTestExpectation(description: "")
    
    // MARK: - Tests
    
    func testSingletonDelegateSet() {
        XCTAssertNotNil((CXoneChat.shared.connection as? ConnectionService)?.socketService.delegate)
    }
    
    func testSignOutResetProperly() {
        (CXoneChat.shared.threads as? ChatThreadsService)?.threads.append(ChatThread(id: LowercaseUUID().uuidString, state: .ready))
        XCTAssertFalse(CXoneChat.shared.threads.get().isEmpty)
        
        CXoneChat.signOut()
        
        XCTAssertTrue(CXoneChat.shared.threads.get().isEmpty)
    }
    
    func testConfigureLoggerProperly() {
        CXoneChat.configureLogger(level: .trace, verbosity: .simple)
        
        XCTAssertTrue(LogManager.verbosity == .simple)
        XCTAssertTrue(LogManager.level == .trace)
    }
    
    func testLoggerDelegateCalled() async {
        currentExpectation = XCTestExpectation(description: "testLoadThreadDataNoThrow")
        currentExpectation.expectedFulfillmentCount = 4
        
        CXoneChat.shared.logDelegate = self
        
        LogManager.error("")
        LogManager.warning("")
        LogManager.info("")
        LogManager.trace("")
        
         await fulfillment(of: [currentExpectation], timeout: 1.0)
    }
}

// MARK: - LogDelegate

extension CXoneChatTests: LogDelegate {
    
    func logError(_ message: String) {
        currentExpectation.fulfill()
    }
    
    func logWarning(_ message: String) {
        currentExpectation.fulfill()
    }
    
    func logInfo(_ message: String) {
        currentExpectation.fulfill()
    }
    
    func logTrace(_ message: String) {
        currentExpectation.fulfill()
    }
}
