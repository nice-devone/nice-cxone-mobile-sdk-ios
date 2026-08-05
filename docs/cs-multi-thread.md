# Case Study: Multi Thread Chat

## Overview

The CXone Mobile SDK supports multi-thread chat configurations, where customers can create and manage multiple conversation threads simultaneously. This case study demonstrates how to implement a multi-thread chat experience using the core SDK module.

> **Note:** This guide focuses on implementations using only the core SDK module without the UI module. Developers using the pre-built UI components will have many of these steps handled automatically by the UI layer.

## Key Concepts

In multi-thread configurations:
- Multiple conversation threads can exist simultaneously 
- Users can create new threads for different topics
- All thread management features are fully available
- Thread list management is required

## Implementation Steps

### 1. Initialize the SDK

Construct a `CXoneChat` instance and hold a reference to it for the lifetime of your chat integration (the previous `CXoneChat.shared` singleton has been removed):

```swift
let chatProvider = CXoneChat()
```

Then prepare the SDK with your environment configuration:

```swift
try await chatProvider.connection.prepare(
    environment: env,
    brandId: configuration.brandId,
    channelId: configuration.channelId
)
```

### 2. Connect to CXone Services

Establish a connection to CXone services:

```swift
try await chatProvider.connection.connect()
```

### 3. Subscribe to SDK Events

The previous `CXoneChatDelegate` protocol has been removed. Instead, observe SDK events through the `events()` async stream:

```swift
Task { [chatProvider] in
    for await event in chatProvider.events() {
        switch event {
        case .chatUpdated(let state, let mode):
            // Track chat state / mode changes
            if state == .ready {
                // Chat is ready - show thread list or empty state
            }
        case .threadsUpdated(let chatThreads):
            // Update UI with the latest threads
            updateThreadList(chatThreads)
        case .threadUpdated(let chatThread):
            // Update UI with the latest thread data
            updateThreadView(chatThread)
        default:
            break
        }
    }
}
```

### 4. Creating New Threads

Implement thread creation functionality:

```swift
func createNewThread(with customFields: [String: String]? = nil) {
    Task {
        do {
            if let customFields {
                // Create thread with pre-chat survey fields
                let threadProvider = try await chatProvider.threads.create(with: customFields)
                // Handle the newly created thread
            } else {
                // Create thread without pre-chat
                let threadProvider = try await chatProvider.threads.create()
                // Handle the newly created thread
            }
        } catch {
            // Handle error
        }
    }
}
```

### 5. Thread Selection and Loading

When a user selects a thread from the list, load its full content:

```swift
func onThreadSelected(_ thread: ChatThread) {
    Task {
        do {
            // Navigate to thread view and display messages
            showThreadView(thread)
        } catch {
            // Handle error
        }
    }
}
```

### 6. Thread View Implementation

In the thread view, react to `threadUpdated` events from the events stream (shown in step 3) to keep the UI in sync with the latest thread data.

## Handling App State Changes

For optimal performance in multi-thread configurations:

```swift
// When app enters foreground
func applicationWillEnterForeground() {
    Task {
        try await chatProvider.connection.connect()
    }
}

// When app enters background
func applicationDidEnterBackground() {
    chatProvider.connection.disconnect()
}
```

## Best Practices

1. **Thread List Management**: Keep the thread list up-to-date by handling `.threadsUpdated` events from `chatProvider.events()`
2. **Thread Creation**: Check for pre-chat requirements before creating new threads
3. **Thread Selection**: Load thread details when a user selects a thread from the list
4. **Connection Management**: Connect only when needed and disconnect when the app is in the background
5. **Logging**: Configure the SDK logger to track issues and state changes by assigning a `LogWriter` to the static `CXoneChat.logWriter` property

```swift
CXoneChat.logWriter = PrintLogWriter().filter(minLevel: .warning)
```

## Sample Code

For a complete implementation example, refer to the [Sample application](https://github.com/nice-devone/nice-cxone-mobile-sample-ios) and the [UI Module](https://github.com/nice-devone/nice-cxone-mobile-ui-ios).

## Related Resources

- [Core SDK Integration](cs-core-sdk-integration.md)
- [Custom Fields](cs-custom-fields.md)
- [Logging](cs-logging.md)

## Core SDK vs UI Module

This guide details the implementation using only the core SDK module, which requires manual handling of connections, state management, and UI rendering. If you're using the CXone UI module, many of these low-level implementation details are handled automatically by the pre-built components.

When using the UI module:
- Thread list UI is provided out-of-the-box
- Thread creation and selection is handled automatically
- Connection management is handled internally
- State changes are managed by the UI components

For UI module integration, refer to the [Core SDK Integration](cs-core-sdk-integration.md) guide which demonstrates using the ChatCoordinator to leverage the pre-built UI components.
