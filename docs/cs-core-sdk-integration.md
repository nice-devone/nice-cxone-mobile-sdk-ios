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

Each component is accessed through the singleton `CXoneChat.shared`.

## Detailed Integration Steps

### 1. Initialize and Prepare the SDK

```swift
// Initialize and prepare the SDK early in your app lifecycle
try await CXoneChat.shared.connection.prepare(
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
    try CXoneChat.shared.customer.set(customer: CustomerIdentity(
        id: userProfile.id,
        firstName: userProfile.firstName,
        lastName: userProfile.lastName
    ))
}

// Then prepare the SDK
try await CXoneChat.shared.connection.prepare(
    environment: yourEnvironment, 
    brandId: yourBrandId, 
    channelId: yourChannelId
)
```

> **Note**: Setting customer identity is **not necessary at all**. It's only required if you want to present a specific customer name or maintain a consistent customer identity (e.g., for OAuth scenarios or when providing your own specific customer ID). However, using custom customer IDs comes with security risks and should be used at your own discretion. If not set, the SDK will generate an anonymous customer ID automatically.

### 2. Implement Chat Delegate

The sample app demonstrates basic delegate implementation:

```swift
// From the sample app - basic delegate setup
extension Manager: CXoneChatDelegate {
    
    func onChatUpdated(_ chatState: ChatState, mode: ChatMode) {
        guard chatState >= .ready else {
            return
        }
        // Handle chat ready state
    }
    
    func onThreadUpdated(_ chatThread: ChatThread) {
        // Handle thread updates - messages, agent changes, etc.
    }
    
    func onUnexpectedDisconnect() {
        Task { @MainActor in
            do {
                try await connect()
            } catch {
                // Handle connection error
            }
        }
    }
    
    func onError(_ error: Error) {
        // Handle SDK errors
    }
}
```

> **Note**: This is a flow for basic single-threaded channel configuration. For detailed descriptions and specific scenarios (multi-thread, live chat, message handling, typing indicators, etc.), visit **Case Studies** and search for your desired scenario.

## Connection Lifecycle Best Practices

For optimal performance and resource usage:

1. **Early Preparation**:
   ```swift
   // In AppDelegate or initialization sequence
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       Task {
           try? await CXoneChat.shared.connection.prepare(environment: env, brandId: brandId, channelId: channelId)
       }
       return true
   }
   ```

2. **Connect When Needed**:
   ```swift
   // When user navigates to chat interface
   func chatButtonTapped() {
       Task {
           try await CXoneChat.shared.connection.connect()
           // Show chat UI
       }
   }
   ```

3. **Disconnect When Inactive**:
   ```swift
   // When user leaves chat or closes chat interface
   func onDisconnectTapped() {
       CXoneChat.shared.connection.disconnect()
   }
   ```

4. **Clean Sign Out**:
   ```swift
   // When user logs out
   func onUserLogout() {
       CXoneChat.signOut()
   }
   ```

> **Note**: For detailed implementation examples and specific use cases, refer to the **Case Studies** documentation and the sample application in the SDK repository.
