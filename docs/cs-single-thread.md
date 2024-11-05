# Case Study: Single Thread

The Mobile SDK supports asynchronous (single-thread, multi-thread) and live chat channel configurations. With single-thread configurations, certain features, such as updating the thread name or archiving threads, are limited or unavailable.

The SDK is using state-based architecture and it tries to handle automatically as much stuff as possible. For example, it automatically tries to load thread after the connection was established and in case of non thread available and pre-chat is not needed to be filled-in, it also creates thread and provides it for immediate usage. It means there is no longer need to call `load(with:)` to recover previously created thread or create it manually in case of non available and no pre-chat form. 

> Important: In case the channel has pre-chat survey set, the SDK does not create the thread automatically and the UI has to handle it.


## Example

This example uses some parts of the example application and is an abbreviated snippet to demonstrate this functionality. The full implementation can be found in the [Sample application](https://github.com/nice-devone/nice-cxone-mobile-sample-ios) and [UI Module](https://github.com/nice-devone/nice-cxone-mobile-ui-ios) repositories. However, some parts are edited just to demonstrate the ability to handle single thread configuration. Note that sample application handles all channel configuration so snippets come from different files. Host application will be focused on a single channel configuration (single-threaded, multi-threaded or live chat) so implementation is much simplier.

For single-threaded channel configuration, it is recommended to do following steps:

- (1) Prepare usage of the CXoneChatSDK via `ConnectionProvider.prepare(environment:brandId:channelId)` method
  - the SDK uses state-based architecture so it is necessary to set the SDK to the correct state so web socket connection may be established
- (2) Subscribe to CXone Chat SDK delegate methods
  - Otherwise you will not be able to receive information about the established connection and continue.
- (3) Connect to the CXone services via `ConnectionProvider.connect()` method
- (4) Register `onChatUpdated(_:mode:)` abd `onThreadUpdated(_:)` delegate methods
  - `onChatUpdated(_:mode:)` method allows to track chat state updates, such as connecting or connected state for logging purposes but required state is a `.ready` state. It indicates the chat is ready for usage. This state is received from the SDK in case there is no thread available for usage and it is necessary to fill-in the pre-chat.
  - `onThreadUpdated(_:)` method receives every thread update and also when new thread is created.
- (5) Handle chat transcript UI with loaded thread data

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

    ...
}
```

### Handle Connection - `ChatContainerViewModel.swift`

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
            ...
        case .singlethread, .liveChat:
            if let thread = chatProvider.threads.get().first, thread.state != .closed {
                show(thread: thread)
            } else {
                createThread(onCancel: onDismiss) { [weak self] thread in
                    self?.show(thread: thread)
                }
            }
        }
    }
}
``` 

### Handle Thread - `ThreadViewModel.swift`

Full source code available [here](https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/Sources/Presentation/Thread/ThreadViewModel.swift).

```swift
...
// MARK: - Methods

extension ThreadViewModel {
    
    func onAppear() {
        ...
        containerViewModel?.chatProvider.add(delegate: self) // (2)
        ...
    }
    ...
}
...
// MARK: - CXoneChatDelegate

extension ThreadViewModel: CXoneChatDelegate {
    ...
    func onThreadUpdated(_ updatedThread: ChatThread) { // (4)
        ... // (5)
    }
    ...
}
```