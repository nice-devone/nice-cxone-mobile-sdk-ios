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
import XCTest

class ErrorsTests: XCTestCase {
    
    // MARK: - OperationError
    
    func testOperationErrorDescription() {
        let error = OperationError(
            eventId: UUID.provide(),
            errorCode: .recoveringThreadFailed,
            transactionId: LowerCaseUUID(),
            errorMessage: "Recovering failed"
        )
        
        XCTAssertEqual(error.errorCode.rawValue, ErrorCode.recoveringThreadFailed.rawValue)
    }
    
    // MARK: - ServerError
    
    func testServerErrorDescription() {
        let error = ServerError(message: "message", connectionId: UUID(), requestId: UUID())
        
        XCTAssertEqual(error.errorDescription, "message")
    }
}
