# Migration Guide: From Singleton to Instance

This guide walks existing integrators through migrating from the previous
singleton-based `CXoneChat.shared` API to the instance-based API.

## What changed at a glance

- **`CXoneChat.shared` is gone.** Construct a `CXoneChat` instance yourself with
  `let chatProvider = CXoneChat()` and hold the reference for the lifetime of the
  chat experience.
- **`CXoneChat.signOut()` (static) is gone.** Sign-out is now an instance method:
  `chatProvider.signOut()`.
- **`CXoneChatDelegate` is gone.** Subscribe to SDK events through
  `func events() -> AsyncStream<ChatEvent>` on `ChatProvider`.
- **`CXoneChat` is now `@MainActor`-isolated.** Calls from non-main contexts
  must hop to the main actor.

## Migration in three steps

### Step 1 — Construct a single instance and hold it

The instance must live for the duration of the chat session. Pick the container
that matches your app architecture:

#### SwiftUI

```swift
@main
struct MyApp: App {

    @State private var chatProvider = CXoneChat()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.chatProvider, chatProvider)
        }
    }
}
```

`CXoneChat` is a `@MainActor`-isolated class, so `@State` for a reference type
is the simplest holder at the app entry point. If your app needs to react to
SDK state changes in SwiftUI, wrap `CXoneChat` in your own `ObservableObject`
that exposes a `@Published var state: ChatState` mirror updated from an
`events()` loop — see `sample/iOSSDKExample/Sources/ChatPresenter.swift` for an
example.

#### UIKit

```swift
@MainActor
final class AppDelegate: UIResponder, UIApplicationDelegate {

    let chatProvider = CXoneChat()

    // ...
}
```

View controllers reach the instance through the delegate:

```swift
let chatProvider = (UIApplication.shared.delegate as! AppDelegate).chatProvider
```

A dependency-injection container or service locator is also fine — the SDK is
indifferent. The only rule is: **one instance, held alive for the duration of
the chat experience**.

### Step 2 — Replace every `CXoneChat.shared.X` with `chatProvider.X`

This is a mechanical sweep. Examples:

| Old | New |
|---|---|
| `CXoneChat.shared.connection.connect()` | `chatProvider.connection.connect()` |
| `CXoneChat.shared.threads.create()` | `chatProvider.threads.create()` |
| `CXoneChat.shared.customer.set(customer:)` | `chatProvider.customer.set(customer:)` |
| `CXoneChat.shared.analytics.viewPage(title:url:)` | `chatProvider.analytics.viewPage(title:url:)` |
| `CXoneChat.shared.state.isChatAvailable` | `chatProvider.state.isChatAvailable` |
| `CXoneChat.signOut()` | `chatProvider.signOut()` |

`CXoneChat.logWriter` stays a static — it is the only remaining static surface
(it sets the writer for the SDK's internal log, which is process-wide).

### Step 3 — Replace `CXoneChatDelegate` with an `events()` loop

Old pattern:

```swift
CXoneChat.shared.add(delegate: self)

extension Manager: CXoneChatDelegate {
    func onChatUpdated(_ state: ChatState, mode: ChatMode) { /* ... */ }
    func onThreadUpdated(_ thread: ChatThread) { /* ... */ }
    func onAgentTyping(_ isTyping: Bool, agent: Agent, threadId: String) { /* ... */ }
    func onError(_ error: Error) { /* ... */ }
}
```

New pattern:

```swift
let observation = Task { [chatProvider] in
    for await event in chatProvider.events() {
        switch event {
        case .chatUpdated(let state, let mode):
            // handle
        case .threadUpdated(let thread):
            // handle
        case .agentTyping(let isTyping, let agent, let threadId):
            // handle
        case .error(let error):
            // handle
        default:
            break
        }
    }
}

// Later, when the consumer leaves scope:
observation.cancel()
```

#### Delegate method → ChatEvent case mapping

| Old `CXoneChatDelegate` method | New `ChatEvent` case |
|---|---|
| `onChatUpdated(_:mode:)` | `.chatUpdated(state:mode:)` |
| `onThreadUpdated(_:)` | `.threadUpdated(_:)` |
| `onThreadsUpdated(_:)` | `.threadsUpdated(_:)` |
| `onUnexpectedDisconnect()` | `.unexpectedDisconnect` |
| `onCustomEventMessage(_:)` | `.customEventMessage(_:)` |
| `onAgentTyping(_:agent:threadId:)` | `.agentTyping(isTyping:agent:threadId:)` |
| `onContactCustomFieldsSet()` | `.contactCustomFieldsSet` |
| `onCustomerCustomFieldsSet()` | `.customerCustomFieldsSet` |
| `onError(_:)` | `.error(_:)` |
| `onTokenRefreshFailed()` | *(removed)* — the SDK refreshes implicit-flow tokens via `CustomerProvider.setTokenDelegateListener(_:)`; an unrecoverable token surfaces as `CXoneChatError.invalidAccessToken` from the failing call |
| `onProactivePopupAction(...)` | `.proactiveActionReceived(_:)` |

## Runtime semantics

### What `chatProvider.signOut()` does

Calling `signOut()`:

1. **Disconnects the WebSocket** cleanly (not as an unexpected disconnect — no
   `.unexpectedDisconnect` event is emitted).
2. **Purges persistent state**: the keychain entries and UserDefaults entries
   scoped to the SDK are erased.
3. **Finishes all in-flight `events()` streams** — every subscribed
   `for await … in chatProvider.events()` loop exits cleanly.

The `CXoneChat` instance itself is still alive and reusable after `signOut()`.
You can call `prepare(...)` and `connect()` again to start a fresh session with
new credentials. If you want a hard reset, discard the instance and construct a
new `CXoneChat()` — both approaches are supported.

### Running multiple instances

The SDK does not enforce a single instance per app, but **two instances will
conflict on persistent state**. Both share the same UserDefaults suite
(`"CXoneChatSDK"`) and the same keychain entries. Each instance opens its own
WebSocket connection, so simultaneous connections are independent in flight,
but the visitor/auth state written by one connection will be overwritten by the
other.

**Recommended pattern: one instance per app**, constructed at launch and held
for the app's lifetime.

### `@MainActor` isolation

`CXoneChat` and every provider it exposes (`connection`, `customer`, `threads`,
`analytics`, `customerCustomFields`, `proactiveAction`) are `@MainActor`-isolated.

You do not need extra ceremony when calling from:

- SwiftUI view bodies
- `@MainActor`-annotated view models
- UIKit lifecycle methods (`viewDidLoad`, `viewWillAppear`, IBActions, etc.)

You **do** need to hop to the main actor when calling from:

- Background `Task`s
- `URLSession` delegate callbacks
- `UNUserNotificationCenterDelegate` callbacks (push notifications)
- `UIApplicationDelegate` push-token callbacks
  (`application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`)

Use either:

```swift
Task { @MainActor in
    chatProvider.customer.setDeviceToken(deviceToken)
}
```

or:

```swift
await MainActor.run {
    chatProvider.customer.setDeviceToken(deviceToken)
}
```

### Push-notification wiring

UIKit fires push-token and notification callbacks on `AppDelegate` early in the
launch sequence — possibly before any SwiftUI scene has connected. If you hold
`chatProvider` on `AppDelegate` (UIKit pattern above), `setDeviceToken` is
straightforward. If your `chatProvider` lives in SwiftUI, see
[`cs-thread-notifications.md`](cs-thread-notifications.md) for the hand-off
pattern that the sample app uses. Note the cold-launch race: `AppDelegate`
push callbacks can fire before any SwiftUI scene mounts, so assign
`appDelegate.chatProvider` in `App.init()` rather than `.onAppear` if you
observe nil-provider token registrations.

### `events()` lifecycle

- Each call to `chatProvider.events()` returns an **independent**
  `AsyncStream<ChatEvent>`. Multiple components in your app can each subscribe
  and all will receive every event — there is no fan-in and no
  de-duplication across subscribers.
- To stop observing, cancel the enclosing `Task`. The `for await` loop exits.
- The stream **never finishes with an error**. It finishes only when
  `signOut()` is called (or when the last reference to the `CXoneChat` instance
  is released, which finalises the broadcaster).
- SDK errors arrive as the `.error(Error)` case on `ChatEvent` — handle these
  as you would any business-level error (surface to the user, log, or attempt
  recovery, typically a fresh `prepare()` + `connect()`).
- **Buffering:** Each stream buffers at most 64 events. If the consuming `Task`
  falls behind (e.g. the `for await` body does heavy work synchronously), the
  **oldest** buffered events are silently dropped. Keep the `for await` body
  lightweight or dispatch heavy work with `Task { }` to avoid silent event loss.

```swift
// Multiple subscribers are fine — each gets its own stream:
let chatObserver = Task { for await event in chatProvider.events() { /* ... */ } }
let analyticsObserver = Task { for await event in chatProvider.events() { /* ... */ } }

// Cancellation is per-task:
chatObserver.cancel()       // analyticsObserver keeps running
```

## Reference

- **Sample app** (`sample/iOSSDKExample/`) demonstrates the singleton-free
  pattern end to end. See `SDKDemoApp.swift` for construction and
  `AppDelegate.swift` for push wiring.
- **Per-feature integration:**
  [`cs-core-sdk-integration.md`](cs-core-sdk-integration.md),
  [`cs-single-thread.md`](cs-single-thread.md),
  [`cs-multi-thread.md`](cs-multi-thread.md),
  [`cs-livechat.md`](cs-livechat.md),
  [`cs-thread-notifications.md`](cs-thread-notifications.md),
  [`cs-analytics.md`](cs-analytics.md),
  [`cs-custom-fields.md`](cs-custom-fields.md),
  [`cs-custom-customer-id.md`](cs-custom-customer-id.md),
  [`cs-oauth.md`](cs-oauth.md),
  [`cs-inactivity-popup.md`](cs-inactivity-popup.md).
