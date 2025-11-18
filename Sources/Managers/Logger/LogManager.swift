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

    private static var internalLogger: ClientLogManager?
    
    // MARK: - Lifecycle
    
    /// Returns a `LogWriter` instance for internal logging of the SDK.
    ///
    /// This method creates a `ClientLogManager` instance using the provided `ConnectionContext` for internal logging,
    /// which is used for user flow tracing in the SDK.
    ///
    /// - Warning: This logger can be used only if the SDK has been already prepared, ie. ``ConnectionService.prepared(brandId:channelId:)`` has been called.
    /// - Parameter connectionContext: The `ConnectionContext` used to create the logger.
    static func configureInternalLogger(connectionContext: ConnectionContext) {
        guard let manager = ClientLogManager(connectionContext: connectionContext) else {
            LogManager.error("Failed to create ClientLogManager")
            return
        }
        
        internalLogger = manager
    }
    
    // MARK: - Methods

    static func error(_ error: Error, file: StaticString = #file, line: UInt = #line) {
        Self.error(error.localizedDescription, file: file, line: line)
    }
    
    static func error(_ message: String, file: StaticString = #file, line: UInt = #line) {
        log(
            message,
            level: .error,
            category: category,
            file: file,
            line: line
        )
        
        Task { [weak internalLogger] in
            await internalLogger?.error(message, file: file, line: line)
        }
    }
}
