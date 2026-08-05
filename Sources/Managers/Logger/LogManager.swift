//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneGuideUtility
import Foundation

// MARK: - Implementation

/// The log manager of the CXoneChat SDK.
enum LogManager: StaticLogger {

    // MARK: - StaticLogger implementation

    private static let _instance = SafeAccessContainer<LogWriter?>(PrintLogWriter())
    static var instance: LogWriter? {
        get { _instance.content }
        set {
            _instance.mutate { content in
                content = newValue
            }
        }
    }

    static let category: String? = "CORE"

    private static let _internalLogger = SafeAccessContainer<ClientLogManager?>(nil)
    private static var internalLogger: ClientLogManager? {
        get { _internalLogger.content }
        set {
            _internalLogger.mutate { content in
                content = newValue
            }
        }
    }
    
    // MARK: - Lifecycle
    
    /// Returns a `LogWriter` instance for internal logging of the SDK.
    ///
    /// This method creates a `ClientLogManager` instance using the provided `ConnectionContext` for internal logging,
    /// which is used for user flow tracing in the SDK.
    ///
    /// - Warning: This logger can be used only if the SDK has been already prepared, ie. ``ConnectionService.prepared(brandId:channelId:)`` has been called.
    /// - Parameter connectionContext: The `ConnectionContext` used to create the logger.
    @MainActor
    static func configureInternalLogger(connectionContext: ConnectionContext) async {
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
        
        Task {
            await LogManager.internalLogger?.error(message, file: file, line: line)
        }
    }
}
