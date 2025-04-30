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

extension Task {

    private static var secondInNanoseconds: TimeInterval {
        1_000_000_000
    }
}

extension Task where Success == Never, Failure == Never {
    
    static func sleep(seconds: Double) async {
        let duration = UInt64(seconds * secondInNanoseconds)
        
        do {
            try await Task.sleep(nanoseconds: duration)
        } catch {
            switch error {
            case is CancellationError:
                break
            default:
                error.logError()
            }
        }
    }
}

extension Task where Failure == Error {
    
    @discardableResult
    static func retrying(
        priority: TaskPriority? = nil,
        attempts: Int = 3,
        operation: @Sendable @escaping () async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            for attempt in 0..<attempts {
                do {
                    return try await operation()
                } catch {
                    let delay = calculateExponentialBackoffDelay(attempt: attempt)
                    try await Task<Never, Never>.sleep(nanoseconds: UInt64(delay))
                    
                    continue
                }
            }
            
            try Task<Never, Never>.checkCancellation()
            
            return try await operation()
        }
    }
    
    private static func calculateExponentialBackoffDelay(attempt: Int) -> TimeInterval {
        let maxDelay = 30 * secondInNanoseconds
        let delay = Double(1 << attempt) * Double(secondInNanoseconds)
        let jitter = Double.random(in: 0...secondInNanoseconds)
        
        return min(delay + jitter, maxDelay)
    }
}
