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

class ErrorsTests: XCTestCase {
    
    // MARK: - OperationError
    
    func testOperationErrorCustomerReconnectFailedDescription() {
        let error = OperationError(errorCode: .customerReconnectFailed, transactionId: LowercaseUUID().uuidString, errorMessage: "Customer reconnect failed")
        
        XCTAssertEqual(error.errorCode.rawValue, EventErrorCode.customerReconnectFailed.rawValue)
    }
    
    func testOperationErrorConsumerReconnectFailedDescription() {
        let error = OperationError(errorCode: .customerReconnectFailed, transactionId: LowercaseUUID().uuidString, errorMessage: "Customer reconnect failed")
        
        XCTAssertEqual(error.errorCode.rawValue, EventErrorCode.customerReconnectFailed.rawValue)
    }
    
    func testOperationErrorCustomerAuthorizationFailedDescription() {
        let error = OperationError(
            errorCode: .customerAuthorizationFailed,
            transactionId: LowercaseUUID().uuidString,
            errorMessage: "Customer Authorization failed"
        )
        
        XCTAssertEqual(error.errorCode.rawValue, EventErrorCode.customerAuthorizationFailed.rawValue)
    }
    
    func testOperationErrorConsumerAuthorizationFailedDescription() {
        let error = OperationError(
            errorCode: .customerAuthorizationFailed,
            transactionId: LowercaseUUID().uuidString,
            errorMessage: "Customer Authorization failed"
        )
        
        XCTAssertEqual(error.errorCode.rawValue, EventErrorCode.customerAuthorizationFailed.rawValue)
    }
    
    func testOperationErrorRecoveringThreadFailedDescription() {
        let error = OperationError(errorCode: .recoveringThreadFailed, transactionId: LowercaseUUID().uuidString, errorMessage: "Recovering failed")
        
        XCTAssertEqual(error.errorCode.rawValue, EventErrorCode.recoveringThreadFailed.rawValue)
    }
    
    // MARK: - ServerError
    
    func testServerErrorDescription() {
        let error = ServerError(message: "message", connectionId: LowercaseUUID().uuidString, requestId: LowercaseUUID().uuidString)
        
        XCTAssertEqual(error.errorDescription, "message")
    }
	
    // MARK: - InternalServerError

    func testDecodingInternalServerError() throws {
        let message = """
            {
                "eventId": "52E519A4-60FD-4A40-9EF8-19E051A02AAB",
                "error": {
                    "errorMessage": "Internal server error",
                    "transactionId": "dde89887-60d8-448f-aee4-df6ea3174221",
                    "errorCode": "InconsistentData"
                },
                "inputData": {
                    "thread": {
                        "id": "chat_ea02df1d-2f67-44b4-bd44-eb7808df1fdc_701BD05B-2C65-4643-9F65-9C35D73697B9",
                        "idOnExternalPlatform": "701BD05B-2C65-4643-9F65-9C35D73697B9"
                    }
                }
            }
        """
        let error: GenericEventDTO = try Data(message.utf8).decode()
        
        XCTAssertEqual(error.error?.errorCode, EventErrorCode.inconsistentData)
    }
}
