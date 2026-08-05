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

import Foundation

extension String {
    
    // MARK: - Properties
    
    static let emailRegEx = #"^[A-Za-z0-9_%+-]+(?:\.[A-Za-z0-9_%+-]+)*@(?:[A-Za-z0-9-]+\.)+[A-Za-z]{2,9}$"#
    
    var formattedJSON: String? {
        guard !self.isEmpty, let data = self.data(using: .utf8) else {
            return nil
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard JSONSerialization.isValidJSONObject(jsonObject) else {
                return self
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            
            return String(data: jsonData, encoding: .utf8)
        } catch {
            error.logError()
            
            return nil
        }
    }

    /// Returns the string with the values of well-known credential-bearing JSON keys masked, safe for logging.
    ///
    /// Outbound WebSocket payloads embed the connection/transaction token (see
    /// ``SendMessageEventDataDTO`` and related event DTOs). Logging the raw payload — even under
    /// `#if DEBUG` — leaks the credential into device/console logs where it may end up in support
    /// bundles or crash reports. This mirrors ``URL/redactingTransactionToken`` for the URL query
    /// path and covers the field names most commonly used for credentials in this SDK's payloads:
    /// `token`, `accessToken`, `refreshToken`, `authorization`.
    ///
    /// - Note: Regex-based redaction (not JSON parsing) so it works on both pretty-printed and
    ///   compact JSON, and so it's safe to call on strings that fail JSON parsing.
    var redactingJSONCredentials: String {
        let keys = ["token", "accessToken", "refreshToken", "authorization"]
        var result = self
        for key in keys {
            // Match: "<key>" : "<any non-quote chars>"  — replace the value with <redacted>.
            let pattern = #""\#(key)"\s*:\s*"[^"]*""#
            result = result.replacingOccurrences(
                of: pattern,
                with: "\"\(key)\": \"<redacted>\"",
                options: [.regularExpression]
            )
        }
        return result
    }
    
    // MARK: - Methods
    
    func substring(to: String) -> String? {
        guard let range = self.range(of: to) else {
            return nil
        }
        
        return String(self[..<range.lowerBound])
    }
    
    func substring(from: String, to: String) -> String? {
        guard let range = self.range(of: from) else {
            return nil
        }
        
        let subString = String(self[range.upperBound...])
        
        guard let range = subString.range(of: to) else {
            return nil
        }
        
        return String(subString[..<range.lowerBound])
    }
    
    func mapNonEmpty(_ transform: (String) throws -> String) rethrows -> String? {
        guard self != "" else {
            return nil
        }
        
        return try? transform(self)
    }
    
    func nilIfEmpty() -> String? {
        isEmpty ? nil : self
    }
    
    func isValid(regex: String) -> Bool {
        self.range(of: regex, options: [.regularExpression]) != nil
    }
}
