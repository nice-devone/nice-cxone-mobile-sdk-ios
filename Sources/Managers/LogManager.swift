import Foundation


// MARK: - Protocol

/// Delegate methods for the LogManager.
public protocol LogDelegate: AnyObject {
    /// Forwards an error from the CXoneChatSDK to the host application.
    /// - Parameter message: The content of the error message.
    func logError(_ message: String)

    /// Forwards a warning from the CXoneChatSDK to the host application.
    /// - Parameter message: The content of the warning message.
    func logWarning(_ message: String)

    /// Forwards an info from the CXoneChatSDK to the host application.
    /// - Parameter message: The content of the info message.
    func logInfo(_ message: String)

    /// Forwards a trace from the CXoneChatSDK to the host application.
    /// - Parameter message: The content of the trace message.
    func logTrace(_ message: String)
}


// MARK: - Implementation

/// The log manager of the CXoneChat SDK.
public class LogManager {
    
    // MARK: - Configuration enums
    
    /// Configuration of a log level.
    public enum Level: Int {
        /// Logs everything.
        case trace
        /// Logs info occurred during chat flow and previous ones.
        case info
        /// Logs warnings occurred during chat flow and previous ones.
        case warning
        /// Logs only errors occurred during chat flow.
        case error
    }
    
    /// Configuration of a log verbository.
    public enum Verbosity {
        /// Logs only date and given message.
        case simple
        /// Logs date, function name and given message.
        case medium
        /// Logs date, file with line number, function name and given message.
        case full
    }
    
    
    // MARK: - Properties
    
    static weak var delegate: LogDelegate?
    
    static var verbository: Verbosity = .medium
    static var level: Level = .warning
    static var isEnabled = false
    
    private static var dateTime: String { formatter.string(from: Date()) }
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm:ss.SS dd.MM.yyyy"
        
        return formatter
    }()


    // MARK: - Methods
    
    class func configure(level: Level, verbosity: Verbosity) {
        self.isEnabled = true
        self.level = level
        self.verbository = verbosity
    }
    
    class func error(_ error: Error, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        self.error(error.localizedDescription, fun: fun, file: file, line: line)
    }
    
    class func error(_ message: String, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        guard isEnabled else {
            return
        }
        
        delegate?.logError(log(message, emoji: "❌", fun: fun, file: file, line: line))
    }
    
    class func warning(_ error: Error, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        warning(error.localizedDescription, fun: fun, file: file, line: line)
    }
    
    class func warning(_ message: String, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        guard isEnabled, level.rawValue <= Level.warning.rawValue else {
            return
        }
        
        delegate?.logWarning(log(message, emoji: "⚠️", fun: fun, file: file, line: line))
    }
    
    class func info(_ message: String, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        guard isEnabled, level.rawValue <= Level.info.rawValue else {
            return
        }
        
        delegate?.logInfo(log(message, emoji: "ℹ️", fun: fun, file: file, line: line))
    }
    
    class func trace(_ message: String, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        guard isEnabled, level == .trace else {
            return
        }
        
        delegate?.logTrace(log(message, emoji: "❇️", fun: fun, file: file, line: line))
    }
}


// MARK: - Private methods

private extension LogManager {

    class func log(_ message: String, emoji: String, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) -> String {
        switch verbository {
        case .simple:
            return "\(dateTime) \(emoji): \(message)"
        case .medium:
            return "\(dateTime) \(emoji) \(fun.description.withoutParameters): \(message)"
        case .full:
            return "\(dateTime) [\(file.description.lastPathComponent):\(line)]: \(emoji) \(fun.description.withoutParameters): \(message)"
        }
    }
}


// MARK: - StaticString helpers

private extension String {
    
    var lastPathComponent: String {
        guard let url = URL(string: self) else {
            LogManager.error("lastPathComponent failed: could not init URL from string - \(self)")
            return self
        }
        
        return url.lastPathComponent
    }
    
    var withoutParameters: String {
        guard let substring = substring(from: "(", to: ")"), !substring.isEmpty else {
            return self
        }
        guard let lhs = firstIndex(of: "("), let rhs = firstIndex(of: ")") else {
            return self
        }
        
        let startIndex = index(after: lhs)
        let endIndex = index(before: rhs)
        
        
        let range = startIndex ... endIndex
        var result = self
        
        result.removeSubrange(range)
        return result
    }
}
