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

// MARK: - Dictionary<String, AnyValue>

extension [String: AnyValue] {
    
    /// Checks if the dictionary contains the specified message parameter with the given value.
    ///
    /// - Parameters:
    ///   - parameter: The ``MessageParameter`` to look for, e.g. `.isUnsupportedMessageTypeAnswer`.
    ///   - value: The `AnyValue` to compare against.
    /// - Returns: `true` if the parameter exists and its value matches; otherwise, `false`.
    func contains(_ parameter: MessageParameter, withValue value: AnyValue) -> Bool {
        guard let param = self[parameter.rawValue] else {
            return false
        }
        
        return param == value
    }
    
    /// Checks if the dictionary contains at least one of the specified parameters set to `.bool(true)`.
    ///
    /// - Parameter parameters: A variadic list of ``MessageParameter`` to check.
    /// - Returns: `true` if any parameter is present with value `.bool(true)`; otherwise, `false`.
    func hasOneOf(_ parameters: MessageParameter...) -> Bool {
        parameters.first { self.contains($0, withValue: .bool(true)) } != nil
    }
}

// MARK: - Dictionary<MessageParameter, AnyValue>

extension [MessageParameter: AnyValue] {
    
    /// Checks if the dictionary contains the specified message parameter with the given value.
    ///
    /// - Parameters:
    ///   - parameter: The ``MessageParameter`` to look for, e.g. `.isUnsupportedMessageTypeAnswer`.
    ///   - value: The `AnyValue` to compare against.
    /// - Returns: `true` if the parameter exists and its value matches; otherwise, `false`.
    func contains(_ parameter: MessageParameter, withValue value: AnyValue) -> Bool {
        guard let param = self[parameter] else {
            return false
        }
        
        return param == value
    }
    
    /// Checks if the dictionary contains at least one of the specified parameters set to `.bool(true)`.
    ///
    /// - Parameter parameters: A variadic list of ``MessageParameter`` to check.
    /// - Returns: `true` if any parameter is present with value `.bool(true)`; otherwise, `false`.
    func hasOneOf(_ parameters: MessageParameter...) -> Bool {
        parameters.first { self.contains($0, withValue: .bool(true)) } != nil
    }
}
