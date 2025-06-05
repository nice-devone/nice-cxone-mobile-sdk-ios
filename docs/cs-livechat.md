# Case Study: Live Chat

> **Quick Start**: To add live chat to your app using the UI module, call `prepare()` after user authentication, then use `ChatCoordinator.start()` for UIKit or `ChatCoordinator.content()` for SwiftUI when the user wants to chat. The UI module handles everything else automatically.

## What is Live Chat?

The Mobile SDK supports asynchronous (single-thread, multi-thread) and live chat channel configurations. In live chat mode:

- Chat availability depends on agent availability (like business hours)
- When no agents are available, the SDK enters an `.offline` state
- Analytics events still work in offline state (they don't require a web socket)
- The SDK automatically loads or creates threads when no pre-chat form is required
- If a pre-chat form is configured, the integrator must handle it and trigger thread creation manually
- Some features (like thread name updates) are not available

## UI Module Integration (Recommended)

The UI module provides a complete, ready-to-use chat interface with all functionality built-in. This is the recommended approach for most integrators.

### Step 1: Prepare the SDK

Call this method after user authentication:

```swift
// Call early in your app lifecycle (e.g., after login)
try await CXoneChat.shared.connection.prepare(
    environment: yourEnvironment, 
    brandId: yourBrandId, 
    channelId: yourChannelId
)

// Set user identity if available
try CXoneChat.shared.customer.set(
    customer: CustomerIdentity(
        id: userProfile.id,
        firstName: userProfile.firstName,
        lastName: userProfile.lastName
    )
)
```

### Step 2: Show the Chat UI

The UI module supports both UIKit and SwiftUI integration. Choose the approach that matches your app:

#### UIKit Integration

```swift
// Create a coordinator (can be stored as a property)
let chatCoordinator = ChatCoordinator()

// UIKit integration - present the chat UI from a view controller
func showChatUI() {
    chatCoordinator.start(
        threadId: nil,  // For a new conversation
        in: navigationController,       // Your UINavigationController
        presentModally: true, 
        onFinish: {
            // Handle chat completion
        }
    )
}
```

#### SwiftUI Integration

```swift
// In your SwiftUI view
struct ContentView: View {
    // Create a coordinator
    let chatCoordinator = ChatCoordinator()
    
    // State to control sheet presentation
    @State private var showingChat = false
    
    var body: some View {
        Button("Start Chat") {
            showingChat = true
        }
        .sheet(isPresented: $showingChat) {
            // Get chat content view from coordinator
            chatCoordinator.content(
                threadId: nil,
                presentModally: true,
                onFinish: {
                    showingChat = false
                }
            )
        }
    }
}
```

**That's it!** The UI module automatically handles live chat specifics including agent availability checks and offline state management.

### User Session Management

When users log in or out of your app, you need to manage the SDK state:

```swift
// When user logs out:
CXoneChat.signOut()

// When a different user logs in:
// Update customer identity before prepare() - no need to sign out
try CXoneChat.shared.customer.set(customer: CustomerIdentity(
    id: newUserProfile.id,
    firstName: newUserProfile.firstName,
    lastName: newUserProfile.lastName
))
try await CXoneChat.shared.connection.prepare(
    environment: yourEnvironment,
    brandId: yourBrandId,
    channelId: yourChannelId
)
```

> **Note**: `signOut()` is intended for changing environments and should not be used in production. For switching between users, simply update the customer identity before calling `prepare()`.

## Sample Implementation

For a complete implementation reference, see:

- [Sample Application](https://github.com/nice-devone/nice-cxone-mobile-sample-ios)
- [UI Module](https://github.com/nice-devone/nice-cxone-mobile-ui-ios)

## Need a Custom UI?

If you need to build your own custom UI without using the UI module, please check our [Core SDK Integration Guide](core-sdk-integration.md) for details on implementing the delegate methods, connecting manually, and handling all states yourself.
