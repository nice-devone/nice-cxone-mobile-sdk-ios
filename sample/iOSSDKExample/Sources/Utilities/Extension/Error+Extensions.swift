import Foundation

extension Error {
    
    /// Logs localized description of the error with additional message, if it exists.
    func logError(_ additionalMessage: String? = nil, fun: String = #function, file: String = #file, line: Int = #line) {
        if let message = additionalMessage {
            Log.error("\(message) error: \(self.localizedDescription)", fun: fun, file: file, line: line)
        } else {
            Log.error(self.localizedDescription, fun: fun, file: file, line: line)
        }
    }
}
