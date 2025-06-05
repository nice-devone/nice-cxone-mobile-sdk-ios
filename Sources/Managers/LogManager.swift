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

import CXoneGuideUtility
import Foundation

// MARK: - Implementation

/// The log manager of the CXoneChat SDK.
enum LogManager: StaticLogger {

    // MARK: - StaticLogger implementation

    nonisolated(unsafe) static var instance: LogWriter? = PrintLogWriter()
    static let category: String? = "CORE"

    // MARK: - Methods

    static func error(
        _ error: Error,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        self.error(error.localizedDescription, file: file, line: line)
    }
}
