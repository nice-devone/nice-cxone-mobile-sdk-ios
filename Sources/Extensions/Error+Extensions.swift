import Foundation


extension Error {
    
    /// Logs localized description of the error with additional message, if it exists.
    func logError(_ additionalMessage: String? = nil, fun: String = #function, file: String = #file, line: Int = #line) {
        if let message = additionalMessage {
            LogManager.error("\(message) error: \(self.localizedDescription)", fun: fun, file: file, line: line)
        } else {
            LogManager.error(self.localizedDescription, fun: fun, file: file, line: line)
        }
    }
}
