# Case Study: Logging

In any robust software system, effective logging and error management is critical for smooth operations and troubleshooting. The CXoneChatSDK introduces a customizable LogManager to provide centralized logging capabilities, helping developers manage errors, warnings, and informational messages during chat operations. This case study illustrates how the LogManager was integrated and configured to streamline error handling, improve monitoring, and enhance debugging in an iOS chat application.


## Problem Statement

During the development of the CXoneChatSDK-based chat module, developers faced several challenges:

1. Inconsistent Error Reporting: Critical errors were not logged systematically.
2. High Debugging Time: Lack of proper logs made it difficult to trace issues across chat sessions.
3. Information Overload: Raw, unfiltered logs increased noise in the development environment, making it hard to distinguish critical issues from minor events.

The solution needed to provide:

- Flexible log filtering by severity.
- Configurable verbosity for different stages of development.
- Seamless integration with the host application’s logging system.

### Solution

The LogManager from the CXoneChatSDK was implemented to address these challenges. It introduces logging levels, verbosity settings, and a protocol-based approach to forward logs to the host application. The key features include:

1. Log Levels:
  - trace: Logs everything (for in-depth debugging).
  - info: Logs general chat flow events.
  - warning: Logs non-critical issues.
  - error: Logs only critical errors.

2. Verbosity Options:
  - simple: Logs only the timestamp and message.
  - medium: Adds function name to the log entry.
  - full: Logs file name, line number, and function name, useful for detailed analysis.
  
3. Delegate-Based Log Handling:
Log messages are forwarded to the host application using the LogDelegate protocol, allowing custom processing of logs on the application side.


## Implementation

1. Configuring the LogManager

The LogManager was configured based on the environment (development or production) to control the level and verbosity of logs:

```swift
LogManager.configure(level: .warning, verbosity: .medium)
```

This setup ensures that only warnings and errors are logged in production, reducing noise, while detailed logs (e.g., trace) are available during development.

2. Forwarding Logs to the Host Application

The host application conforms to the LogDelegate protocol to handle logs:

```swift
class ChatLogger: LogDelegate {

    func logError(_ message: String) {
        print("❌ ERROR: \(message)")
    }
    
    func logWarning(_ message: String) {
        print("⚠️ WARNING: \(message)")
    }

    func logInfo(_ message: String) {
        print("ℹ️ INFO: \(message)")
    }

    func logTrace(_ message: String) {
        print("❇️ TRACE: \(message)")
    }
}

// Set the logger as the delegate
LogManager.delegate = ChatLogger()
```

3. Logging Messages During Chat Operations

Here are examples of how various log levels were used during different chat events:

- Error Logging (Network Failure):

```swift
LogManager.error("Failed to connect to chat server.")
```

- Warning Logging (Retry Mechanism):

```swift
LogManager.warning("Retrying connection...")
```

- Info Logging (User Joined Chat):

```swift
LogManager.info("User successfully joined the chat.")
```

- Trace Logging (Detailed Debugging):

```swift
LogManager.trace("Chat message sent: \(message)")
```
