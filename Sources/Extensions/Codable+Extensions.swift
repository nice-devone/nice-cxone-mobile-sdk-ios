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

// MARK: - KeyedDecodingContainer

extension KeyedDecodingContainer {
    
    func decodeUUID(forKey key: Key) throws -> UUID {
        if let eventId = try decodeIfPresent(UUID.self, forKey: key) {
            return eventId
        } else if let eventId = try decodeIfPresent(LowerCaseUUID.self, forKey: key)?.uuid {
            return eventId
        } else {
            throw DecodingError.valueNotFound(UUID.self, DecodingError.Context(codingPath: codingPath, debugDescription: key.stringValue))
        }
    }
    
    func decodeUUIDIfPresent(forKey key: Key) throws -> UUID? {
        if let eventId = try decodeIfPresent(UUID.self, forKey: key) {
            return eventId
        } else if let eventId = try decodeIfPresent(LowerCaseUUID.self, forKey: key)?.uuid {
            return eventId
        } else {
            return nil
        }
    }
    
    func decodeISODate(forKey key: Key) throws -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withFullTime, .withTimeZone, .withColonSeparatorInTimeZone]
        
        let stringValue = try decode(String.self, forKey: key)
        
        guard let date = formatter.date(from: stringValue) else {
            throw DecodingError.valueNotFound(Date.self, DecodingError.Context(codingPath: codingPath, debugDescription: key.stringValue))
        }
        
        return date
    }
    
    func decodeISODateIfPresent(forKey key: Key) throws -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withFullTime, .withTimeZone, .withColonSeparatorInTimeZone]
        
        guard let stringValue = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        guard let date = formatter.date(from: stringValue) else {
            throw DecodingError.valueNotFound(Date.self, DecodingError.Context(codingPath: codingPath, debugDescription: key.stringValue))
        }
        
        return date
    }
}

// MARK: - KeyedEncodingContainer

extension KeyedEncodingContainer {
    
    mutating func encodeISODate(_ date: Date?, forKey key: Key, withFractionalSeconds: Bool = false) throws {
        guard let date = date else {
            return
        }
        
        let formatter = ISO8601DateFormatter()
        
        if withFractionalSeconds {
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        }
        
        let string = formatter.string(from: date)
        
        try encode(string, forKey: key)
    }
    
    mutating func encodeISODateIfPresent(_ date: Date?, forKey key: Key, withFractionalSeconds: Bool = false) throws {
        guard let date = date else {
            return
        }
        
        let formatter = ISO8601DateFormatter()
        
        if withFractionalSeconds {
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        }
        
        let string = formatter.string(from: date)
        
        try encodeIfPresent(string, forKey: key)
    }
}
