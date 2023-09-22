import Foundation

extension Error {
    
    /// Logs localized description of the error with additional message, if it exists.
    func logError(_ additionalMessage: String? = nil, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        if let message = additionalMessage {
            LogManager.error("\(message) error: \(self.localizedDescription)", fun: fun, file: file, line: line)
        } else {
            LogManager.error(self.localizedDescription, fun: fun, file: file, line: line)
        }
    }
}
