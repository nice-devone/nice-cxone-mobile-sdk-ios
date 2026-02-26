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

/// A type that represents an entity with a finite lifetime.
///
/// Conforming types provide the creation timestamp and the lifetime duration
/// in seconds. Use the `isExpired` convenience to determine when the entity
/// should be considered invalid.
protocol Expirable {
    /// Time interval, in seconds, after which the instance should be treated as expired.
    /// For example, a token with `expiresIn = 3600` is valid for one hour from `createdDate`.
    var expiresIn: Int { get }
    /// The date and time when the instance was created (used as the start of its validity window).
    var createdDate: Date { get }
}

// MARK: - Helpers

extension Expirable {
    
    private static var safetyMarginSeconds: Int {
        30
    }
    
    /// Indicates whether the instance should be considered expired.
    ///
    /// This uses the difference in seconds between `createdDate`
    /// and the current time to determine whether the instance has exceeded its allowed lifetime.
    var isExpired: Bool {
        let date = Calendar.current.dateComponents([.second], from: createdDate, to: .now)
        let elapsedSeconds = date.second ?? 0
                
        return elapsedSeconds + Self.safetyMarginSeconds >= expiresIn
    }
}
