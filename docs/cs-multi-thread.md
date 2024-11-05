# Case Study: Multi Thread

The Mobile SDK has support for asynchronous (single-thread, multi-thread) and live chat channel configuration. In case of multi-thread, there are no features limitations.

The SDK is using state-based architecture and it tries to handle automatically as much stuff as possible. For example, it automatically tries to load threads after the connection was established. However, otherwise from the single-threaded channel configuration, there is no automatic thread creation to be able to present empty chat thread list. 


## Example

This example uses some parts of the example application and is an abbreviated snippet to demonstrate this functionality. The full implementation can be found in the [Sample application](https://github.com/nice-devone/nice-cxone-mobile-sample-ios) and [UI Module](https://github.com/nice-devone/nice-cxone-mobile-ui-ios) repositories. However, some parts are edited just to demonstrate the ability to handle single thread configuration. Note that sample application handles all channel configuration so snippets come from different files. Host application will be focused on a single channel configuration (single-threaded, multi-threaded or live chat) so implementation is much simplier.

For multi-threaded channel configuration, it is recommended to do following steps:

- (1) Prepare usage of the CXoneChatSDK via `ConnectionProvider.prepare(environment:brandId:channelId)` method
  - the SDK uses state-based architecture so it is necessary to set the SDK to the correct state so web socket connection may be established
- (2) Subscribe to CXone Chat SDK delegate methods
  - Otherwise you will not be able to receive information about the established connection and continue.
- (3) Connect to the CXone services via `ConnectionProvider.connect()` method
- (4) Register `onChatUpdated(_:mode:)`, `onThreadsUpdated(_:)` and `onThreadUpdated(_:)` delegate methods in the chat thread list scene manager
  - `onChatUpdated(_:mode:)` method allows you to track updates to chat state, such as connecting or connected state for logging or other purposes.  The `ready` state indicates the chat is ready for usage. This state is triggered from the SDK in case there is no thread available for usage.
  - `onThreadsUpdated(_:)` method is triggered when chat threads changed.
  - `onThreadUpdated(_:)` method is triggered when thread was updated and also when a new one was created.
- (5) Fill-up the table with loaded threads or show empty thread list
- (6) Implement interaction with the chat thread list row to open chat communication with an agent
- (7) Register `onChatUpdated(_:mode:)` abd `onThreadUpdated(_:)` delegate methods in the chat transcript scene
  - `onChatUpdated(_:mode:)` method allows you to track chat state updates, such as connecting or connected state for logging purposes. For this channel configuration, it is mandatory to disconnect when the application enters background and reconnect when returning to the foreground. It is necessary to trigger reload of the chat thread with the `ChatThreadProvider.load(with:)` method. 
  - `onThreadUpdated(_:)` method receives all thread updates, such as new message, assigned agent, updated name, etc.
- (8) Append subscription for CXone Chat SDK delegate methods
- (9) Handle chat transcript UI with loaded thread data


> Important: To see logged warnings/errors you need to configure the SDK logger. This can be done using the `configureLogger(level:verbosity:)` method available in `CXoneChat`.

### Prepare usage of the CXoneChatSDK - `LoginViewModel.swift`

Full source code available [here](https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/iOSSDKExample/Sources/Presentation/Views/Login/LoginViewModel.swift).

```swift
class LoginViewModel: AnalyticsReporter, ObservableObject {
    
    ...
    
    // MARK: - Methods

    override func onAppear() {
        ...
        prepareAndFetchConfiguration()
        ...
    }
    ...
}

...

// MARK: - Private methods

private extension LoginViewModel {
    
    func prepareAndFetchConfiguration() {
        ...
        
        Task { @MainActor in
            do {
                if let env = configuration.environment {
                    try await CXoneChat.shared.connection.prepare(environment: env, brandId: configuration.brandId, channelId: configuration.channelId) // (1)
                } else {
                    ...
                }

                ...
            } catch {
                ...
            }
        }
    }
}
### 
```

### Handle connection - `ChatContainerViewModel.swift`

Full source code available [here](https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/Sources/Presentation/Container/ChatContainerViewModel.swift).

```swift
class ChatContainerViewModel: ObservableObject {

    ...
    
    // MARK: - Methods
    
    func onAppear() {
        LogManager.trace("View did appear")

        chatProvider.add(delegate: self) // (2)
        
        Task {
            do {
                try await CXoneChat.shared.connection.connect() // (3)
            } catch {
                ...
            }
        }
    }
    ...
}

...

// MARK: - CXoneChatDelegate

extension ChatContainerViewModel: CXoneChatDelegate {
    
    func onChatUpdated(_ chatState: ChatState, mode: ChatMode) { // (4)
        ...
        switch chatState {
        case .connecting:
            ...
        case .connected:
            ...
        case .offline:
            ...
        case .ready:
            startChat()
        default:
            ...
        }

    }
    
    private func startChat() {
        ...
        switch chatProvider.mode {
        case .multithread:
            if let uuid = threadToOpen, let thread = chatProvider.threads.get().first(where: { $0.id == uuid }) {
                show(thread: thread, onBack: showThreadList)
            } else {
                showThreadList()
            }
            ...
        case .singlethread, .liveChat:
            ...
        }
    }
}
``` 

### Thread list - `ThreadListViewModel.swift`

Full source code available [here](https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/Sources/Presentation/ThreadList/ThreadListViewModel.swift).

```swift
...
// MARK: - Actions

extension ThreadListViewModel {
    
    func onAppear() {
        ...
        chatProvider.add(delegate: self) // (2)
        
        updateCurrentThreads() // (5)
    }
    ...
    func onThreadTapped(_ thread: ChatThread) { // (6)
        LogManager.trace("Opening chat window")
        
        containerViewModel?.show(thread: thread) { [weak containerViewModel] in
            ...
        }
    }
    ...
}
...
// MARK: - CXoneChatDelegate

extension ThreadListViewModel: CXoneChatDelegate {
    ...
    func onThreadUpdated(_ thread: ChatThread) {
		... // (5)
    }
    
    func onThreadsUpdated(_ chatThreads: [ChatThread]) {
		... // (5)
    }
    ...
}
```

### Handle chat transcript UI with loaded thread data - `ThreadViewModel.swift`

Full source code available [here](https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/Sources/Presentation/Thread/ThreadViewModel.swift).

```swift
...
// MARK: - Methods

extension ThreadViewModel {
    
    func onAppear() {
        ...
        containerViewModel?.chatProvider.add(delegate: self) // (8)
        ...
    }
    ...
}
...
// MARK: - CXoneChatDelegate

extension ThreadViewModel: CXoneChatDelegate {
    ...
    func onThreadUpdated(_ updatedThread: ChatThread) { // (7)
        ... // (9)
    }
    ...
}
``` 
