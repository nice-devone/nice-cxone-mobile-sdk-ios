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

extension XCTest {
    
    func XCTAssertAsyncThrowsError<T>(
        _ expression: @autoclosure () async throws -> T,
        message: String? = nil,
        file: StaticString = #filePath,
        line: UInt = #line,
        errorHandler: @escaping (Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail(message ?? "Expression did not throw error as expected", file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}
