# Case Study: Single Thread

The Mobile SDK supports asynchronous (single-thread, multi-thread) and live chat channel configurations. With single-thread configurations, certain features, such as updating the thread name or archiving threads, are limited or unavailable.

The SDK is using state-based architecture and it tries to handle automatically as much stuff as possible. For example, it automatically tries to load thread after the connection was established and in case of non thread available and pre-chat is not needed to be filled-in, it also creates thread and provides it for immediate usage. It means there is no longer need to call `load(with:)` to recover previously created thread or create it manually in case of non available and no pre-chat form. 

> Important: In case the channel has pre-chat survey set, the SDK does not create the thread automatically and the UI has to handle it.


## Example

This example uses some parts of the example application and is an abbreviated snippet to demonstrate this functionality. The full implementation can be found in the [Sample application](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/tree/main/sample) and [UI Module](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/tree/main/cxone-chat-ui) repositories. However, some parts are edited just to demonstrate the ability to handle single thread configuration.

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

    ...
}
```

### Handle Connection and Loading of the thread - `DefaultChatViewModel.swift`

Full source code available [here](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/cxone-chat-ui/Sources/Presentation/Implementation/Default/Chat/DefaultChatViewModel.swift).

Note that `ConnectionProvider.connect()` (3) is not part of the `DefaultChatViewModel.onAppear()` method because sample application handles both channel configuration and connection has been already established in the `DefaultChatCoordinatorViewModel` which is a screen to decide if the user should be forwarded straight to the chat or to the thread list based on the channel configuration. But the example contain where the `ConnectionProvider.connect()` method could be used.

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
}

...

// MARK: - CXoneChatDelegate

extension DefaultChatViewModel: CXoneChatDelegate {
    
    func onChatUpdated(_ state: ChatState, mode: ChatMode) { // (4)
        switch state {
        case .connecting:
            LogManager.trace("Connecting to the CXone chat services")
            
            Task { @MainActor in
                isLoading = true
            }
        case .connected:
            ...
        default:
            return
        }
    }
    
    ...
    
    func onThreadUpdated(_ chatThread: ChatThread) { // (4)
        LogManager.trace("Thread has been updated")
        
        Task { @MainActor in
            ... // (5)
        }
    }

    ...
}
``` 
