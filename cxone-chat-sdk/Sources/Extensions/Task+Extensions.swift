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
            error.logError()
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
