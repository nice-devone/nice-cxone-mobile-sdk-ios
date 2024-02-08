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

import Foundation

/// The different types of data on a visitor event.
public enum VisitorEventDataType {
    
    /// Data for a custom visitor event. Any encoded string is accepted.
    case custom(String)
}

// MARK: - Encodable

extension VisitorEventDataType: Encodable {
    
    /// Encodes values into a native format for external representation.
    ///  - Parameter encoder: The type that can encode values.
    ///  - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .custom(let string):
            try container.encode(string)
        }
    }
}
