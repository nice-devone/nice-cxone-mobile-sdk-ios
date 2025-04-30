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

import XCTest
@testable import CXoneChatSDK

final class TaskTests: XCTestCase {
    
    // MARK: - Properties
    
    private let attempts = 3
    private var callCount = 0
    
    // MARK: - Tests
    
    func testDelayedTaskRetriesSuccessfully() async throws {
        let result = try await Task.retrying(attempts: attempts) {
            try await self.delayedAsyncCall()
        }.value
        
        XCTAssertEqual(result, "Done")
    }
}

// MARK: - Private methods

private extension TaskTests {
    
    func delayedAsyncCall() async throws -> String {
        // Make the last call successful
        if callCount == attempts {
            return "Done"
        } else {
            callCount += 1
            
            throw CXoneChatError.serverError
        }
    }
}
