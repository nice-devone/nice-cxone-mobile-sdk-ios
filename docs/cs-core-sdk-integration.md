# Core SDK Integration Guide

This guide explains how to integrate the CXone Chat SDK core module directly without using the UI module. Use this approach when you need to build a completely custom UI or when you need lower-level access to the SDK functionality.

## Core SDK vs UI Module

The CXone Mobile SDK consists of two main modules:

- **Core Module**: Provides the fundamental chat functionality, including connection management, messaging, and state handling.
- **UI Module**: Builds on the Core Module to provide a complete, ready-to-use chat interface.

This guide focuses on using the Core Module directly when you need to create your own custom UI.

## Understanding the Architecture

The Core SDK uses a service-based architecture with distinct components:

- `ConnectionProvider`: Manages the connection to CXone services
- `CustomerProvider`: Handles customer identity
- `ChatThreadListProvider`: Manages chat threads, including creation and state
- `ContactCustomFieldsProvider`: Handles contact custom fields for specific threads
- `CustomerCustomFieldsProvider`: Handles customer custom fields across all threads
- `AnalyticsProvider`: Handles analytics and reporting

Each component is accessed through an instance of `CXoneChat` that you construct and hold yourself.

## Detailed Integration Steps

### 1. Construct the Chat Provider

The SDK no longer exposes a global singleton. Create a `CXoneChat` instance once and retain it for the lifetime of the chat session (for example, on your app delegate, scene delegate, or a dedicated chat manager).

```swift
// Construct the chat provider once and hold it
let chatProvider = CXoneChat()
```

All subsequent calls in this guide assume you have a `chatProvider` reference in scope.

### 2. Initialize and Prepare the SDK

```swift
// Initialize and prepare the SDK early in your app lifecycle
try await chatProvider.connection.prepare(
    environment: yourEnvironment, 
    brandId: yourBrandId, 
    channelId: yourChannelId
)
```

#### When to prepare the SDK

For optimal performance:
- Call `prepare()` as early as possible after app launch
- The prepare method has minimal resource impact and sets up the SDK configuration
- Actual connection to services happens later with `connect()`

#### Customer Identity (Optional)

**Customer Identity** contains basic identification (`id`, `firstName`, `lastName`) and must be set **before** `prepare()` if used.

```swift
// OPTIONAL: Set customer identity BEFORE prepare() only if needed
if let userProfile = getCurrentUser() {
    try chatProvider.customer.set(customer: CustomerIdentity(
        id: userProfile.id,
        firstName: userProfile.firstName,
        lastName: userProfile.lastName
    ))
}

// Then prepare the SDK
try await chatProvider.connection.prepare(
    environment: yourEnvironment, 
    brandId: yourBrandId, 
    channelId: yourChannelId
)
```

> **Note**: Setting customer identity is **not necessary at all**. It's only required if you want to present a specific customer name or maintain a consistent customer identity (e.g., for OAuth scenarios or when providing your own specific customer ID). However, using custom customer IDs comes with security risks and should be used at your own discretion. If not set, the SDK will generate an anonymous customer ID automatically.

### 3. Observe Chat Events

The SDK exposes events through an `AsyncStream<ChatEvent>` returned by `chatProvider.events()`. Start a long-lived `Task` that iterates the stream and switches on the cases your app cares about.

The `ChatEvent` enum covers every event the SDK emits:

- `chatUpdated(state:mode:)` — chat state or mode changed
- `threadUpdated(_:)` — a single thread changed (messages, agent, name, etc.)
- `threadsUpdated(_:)` — the full list of threads changed
- `unexpectedDisconnect` — the connection dropped unexpectedly
- `customEventMessage(_:)` — a custom plugin message arrived
- `agentTyping(isTyping:agent:threadId:)` — agent started or stopped typing
- `contactCustomFieldsSet` — custom fields for the current contact were set
- `customerCustomFieldsSet` — custom fields for the customer were set
- `error(_:)` — an SDK error occurred
- `proactiveActionReceived(_:)` — a proactive action (e.g. inactivity popup) was received

```swift
// Subscribe to SDK events. Retain the Task if you need to cancel it later.
Task { [chatProvider] in
    for await event in chatProvider.events() {
        switch event {
        case .chatUpdated(let chatState, _):
            guard chatState >= .ready else {
                continue
            }
            // Handle chat ready state
        case .threadUpdated(let chatThread):
            // Handle thread updates - messages, agent changes, etc.
            _ = chatThread
        case .agentTyping(let isTyping, let agent, let threadId):
            // Handle typing indicators
            _ = (isTyping, agent, threadId)
        case .unexpectedDisconnect:
            do {
                try await chatProvider.connection.connect()
            } catch {
                // Handle connection error
            }
        case .error(let error):
            // Handle SDK errors
            _ = error
        default:
            break
        }
    }
}
```

> **Note**: This is a flow for basic single-threaded channel configuration. For detailed descriptions and specific scenarios (multi-thread, live chat, message handling, typing indicators, etc.), visit **Case Studies** and search for your desired scenario.

## Connection Lifecycle Best Practices

For optimal performance and resource usage:

1. **Early Preparation**:
   ```swift
   // In AppDelegate or initialization sequence
   let chatProvider = CXoneChat()

   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       Task { [chatProvider] in
           try? await chatProvider.connection.prepare(environment: env, brandId: brandId, channelId: channelId)
       }
       return true
   }
   ```

2. **Connect When Needed**:
   ```swift
   // When user navigates to chat interface
   func chatButtonTapped() {
       Task { [chatProvider] in
           try await chatProvider.connection.connect()
           // Show chat UI
       }
   }
   ```

3. **Disconnect When Inactive**:
   ```swift
   // When user leaves chat or closes chat interface
   func onDisconnectTapped() {
       chatProvider.connection.disconnect()
   }
   ```

4. **Clean Sign Out**:
   ```swift
   // When user logs out
   func onUserLogout() {
       chatProvider.signOut()
   }
   ```

> **Note**: For detailed implementation examples and specific use cases, refer to the **Case Studies** documentation and the sample application in the SDK repository.