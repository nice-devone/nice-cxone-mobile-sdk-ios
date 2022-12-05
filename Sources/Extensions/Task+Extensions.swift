import Foundation


extension Task where Success == Never, Failure == Never {
    
    static func sleep(seconds: Double) async {
        let duration = UInt64(seconds * 1_000_000_000)
        
        do {
            try await Task.sleep(nanoseconds: duration)
        } catch {
            error.logError()
        }
    }
}
