# Case Study: Single Thread Chat

## Overview

The CXone Mobile SDK supports single-thread chat configurations, where a customer interacts with agents through a single conversation thread. This case study demonstrates how to implement and manage a single-thread chat experience.

> **Note:** This guide focuses on implementations using only the core SDK module without the UI module. Developers using the pre-built UI components will have many of these steps handled automatically by the UI layer.

## Key Concepts

In single-thread configurations:
- Only one conversation thread is used for all interactions
- Thread management features (renaming, archiving) may be limited
- The SDK automatically handles many tasks, including thread loading after connection

## Implementation Steps

### 1. Initialize the SDK

Start by preparing the SDK with your environment configuration:

```swift
try await CXoneChat.shared.connection.prepare(
    environment: env,
    brandId: configuration.brandId,
    channelId: configuration.channelId
)
```

### 2. Connect to CXone Services

Establish a connection to CXone services:

```swift
try await CXoneChat.shared.connection.connect()
```

### 3. Set Up Delegates

Register as a delegate to receive SDK updates:

```swift
CXoneChat.shared.add(delegate: self)
```

### 4. Implement Delegate Methods

```swift
// Track chat state changes
func onChatUpdated(_ state: ChatState, mode: ChatMode) {
    switch state {
    case .connecting:
        // Show loading indicator
    case .connected:
        // Connection established
    case .ready:
        // Chat is ready for interaction
    default:
        break
    }
}

// Handle thread updates
func onThreadUpdated(_ chatThread: ChatThread) {
    // Update UI with thread data
}
```

### 5. Handle Pre-Chat Survey (If Configured)

If your channel has a pre-chat survey configured, implement the form handling:

```swift
func submitPreChat(with fields: [String: String]) {
    Task {
        do {
            // Create thread with pre-chat survey fields
            let threadProvider = try await CXoneChat.shared.threads.create(with: fields)
            // Continue with the created thread
        } catch {
            // Handle error
        }
    }
}
```

## Handling Thread States

The SDK automatically manages thread states:
- If a thread exists, it will be loaded automatically
- If no thread exists and no pre-chat is required, a thread is created automatically
- If pre-chat is required, the SDK will enter the `.ready` state, indicating that pre-chat needs to be submitted

## Best Practices

1. **Error Handling**: Always implement proper error handling for SDK operations
2. **Loading States**: Show appropriate loading indicators during connection and thread creation
3. **Logging**: Configure the SDK logger to track issues and state changes

```swift
CXoneChat.shared.configureLogger(level: .warning, verbosity: .verbose)
```

## Sample Code

For a complete implementation example, refer to the [Sample application](https://github.com/nice-devone/nice-cxone-mobile-sample-ios) and the [UI Module](https://github.com/nice-devone/nice-cxone-mobile-ui-ios).

## Related Resources

- [Core SDK Integration](core-sdk-integration.md)
- [Custom Fields](cs-custom-fields.md)
- [Logging](cs-logging.md)

## Core SDK vs UI Module

This guide details the implementation using only the core SDK module, which requires manual handling of connections, state management, and UI rendering. If you're using the CXone UI module, many of these low-level implementation details are handled automatically by the pre-built components.

When using the UI module:
- Connection management is handled internally
- Thread creation and loading is automated
- State changes are managed by the UI components
- Pre-chat forms are rendered with built-in UI

For UI module integration, refer to the [Core SDK Integration](core-sdk-integration.md) guide which demonstrates using the ChatCoordinator to leverage the pre-built UI components.
