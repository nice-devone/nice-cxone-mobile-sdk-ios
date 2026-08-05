![](https://img.shields.io/badge/min_iOS-16.0%2B-orange?style=flat) ![](https://img.shields.io/badge/Swift-5.10%2B-orange?style=flat) ![](https://img.shields.io/badge/security-BlackDuck-blue) ![](https://img.shields.io/badge/security-Veracode-blue)

# CXoneChatSDK

The CXoneChat Mobile SDK empowers developers to build real-time chat applications for mobile platforms using WebSocket communication. With seamless integration, the SDK provides a fast, reliable, and scalable way to connect users with customer service agents or chatbots. By leveraging WebSockets, it ensures low-latency, bi-directional messaging, creating a smooth and responsive chat experience.

## Getting Started

CXone Mobile SDK lets you integrate CXone into your enterprise iOS mobile phone application with operating system iOS 16 and later.

Developing an iOS app using the CXone Mobile package requires the following:
- An Apple Mac computer
- Xcode, downloaded, installed and set up
- Expertise in developing in Swift
- An iPhone or iPad to test push notifications or features related with real device


## Requirements

- iOS 16.0+
- Swift 5.10+


## Modules

- [Utility](https://github.com/nice-devone/nice-cxone-mobile-guide-utility-ios)
- Core
- [UI](https://github.com/nice-devone/nice-cxone-mobile-ui-ios)
- [Sample](https://github.com/nice-devone/nice-cxone-mobile-sample-ios)


## SDK Integration

1. Open Xcode.
2. Navigate to `File > Swift Packages > Add Package Dependency...`
3. Enter the SDK repository URL https://github.com/nice-devone/nice-cxone-mobile-sdk-ios in the search bar.
4. Select a **Dependency Rule** and specify where you want to save the project. Select your new Xcode project in  **Add to Project**.
5. Finish package import process with click on **Add Package**.

The sample comes from a sample app that you can get from [CXone Mobile SDK sample application](https://github.com/nice-devone/nice-cxone-mobile-sample-ios) or [UI Module](https://github.com/nice-devone/nice-cxone-mobile-ui-ios).

> ⚠️ Important: To ensure the sustainability of SDK version support, only the last two major versions are permitted. Attempting to use an outdated version will result in a `CXoneChatSDKError.sdkVersionNotSupported` error from the `getChannelConfiguration(environment:brandId:channelId:)` method, which will prevent further use of CXone chat services.


## Lifecycle

The SDK no longer exposes a shared singleton. Construct a `CXoneChat` instance once at app start and hold onto it for the lifetime of the chat experience — typically on your app's root object, a dependency container, or a long-lived view model. All subsequent calls go through this instance (referenced as `chatProvider` throughout this document).

> 📖 **Upgrading from an earlier version that used `CXoneChat.shared` + `CXoneChatDelegate`?** See [`docs/migration-from-singleton.md`](docs/migration-from-singleton.md) for a step-by-step walkthrough with a delegate-method → `ChatEvent`-case mapping table.

```swift
import CXoneChatSDK

let chatProvider = CXoneChat()
```

Pass the instance down to any component that needs to talk to the SDK. The recommended type to thread through your app is the `ChatProvider` protocol, not the concrete `CXoneChat` class — this keeps your app testable and lets you swap in a mock in unit tests.

```swift
final class ChatPresenter {
    let chatProvider: ChatProvider

    init(chatProvider: ChatProvider) {
        self.chatProvider = chatProvider
    }
}
```

### Where to hold the instance

Pick the container that matches your app architecture. The SDK is indifferent — only the **single-instance, held-for-lifetime** rule matters.

**SwiftUI**

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

`CXoneChat` is a `@MainActor` reference type, so `@State` at the app entry point is the simplest holder. If you also need to react to SDK state changes in SwiftUI, wrap `CXoneChat` in your own `ObservableObject` that mirrors `state` from an `events()` loop into a `@Published` property — see `sample/iOSSDKExample/Sources/ChatPresenter.swift` in the sample app.

**UIKit**

```swift
@MainActor
final class AppDelegate: UIResponder, UIApplicationDelegate {

    let chatProvider = CXoneChat()

    // ... rest of the AppDelegate
}
```

View controllers reach it via the delegate:

```swift
let chatProvider = (UIApplication.shared.delegate as! AppDelegate).chatProvider
```

> ⚠️ **Push-notification consumers**: hold `chatProvider` on `AppDelegate` directly. Cold-launch push callbacks fire before any SwiftUI scene appears — see [`docs/cs-thread-notifications.md`](docs/cs-thread-notifications.md) for the full wiring pattern.

### Multiple instances

The SDK does not enforce a single instance per app, but two instances **will conflict on persistent state** — both share the same UserDefaults suite (`"CXoneChatSDK"`) and the same keychain entries. The recommended pattern is **one instance per app**, constructed at launch and held for the app's lifetime.

### Signing out

```swift
chatProvider.signOut()
```

Calling `signOut()`:

1. Disconnects the WebSocket cleanly (no `.unexpectedDisconnect` is emitted).
2. Purges the keychain + UserDefaults state scoped to the SDK.
3. Finishes all in-flight `events()` streams — every `for await event in chatProvider.events()` loop exits.

The instance is **reusable** after `signOut()` — you can call `prepare(...)` + `connect()` again with new credentials. Alternatively, discard the instance and construct a fresh `CXoneChat()` for a hard reset. Both patterns are supported.

> ⚠️ `CXoneChat` is `@MainActor`-isolated. All calls — including property access on the providers (`connection`, `customer`, `threads`, …) — must happen on the main actor. From SwiftUI views, `@MainActor`-annotated view models, or UIKit callbacks you are already on main and no extra ceremony is needed. From background tasks, URLSession delegates, or push-notification callbacks, hop to the main actor first:
>
> ```swift
> await MainActor.run {
>     chatProvider.customer.setDeviceToken(token)
> }
> // or, inside an async context:
> Task { @MainActor in
>     try await chatProvider.connection.connect()
> }
> ```


## Connect Your Application to CXone

You need to connect your app to **CXone** to begin communication with the **CXone platform** and to create a *Web Socket* connection. You also need to authorize your app users to use the chat features so they can begin loading threads.

> ⚠️ Important: To use the CXone analytic APIs, you must first ensure the chat is in the `.prepared` state by calling the `ConnectionProvider.prepare(environment:brandId:channelId:)` method. Otherwise, the SDK will return an `illegalChatState` error. Additionally, Web socket connections should only be active when needed. Only call `ConnectionProvider.connect()` when you have an active chat conversation that requires it.

1.  Add `ConnectionProvider.connect()` to your app code as early on as possible to fully track user activity. If you've configured OAuth for your app, `connect()` should immediately follow the OAuth code. It uses previously set `Environment`, brandId and channelId using the `ConnectionProvider.prepare(environment:brandId:channelId:)` method.
    ```swift
    try await chatProvider.connection.connect()
    ```
2. Observe the SDK event stream (see [Observing SDK Events](#observing-sdk-events) below) to handle `.error(_)` events that may occur during thread load or other processes.


## Observing SDK Events

The SDK publishes all state changes, thread updates, agent activity, and errors through an `AsyncStream<ChatEvent>` returned by `ChatProvider.events()`. Each call to `events()` returns an independent stream, so multiple components in your app can each subscribe to the same SDK instance and all receive every event. To stop observing, cancel the enclosing `Task`.

A minimal observer looks like this:

```swift
let observation = Task { [chatProvider] in
    for await event in chatProvider.events() {
        switch event {
        case .chatUpdated(let state, let mode):
            // React to SDK state / mode changes (e.g. `.ready`, `.offline`).
            break
        case .threadUpdated(let thread):
            // A single thread was updated (single-thread / livechat).
            break
        case .threadsUpdated(let threads):
            // The full thread list was updated (multi-thread).
            break
        case .agentTyping(let isTyping, let agent, let threadId):
            // Show / hide a typing indicator.
            break
        case .error(let error):
            // Handle SDK errors.
            break
        case .unexpectedDisconnect:
            // Reconnect (typically a fresh `prepare()` + `connect()` cycle).
            break
        case .proactiveActionReceived(let action):
            // Present a proactive popup.
            break
        case .customEventMessage, .contactCustomFieldsSet, .customerCustomFieldsSet:
            break
        }
    }
}

// Later, when the screen / view model goes away:
observation.cancel()
```

### Lifecycle and error handling

- **Independent streams.** Each call to `events()` returns its own `AsyncStream`. Multiple components can each subscribe and all receive every event — there is no fan-in or de-duplication. Cancel one subscriber without affecting the others.
- **No stream error termination.** The stream never finishes with an error. SDK errors arrive as the `.error(_)` case on `ChatEvent`. Handle them as you would any business-level error: surface to the user, log, or attempt recovery (typically a fresh `prepare()` + `connect()` cycle). Token problems are not an event: for the implicit OAuth flow the SDK refreshes the connection token silently via the listener registered with `setTokenDelegateListener(_:)`, and an unrecoverable token surfaces as `CXoneChatError.invalidAccessToken` thrown from the failing call — obtain a fresh token, pass it to `setConnectionToken(_:expiresAt:)`, and retry.
- **Clean shutdown.** Calling `chatProvider.signOut()` finishes every active `events()` stream — `for await` loops exit cleanly, no cancellation propagates as an error. Cancel the wrapping `Task` from your own code paths (view-model `deinit`, scene teardown) when you want to stop observing without signing out.

Available `ChatEvent` cases (defined in `CXoneChatSDK.ChatEvent`):

- `chatUpdated(state: ChatState, mode: ChatMode)` — SDK state or chat mode changed.
- `threadUpdated(ChatThread)` — a single thread was updated.
- `threadsUpdated([ChatThread])` — the full thread list was updated.
- `unexpectedDisconnect` — the socket dropped unexpectedly.
- `customEventMessage(Data)` — a custom plugin message was received.
- `agentTyping(isTyping: Bool, agent: Agent, threadId: String)` — agent started / stopped typing.
- `contactCustomFieldsSet` — contact custom fields were set on the backend.
- `customerCustomFieldsSet` — customer custom fields were set on the backend.
- `error(Error)` — an SDK error occurred.
- `proactiveActionReceived(ProactiveActionType)` — a proactive action (e.g. inactivity popup) arrived.


## Thread handling

You will handle the CXone Mobile SDK for iOS as an extension of a manager. You have the option to use either an asynchronous or live chat channel. The asynchronous channel can be configured in either a single-threaded or multi-threaded configuration.

Set up your app to handle single-thread handling, multi-thread handling, or live chat. If your app is single-threaded, each of your contacts can have only one chat thread. Any interaction they have with your organization takes place in that one chat thread. If your app is multi-threaded, your customer can create as many threads as they want to discuss new topics. These threads can be active at the same time. Live chat is similar to the single-threaded configuration, but with the restriction that conversations cannot be initiated unless an agent is available.

Use the [iOS SDK library](https://cautious-sniffle-1d4a9c48.pages.github.io/index.html) as you work.

> Important: The SDK utilizes a state-based architecture so it is not necessary to handle everything on your own. For example after establishing a connection, it is not necessary to load thread(s) on your own. The SDK automatically recovers existing or creates a new thread for single-threaded and loads thread metadata for multi-threaded channel configuration. However, if the chat channel contains a pre-chat survey, it is necessary to fill in the survey and manually create a new thread using the `ChatThreadListProvider.create(with:)` method, to which custom fields must be passed. 

1. Choose the manager where you want to add the SDK. Open the file.
2. Import the SDK into the manager.
    ```swift
    import CXoneChatSDK
    ```
3. Inject the `ChatProvider` instance into the manager (typically through its initializer) and start observing the SDK event stream when the manager becomes active.
    ```swift
    final class Manager {
        private let chatProvider: ChatProvider
        private var observation: Task<Void, Never>?

        init(chatProvider: ChatProvider) {
            self.chatProvider = chatProvider
        }

        func start() {
            observation = Task { [chatProvider] in
                for await event in chatProvider.events() {
                    // handle event (see per-mode sections below)
                }
            }
        }

        func stop() {
            observation?.cancel()
            observation = nil
        }
    }
    ```

### Single-thread - Set Up the Thread Manager

In this moment, you should be already connected to the Web Socket with SDK method `ConnectionProvider.connect()`. As already mentioned, it is not necessary to load previously created thread or create a new one without actual checking it. For single thread continue with following steps:

1. Observe `.chatUpdated(state:mode:)` and `.threadUpdated(_:)` events on the SDK event stream. There are two scenarios:
    a) No thread available and pre-chat has to be completed before creating a new thread – the SDK finished recover process without receiving any thread from the backend. However, it was unable to create a new thread because channel configuration contains pre-chat to be completed. The host application is notified with `.chatUpdated(state:mode:)` so it can present a form of pre-chat survey custom fields and then provide it to the SDK via `ChatThreadListProvider.create(with:)` method.

    b) Thread recovered with previously sent messages or no form needs to be completed – the SDK successfully recovered previously created thread or created a new chat thread. The host application is notified via `.threadUpdated(_:)`. From this point, the UI can be reloaded with thread data and thread is ready to use.

    A single observation loop covers both scenarios:
    ```swift
    Task { [chatProvider, weak self] in
        for await event in chatProvider.events() {
            switch event {
            case .chatUpdated(let chatState, _):
                guard chatState >= .ready else {
                    continue
                }

                if let preChatSurvey = chatProvider.threads.preChatSurvey {
                    LogManager.trace("Chat(`.singlethread`) is ready to use but there is no thread to use but firstly it is need to fill in the prechat")

                    let fieldEntities = preChatSurvey.customFields.map(FormCustomFieldTypeMapper.map)

                    self?.coordinator.presentForm(title: preChatSurvey.name, customFields: fieldEntities) { [weak self] customFields in
                        LogManager.trace("Pre-chat was filled successfully -> create a new thread")

                        self?.createNewThread(with: customFields)
                    }
                } else {
                    LogManager.trace("Chat is ready to use but there is no thread to use -> chat mode = `.singlethread` -> creating a new thread")

                    self?.createNewThread()
                }
            case .threadUpdated(let thread):
                // Reload the UI with the thread data — `thread` is ready to use.
                self?.handle(thread: thread)
            default:
                break
            }
        }
    }
    ```

2. *(optional)* In case you had to complete a pre-chat form, you have to provide those custom fields to the SDK with threads provider method `create(with:)`.
    ```swift
    func createNewThread(with customFields: [String: String]? = nil) {
        do {
            if let customFields {
                try chatProvider.threads.create(with: customFields)
            } else {
                try chatProvider.threads.create()
            }
        } catch {
            ...
        }
    }
    ```

> Note: For detailed information on how to handle single-thread channel configuration, see [Case Study: Single Thread](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/tree/main/docs/cs-single-thread.md).

### Multi-thread - Set Up the Thread List

Handling the CXone Mobile SDK thread list is up to you, based on used design pattern. In the examples shown here, the sample application observes the SDK event stream from inside **DefaultChatListViewModel**. Because events are delivered through a `switch` on `ChatEvent`, you only need to write `case` clauses for the events your screen actually cares about — every other event simply falls through `default`.

As already mentioned, it is not necessary to load previously created threads because it is automatically handled with `ConnectionProvider.connect()` method. For multi thread continue with following steps:

1. Observe `.chatUpdated(state:mode:)` and `.threadsUpdated(_:)` events on the SDK event stream. There are two scenarios:
    a) No threads available – the SDK finished load process without receiving any threads from the backend -> Empty thread list should be presented.

    b) Threads have been loaded with their metadata – the SDK successfully loaded the thread list and also loaded metadata of each thread -> the UI can be reloaded with thread data.

    Both scenarios are surfaced through `.threadsUpdated(_:)` — the empty case is just an empty array:
    ```swift
    Task { [chatProvider, weak self] in
        for await event in chatProvider.events() {
            switch event {
            case .chatUpdated(let chatState, _):
                // React to SDK readiness, e.g. enable the "new thread" button.
                self?.handle(chatState: chatState)
            case .threadsUpdated(let threads):
                // Reload the UI with the (possibly empty) thread list.
                self?.handle(threads: threads)
            default:
                break
            }
        }
    }
    ```

2. Multi-threaded channel configuration allows to create a new thread even with another existing one. Also, you can automatically create a new one in case thread list is empty. For a new chat thread, use a threads provider method `create()`.

    > Important: If your channel configuration contains pre-chat, it is firstly necessary to fill-in the form and then use `create(with:)` alternative method to provide the custom fields to the SDK.

    ```swift
    func createNewThread(with customFields: [String: String]? = nil) {
        do {
            let provider: ChatThreadProvider

            if let customFields {
                provider = try chatProvider.threads.create(with: customFields)
            } else {
                provider = try chatProvider.threads.create()
            }
            ...
        } catch {
            ...
        }
    }
    ```

> Note: For detailed information on how to handle multi-thread channel configuration, see [Case Study: Multi Thread](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/tree/main/docs/cs-multi-thread.md).

### LiveChat - Set Up the Thread Manager

Live chat channel may also be offline, based on the chat state `.offline` which can be obtained via the `.chatUpdated(state:mode:)` event. In this case, there is no agent available to start a conversation with.

In this moment, you should be already connected to the Web Socket with SDK method `ConnectionProvider.connect()`. As already mentioned, it is not necessary to load previously created thread or create a new one without actual checking it. For live chat, continue with the following steps:

1. Observe `.chatUpdated(state:mode:)` and `.threadUpdated(_:)` events on the SDK event stream. There are two scenarios:
    a) No thread available and pre-chat has to be completed before creating a new thread – the SDK finished recover process without receiving any thread from the backend. However, it was unable to create a new thread because channel configuration contains pre-chat to be completed. The host application is notified with `.chatUpdated(state:mode:)` so it can present a form of pre-chat survey custom fields and then provide it to the SDK via `ChatThreadListProvider.create(with:)` method.

    b) Thread recovered with previously sent messages or no form needs to be completed – the SDK successfully recovered previously created thread or created a new chat thread. The host application is notified via `.threadUpdated(_:)`. From this point, the UI can be reloaded with thread data and thread is ready to use.

    A single observation loop, similar to the single-thread case but also handling `.offline`, covers both scenarios:
    ```swift
    Task { [chatProvider, weak self] in
        for await event in chatProvider.events() {
            switch event {
            case .chatUpdated(let chatState, _):
                switch chatState {
                case .offline:
                    // No agent available — present the offline UI.
                    self?.presentOffline()
                case let state where state >= .ready:
                    if let preChatSurvey = chatProvider.threads.preChatSurvey {
                        LogManager.trace("LiveChat ready but pre-chat must be completed first")

                        let fieldEntities = preChatSurvey.customFields.map(FormCustomFieldTypeMapper.map)

                        self?.coordinator.presentForm(title: preChatSurvey.name, customFields: fieldEntities) { [weak self] customFields in
                            LogManager.trace("Pre-chat was filled successfully -> create a new thread")

                            self?.createNewThread(with: customFields)
                        }
                    } else {
                        LogManager.trace("LiveChat is ready and no pre-chat is required -> creating a new thread")

                        self?.createNewThread()
                    }
                default:
                    break
                }
            case .threadUpdated(let thread):
                // Reload the UI with the thread data — `thread` is ready to use.
                self?.handle(thread: thread)
            default:
                break
            }
        }
    }
    ```

2. *(optional)* In case you had to complete a pre-chat form, you have to provide those custom fields to the SDK with threads provider method `create(with:)`.
    ```swift
    func createNewThread(with customFields: [String: String]? = nil) {
        do {
            if let customFields {
                try chatProvider.threads.create(with: customFields)
            } else {
                try chatProvider.threads.create()
            }
        } catch {
            ...
        }
    }
    ```

> Note: For detailed information on how to handle single-thread channel configuration, see [Case Study: LiveChat](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/tree/main/docs/cs-livechat.md).


## Pre-Chat Survey

Before starting a thread you need to check if you need to complete a pre-chat poll. The prechat survey model is available from `ChatThreadListProvider.prechatSurvey`. It consists of mandatory and optional parameters, which can be of 4 types - textfield, e-mail, list and hierarchical. To complete it, you will need:
1. Check that a pre-chat has been defined for the channel.
    ```swift
    if let preChatSurvey = chatProvider.threads.preChatSurvey {
        ...
    }
    ```
2. Prepare your custom UI form controller where user can fill those required and optional fields. In the sample application this is solved by a `presentForm(title:customFields:onFinished:)` UI module method.
3. Create a new thread with custom fields from the pre-chat survey form controller, as seen in the form completion handler of the code snippet.


## Configure Chat Functions

How you configure your application to send, receive and display chat messages is unique to your situation. The [iOS Samples](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/docs/samples.md) section provides examples of how your application can send messages to an agent, send attachments to an agent, handle messages, perform analytics, and perform other important actions.
