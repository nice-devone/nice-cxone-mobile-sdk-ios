# Case Study: Multi Thread

The Mobile SDK has support for asynchronous (single-thread, multi-thread) and live chat channel configuration. In case of multi-thread, there are no features limitations.

The SDK is using state-based architecture and it tries to handle automatically as much stuff as possible. For example, it automatically tries to load threads after the connection was established. However, otherwise from the single-threaded channel configuration, there is no automatic thread creation to be able to present empty chat thread list. 


## Example

This example uses some parts of the example application and is an abbreviated snippet to demonstrate this functionality. The full implementation can be found in the [Sample application](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/tree/main/sample) and [UI Module](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/tree/main/cxone-chat-ui) repositories. However, some parts are edited just to demonstrate the ability to handle single thread configuration.

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
- (8) Override subscription for CXone Chat SDK delegate methods
- (9) Handle chat transcript UI with loaded thread data


> Important: To see logged warnings/errors you need to configure the SDK logger. This can be done using the `configureLogger(level:verbosity:)` method available in `CXoneChat`.

### Prepare usage of the CXoneChatSDK - `LoginViewModel.swift`

Full source code available [here](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/sample/iOSSDKExample/Sources/Presentation/Views/Login/LoginViewModel.swift).

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

### Handle Connection and Loading of threads - `DefaultChatListViewModel.swift`

Full source code available [here](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/cxone-chat-ui/Sources/Presentation/Implementation/Default/DefaultChatListViewModel.swift).

Note that `ConnectionProvider.connect()` (3) is not part of the `DefaultChatViewModel.onAppear()` method because sample application handles both channel configuration and connection has been already established in the `DefaultChatCoordinatorViewModel` which is a screen to decide if the user should be forwarded straight to the chat or to the thread list based on the channel configuration. But the example contain where the `ConnectionProvider.connect()` method could be used.

### Loading rest of the chat thread data - `DefaultChatViewModel.swift`

```swift
class DefaultChatViewModel: ObservableObject {

    ...
    
    // MARK: - Lifecycle
    
    init(thread: ChatThread, coordinator: DefaultChatCoordinator) {
        ...
        CXoneChat.shared.add(delegate: self) // (2)
    }
    ...
    
    // MARK: - Methods
    
    func onAppear() {
        ...
        Task { @MainActor in
            isLoading = true
            
            await connect() // (3)
        }
    }
    ...
    
    func onThreadTapped(_ thread: ChatThread) {
        LogManager.trace("Opening chat window")
        
        coordinator.showThread(thread) // (6)
    }
}

...

// MARK: - CXoneChatDelegate

extension DefaultChatViewModel: CXoneChatDelegate {
    
    func onChatUpdated(_ state: ChatState, mode: ChatMode) { // (4)
        Task { @MainActor in
            switch chatState {
            case .ready:
                isLoading = false // (5)
            default:
                isLoading = true
            }
        }
    }
    
    ...
    
    func onThreadUpdated(_ chatThread: ChatThread) { // (4)
        LogManager.trace("Thread has been updated")
        
        Task { @MainActor in
            ...
        }
    }
    
    func onThreadsUpdated(_ chatThreads: [ChatThread]) { // (4)
        LogManager.trace("Threads has been updated")

        Task { @MainActor in
            updateCurrentThreads(with: chatThreads) // (5)
            
            isLoading = false
        }
    }

    ...
}
```

### Handle chat transcript UI with loaded thread data - `DefaultChatViewModel.swift`

Full source code available [here](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/cxone-chat-ui/Sources/Presentation/Implementation/Default/Chat/DefaultChatViewModel.swift).

```swift
class DefaultChatViewModel: ObservableObject {

    ...
    
    // MARK: - Lifecycle
    
    init(thread: ChatThread, coordinator: DefaultChatCoordinator) {
        ...
        CXoneChat.shared.add(delegate: self) // (8)
    }

    ...
    
    // MARK: - Methods
    
    func onAppear() {
        ...
        Task { @MainActor in
            isLoading = true
            
            await connect() // (3)
        }
    }

    ...
}
...

// MARK: - CXoneChatDelegate

extension DefaultChatViewModel: CXoneChatDelegate {
    
    func onChatUpdated(_ state: ChatState, mode: ChatMode) { // (7)
        switch state {
        case .connecting:
            LogManager.trace("Connecting to the CXone chat services")
            
            Task { @MainActor in
                isLoading = true
            }
        case .connected:
            ...
            LogManager.trace("Did connect to the CXone chat services. Refreshing thread")
                
            do {
                try CXoneChat.shared.threads.load(with: thread.id)
            } catch {
                error.logError()
                    
                dismiss = true
            }
            ...
        default:
            return
        }
    }
    
    ...
    
    func onThreadUpdated(_ chatThread: ChatThread) { // (7)
        LogManager.trace("Thread has been updated")
        
        Task { @MainActor in
            ... // (9)
        }
    }

    ...
}
``` 
