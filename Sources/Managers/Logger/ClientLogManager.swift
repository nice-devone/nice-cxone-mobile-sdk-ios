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

import Foundation

actor ClientLogManager {
    
    // MARK: - Objects
    
    enum LogLevel: String {
        case info = "0"
        case warning = "1"
        case error = "2"
    }
    
    // MARK: - Properties
    
    private let session: URLSessionProtocol
    private let loggerUrl: URL
    private let deviceFingerprint: DeviceFingerprintDTO
    
    private(set) var isEnabled: Bool
    
    private static let program = "ios-dfo-chat"
    
    // MARK: - Init
    
    init?(connectionContext: ConnectionContext) {
        guard let loggerUrl = connectionContext.environment.loggerUrl(brandId: connectionContext.brandId, program: Self.program) else {
            LogManager.error("Unable to resolve logger post URL")
            return nil
        }
        
        self.session = connectionContext.session
        self.loggerUrl = loggerUrl
        self.deviceFingerprint = DeviceFingerprintDTO(deviceToken: connectionContext.deviceToken)
        self.isEnabled = true
    }
    
    // MARK: - Methods
    
    func error(_ message: String, file: StaticString = #file, line: UInt = #line) async {
        await post(level: .error, message: message, file: file, line: line)
    }
}

// MARK: - Private methods

private extension ClientLogManager {
    
    func post(level: LogLevel, message: String, file: StaticString = #file, line: UInt = #line) async {
        // Check if the logger is enabled (it can be disabled due to previous errors while trying to send logs)
        guard isEnabled else {
            return
        }
        
        var request = URLRequest(url: loggerUrl, method: .post, contentType: "application/json")
        
        let logBody: [String: Any] = [
            "level": level.rawValue,
            "message": message,
            "appVersion": CXoneChatSDKModule.version,
            "detail": [
                // Optional data
                "file": file.lastPathComponent,
                "line": line.description,
                "deviceFingerprint": deviceFingerprint.description
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: logBody, options: [])
            
            let (data, response) = try await session.fetch(for: request, file: file, line: line)
            
            if let response = response as? HTTPURLResponse, [200, 204].contains(response.statusCode) == false {
                // Disable logging to prevent cycle calling of the method
                isEnabled = false
                
                let responseBody = String(data: data, encoding: .utf8) ?? "nil"
                
                LogManager.error("Failed to log message, received status code \(response.statusCode). Response body: \(responseBody)")
            }
        } catch {
            // Disable logging to prevent cycle calling of the method
            isEnabled = false
            
            error.logError()
        }
    }
}

// MARK: - Helpers

private extension StaticString {
    /// Returns the last segment from the file path
    ///
    /// Parse `LogManager.swift` from absolute URL's string `/absolute/path/to/the/file/LogManager.swift`
    var lastPathComponent: String {
        self.description.split(separator: "/").last.map(String.init) ?? self.description
    }
}

private extension EnvironmentDetails {
 
    var loggerServerUrl: URL? {
        URL(string: loggerURL)
    }
    
    func loggerUrl(brandId: Int, program: String) -> URL? {
        loggerServerUrl & ("brandId", brandId.description) & ("program", program)
    }
}
