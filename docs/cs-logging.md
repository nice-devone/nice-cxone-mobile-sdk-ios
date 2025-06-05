# Case Study: Logging

The CXone Mobile SDK provides a flexible and powerful logging system built on the `CXoneGuideUtility` library. This case study illustrates how to implement effective logging in your application using the SDK's built-in logging capabilities, demonstrating configuration, customization, and integration strategies.

## Overview

Effective logging is essential for troubleshooting issues, monitoring application behavior, and providing a clear audit trail of events. The CXone Mobile SDK's logging system allows developers to:

1. Configure log levels to control verbosity
2. Direct logs to multiple destinations (console, file, crash reporting services)
3. Format log messages with different levels of detail
4. Filter logs by category or level
5. Integrate with existing application logging systems

## The Logging Architecture

The CXone Mobile SDK uses a modular logging architecture based on these key components:

### LogWriter Protocol

The `LogWriter` protocol is the foundation of the logging system, providing methods to write log records:

```swift
public protocol LogWriter {
    func log(record: LogRecord)
}
```

The SDK includes several implementations:

- `PrintLogWriter`: Outputs logs to the console
- `FileLogWriter`: Writes logs to a file
- `SystemLogWriter`: Sends logs to the system's os.Logger
- `ForkLogWriter`: Distributes logs to multiple LogWriters

### LogLevel

The `LogLevel` enum defines the severity of log messages, in ascending order of importance:

```swift
public enum LogLevel: String, Sendable, CaseIterable, Equatable {
    case trace   // Most detailed level for tracing execution flow
    case debug   // Debugging information
    case info    // General informational messages
    case warning // Potential issues
    case error   // Error conditions
    case fatal   // Critical unrecoverable errors
}
```

### LogRecord

A `LogRecord` encapsulates all information about a log entry, including:

- The message text
- Log level
- Category (optional)
- Source file, line number, and timestamp
- Formatted message (after applying LogFormatter)

### StaticLogger Protocol

The `StaticLogger` protocol provides convenient static methods for logging:

```swift
public protocol StaticLogger {
    static var instance: LogWriter? { get }
    static var category: String? { get }
}
```

Implementations include:
- `LogManager` in the CXone SDK (category: "CORE")
- `LogManager` in the CXone UI library (category: "UI")

## Implementing Logging in Your Application

### 1. Configure the SDK's LogWriter

The SDK's logging system can be configured by setting the `CXoneChat.logWriter` property:

```swift
// Use a simple console logger
CXoneChat.logWriter = PrintLogWriter()

// Or configure a more complex setup with filtering and multiple destinations
CXoneChat.logWriter = ForkLogWriter(
    PrintLogWriter().format(.simple),
    FileLogWriter(path: logFileURL).format(.full)
).filter(minLevel: .warning)
```

### 2. Create Your Own Logger Implementation

You can create your own implementation of the `StaticLogger` protocol:

```swift
class Log: StaticLogger {
    nonisolated(unsafe) public static var instance: LogWriter? = PrintLogWriter()
    public static let category: String? = "Application"
    
    // Additional utility methods as needed
}
```

### 3. Configure Multiple Log Destinations

The sample application demonstrates how to configure multiple log destinations:

```swift
class func configure(
    format: LogFormatter = .full,
    isPrintEnabled: Bool = true,
    isWriteToFileEnabled: Bool = false,
    isCrashlyticsEnabled: Bool = false,
    isSystemEnabled: Bool = false
) {
    var loggers = [any LogWriter]()

    if isPrintEnabled {
        loggers.append(PrintLogWriter())
    }
    
    if isWriteToFileEnabled, let url = getCurrentLogUrl() {
        loggers.append(FileLogWriter(path: url))
    }

    if isCrashlyticsEnabled {
        loggers.append(CrashlyticsLogWriter())
    }

    if isSystemEnabled {
        loggers.append(SystemLogWriter(logger: Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: "Application"
        )))
    }

    let instance = loggers.isEmpty ? nil : ForkLogWriter(loggers: loggers).format(format)

    Self.instance = instance
    CXoneChat.logWriter = instance
    CXoneChatUI.LogManager.instance = instance
}
```

### 4. Log Message Formatting

The SDK supports three formatting styles through the `LogFormatter` class:

- `.simple`: Level, category, and message only
- `.medium`: Adds timestamp
- `.full`: Adds file name and line number

```swift
// Format logs with full details
let logger = PrintLogWriter().format(.full)
```

### 5. Using the Logger

Once configured, you can log messages at various levels:

```swift
// Basic logging
Log.trace("Starting connection process")
Log.info("User successfully connected")
Log.warning("Response timeout, retrying")
Log.error("Connection failed: \(error.localizedDescription)")

// Error extension utility
error.logError("Connection attempt")

// Scope tracking with automatic entry/exit logging
Log.scope {
    // Code to be executed with automatic entry/exit logging
    performComplexOperation()
}

// Timing block execution
Log.time {
    // Code to be executed with timing
    performExpensiveOperation()
}
```

## Advanced Usage Examples

### Filtering Logs by Category

```swift
// Only log messages with specific categories
let logger = PrintLogWriter().filter { record in
    record.category == "Network" || record.category == "Authentication"
}

// Only log messages at warning level or higher
let logger = PrintLogWriter().filter(minLevel: .warning)

// Filter by specific categories
let logger = PrintLogWriter().filter(categories: "Network", "Authentication")
```

### Writing Logs to a File for Debugging

```swift
// Define a log file URL
let logDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let logFileURL = logDirectory.appendingPathComponent("app.log")

// Configure a file writer
let fileWriter = FileLogWriter(path: logFileURL).format(.full)

// Set as the SDK's logger
CXoneChat.logWriter = fileWriter
```

### Creating a Log Share Feature

```swift
func shareLogFiles() throws -> UIActivityViewController {
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let logsUrl = documentDirectory.appendingPathComponent("Logs")
    let filePaths = try FileManager.default.contentsOfDirectory(at: logsUrl, includingPropertiesForKeys: nil)
    
    return UIActivityViewController(activityItems: filePaths, applicationActivities: nil)
}
```

## Best Practices

1. **Appropriate Log Levels**: Use the appropriate log level for each message:
   - `trace` for detailed flow information
   - `debug` for development-time diagnostics
   - `info` for notable but normal events
   - `warning` for non-critical issues
   - `error` for failures requiring attention
   - `fatal` for catastrophic failures

2. **Performance Considerations**: 
   - In production builds, filter logs to reduce overhead
   - File writing is done using `Task { @MainActor in }` to ensure thread safety
   - Be cautious with logging sensitive information
   - For expensive computations, use conditional compilation:
     ```swift
     #if DEBUG
     Log.trace("Complex data: \(expensiveComputation())")
     #endif
     ```

3. **Log Rotation**:
   - Implement log rotation to prevent excessive disk usage
   - Delete old logs periodically

4. **Context-Rich Messages**:
   - Include relevant context in log messages
   - For errors, include the operation being performed and relevant IDs

## Conclusion

The CXone Mobile SDK's logging system provides a flexible foundation for comprehensive application logging. By leveraging its modular architecture, you can create a tailored logging solution that addresses your specific debugging, monitoring, and diagnostic needs across development and production environments.
