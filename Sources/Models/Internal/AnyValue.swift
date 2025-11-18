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

/// A polymorphic enum that represents any JSON-compatible value.
///
/// `AnyValue` is designed to encapsulate a wide range of data types commonly found in JSON,
/// including strings, numbers, booleans, arrays, dictionaries, and null values. It conforms to
/// `Codable` and `Equatable`, making it suitable for encoding/decoding and comparison.
///
/// This enum is particularly useful when working with dynamic or loosely-typed JSON structures
/// where the type of a value is not known in advance.
///
/// - Cases:
///   - string: A `String` value.
///   - int: An `Int` value.
///   - double: A `Double` value.
///   - bool: A `Bool` value.
///   - array: An array of `AnyValue` elements.
///   - dictionary: A dictionary with `String` keys and `AnyValue` values.
///   - null: A null value.
///
/// - Note: The decoding initializer attempts to infer the correct case by trying each supported
///   type in a specific order. If none match, it throws a `DecodingError`.
enum AnyValue: Equatable {
    
    // MARK: - Cases
    
    case null
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([AnyValue])
    case dictionary([String: AnyValue])
}

// MARK: - Codable

extension AnyValue: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([AnyValue].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: AnyValue].self) {
            self = .dictionary(value)
        } else {
            throw DecodingError.typeMismatch(
                AnyValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON value")
            )
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .null:
            break
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        }
    }
}
