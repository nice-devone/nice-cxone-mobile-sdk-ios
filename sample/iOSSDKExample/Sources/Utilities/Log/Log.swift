//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

import UIKit

class Log {
    
    // MARK: - Properties
    
    static var isEnabled = false
    static var isWriteToFileEnabled = false
    private static var logContent = ""
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm:ss.SS dd.MM.yyyy"
        
        return formatter
    }()
    
    // MARK: - Methods
    
    class func message(_ message: String) {
        write(message)
    }
    
    class func error(_ error: CommonError, fun: String = #function, file: String = #file, line: Int = #line) {
        Self.error(error.localizedDescription, fun: fun, file: file, line: line)
    }
    
    class func error(_ message: String, fun: String = #function, file: String = #file, line: Int = #line) {
        let time = formatter.string(from: Date())
        
        let message = "\(time) [\(file.lastPathComponent):\(line)]: ❌ \(fun.withoutParameters) has failed: \(message)"
        
        write(message)
    }
    
    class func warning(_ error: CommonError, fun: String = #function, file: String = #file, line: Int = #line) {
        Self.warning(error.localizedDescription, fun: fun, file: file, line: line)
    }
    
    class func warning(_ message: String, fun: String = #function, file: String = #file, line: Int = #line) {
        let time = formatter.string(from: Date())
        
        let message = "\(time) [\(file.lastPathComponent):\(line)]: ⚠️ \(fun.withoutParameters): \(message)"
        
        write(message)
    }
    
    class func info(_ message: String, fun: String = #function, file: String = #file, line: Int = #line) {
        let time = formatter.string(from: Date())
        
        let message = "\(time) [\(file.lastPathComponent):\(line)]: ℹ️ \(fun.withoutParameters): \(message)"
        
        write(message)
    }
    
    class func trace(_ message: String, fun: String = #function, file: String = #file, line: Int = #line) {
        let time = formatter.string(from: Date())
        
        let message = "\(time) [\(file.lastPathComponent):\(line)]: ❇️ \(fun.withoutParameters): \(message)"
        
        write(message)
    }
    
    class func getLogShareDialog() throws -> UIActivityViewController {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CommonError.unableToParse("path")
        }
        
        let formatter = formatter
        formatter.dateFormat = "dd.MM.yyyy"
        let logFile = "\(formatter.string(from: Date())) - CXoneChat Log.txt"
        let logURL = path.appendingPathComponent(logFile)
        
        try logContent.write(to: logURL, atomically: true, encoding: .utf8)
        
        return UIActivityViewController(activityItems: [logURL], applicationActivities: nil)
    }
    
    class func removeLogs() throws {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CommonError.unableToParse("path")
        }
        
        let filePaths = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
        
        for filePath in filePaths {
            try? FileManager.default.removeItem(at: filePath)
        }
    }
}

// MARK: - Private methods

private extension Log {
    
    class func write(_ message: String) {
        guard isEnabled else {
            return
        }
        
        if Self.isWriteToFileEnabled {
            logContent += "\n" + message
        }
        
        print(message)
    }
}

// MARK: - String helpers

private extension String {
    
    var lastPathComponent: String {
        guard let url = URL(string: self) else {
            Log.error("lastPathComponent failed: could not init URL from string - \(self)")
            return self
        }
        
        return url.lastPathComponent
    }
    
    var withoutParameters: String {
        guard let substring = substring(from: "(", to: ")"), !substring.isEmpty else {
            return self
        }
        guard let lhs = firstIndex(of: "("), let rhs = firstIndex(of: ")") else {
            return self
        }
        
        let startIndex = index(after: lhs)
        let endIndex = index(before: rhs)
        
        let range = startIndex...endIndex
        var result = self
        
        result.removeSubrange(range)
        return result
    }
}
