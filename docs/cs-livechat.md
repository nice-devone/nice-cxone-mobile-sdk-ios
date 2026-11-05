# Case Study: Live Chat

> **Quick Start**: To add live chat to your app using the UI module, set the customer identity and call `prepare()` after user authentication, then use `ChatCoordinator.content(threadId:presentModally:onFinish:)` when the user wants to chat — embed the returned view in SwiftUI, or host it in a `UIHostingController` for UIKit. The UI module handles everything else automatically.

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

Call these methods after user authentication. The customer identity can only be set while the SDK is in the `.initial` state, so set it **before** `prepare()` — calling `customer.set(customer:)` afterwards throws `CXoneChatError.illegalChatState`:

```swift
// Set user identity if available — must happen before prepare()
try chatProvider.customer.set(
    customer: CustomerIdentity(
        id: userProfile.id,
        firstName: userProfile.firstName,
        lastName: userProfile.lastName
    )
)

// Call early in your app lifecycle (e.g., after login)
try await chatProvider.connection.prepare(
    environment: yourEnvironment, 
    brandId: yourBrandId, 
    channelId: yourChannelId
)
```

### Step 2: Show the Chat UI

The UI module supports both UIKit and SwiftUI integration. Choose the approach that matches your app:

#### UIKit Integration

```swift
// Create a coordinator (can be stored as a property)
let chatCoordinator = ChatCoordinator(chatProvider: chatProvider)

// UIKit integration - host the chat UI in a UIHostingController from a view controller
func showChatUI() {
    let content = chatCoordinator.content(
        threadId: nil,  // For a new conversation
        presentModally: true,
        onFinish: { [weak self] in
            // Handle chat completion
            self?.dismiss(animated: true)
        }
    )

    present(UIHostingController(rootView: content), animated: true)
}
```

#### SwiftUI Integration

```swift
// In your SwiftUI view
struct ContentView: View {
    // Create a coordinator (or receive one created with your `chatProvider`)
    let chatCoordinator: ChatCoordinator
    
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
chatProvider.signOut()

// When a different user logs in:
// signOut() returns the SDK to `.initial`, so the new identity can be set before prepare()
try chatProvider.customer.set(customer: CustomerIdentity(
    id: newUserProfile.id,
    firstName: newUserProfile.firstName,
    lastName: newUserProfile.lastName
))
try await chatProvider.connection.prepare(
    environment: yourEnvironment,
    brandId: yourBrandId,
    channelId: yourChannelId
)
```

> **Note**: `signOut()` disconnects, purges the SDK's persisted data and in-memory session state, and returns `state` to `.initial` — the device token and any listener registered with `setTokenDelegateListener(_:)` are kept. The instance stays reusable: set the next customer's identity and call `prepare()` again. The customer identity cannot be changed on an already prepared session, so sign out before switching users.

## Queue Position and Contact Handler

On a live chat channel, a `ChatThread` reports where the customer stands while waiting for an agent:

- `positionInQueue` — the position in the queue. It is `nil` once an agent is assigned or the thread is closed, including when a thread is recovered with an agent already assigned.
- `contactHandler` — the party currently handling the contact: `.cxone` (CXone routing — the contact is queued for, or assigned to, a human agent), `.cognigy` (an automated bot), or `.unknown` (a handler this SDK version does not recognize). It is `nil` on channels where the platform reports no handler.

While `contactHandler` is anything other than `.cxone`, the customer is not queued, so ignore `positionInQueue` until the contact is handed over to CXone routing. Treat both `.cognigy` and `.unknown` as "not handled by CXone":

```swift
case .threadUpdated(let thread):
    if thread.contactHandler == nil || thread.contactHandler == .cxone, let position = thread.positionInQueue {
        showQueuePosition(position)
    } else {
        hideQueuePosition()
    }
```

The UI module already applies this rule: its position-in-queue view is not shown while a bot handles the conversation.

## Sample Implementation

For a complete implementation reference, see:

- [Sample Application](https://github.com/nice-devone/nice-cxone-mobile-sample-ios)
- [UI Module](https://github.com/nice-devone/nice-cxone-mobile-ui-ios)

## Need a Custom UI?

If you need to build your own custom UI without using the UI module, please check our [Core SDK Integration Guide](cs-core-sdk-integration.md) for details on observing `ChatProvider.events()`, connecting manually, and handling all states yourself.
