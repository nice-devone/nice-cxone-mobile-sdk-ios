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

extension TimeInterval {
    
    /// One second in nanoseconds
    static let secondInNanoseconds: Double = 1_000_000_000
    
    /// Calculates an exponential backoff delay with jitter, capped at 30 seconds.
    ///
    /// - Parameter attempt: The retry attempt number (starting from 0).
    /// - Returns: A delay in seconds.
    static func calculateExponentialBackoffDelay(attempt: Int) -> TimeInterval {
        let maxDelay: TimeInterval = 30 // seconds
        let cappedAttempt = min(attempt, 10) // Prevent overflow (2^10 = 1024)
        let baseDelay = pow(1.3, Double(cappedAttempt)) // Exponential backoff
        let jitter = Double.random(in: 0...1) // Jitter in seconds
        
        return min(baseDelay + jitter, maxDelay)
    }
}
