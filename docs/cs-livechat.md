# Case Study: Live Chat

The Mobile SDK has support for asynchronous (single-thread, multi-thread) and live chat channel configuration. In case of live chat, the whole behavior is different. The chat availability is based on the availability of agents, akin to business hours.
The SDK indicates no agent is available with an `.offline` chat state.  In this case, no web socket connection is established. However, it is still possible to use analytics events, as they are not web socket-based.

When the chat is available, the SDK first attempts to load any previously created thread to continue the conversation. If no thread is available, the SDK automatically creates one and assigns a user to the queue.

> Important: The live chat configuration also has some feature limitations, similar to the single-thread configuration. For example, updating the thread name or archiving the thread is prohibited.

The SDK employs a state-based architecture and handles many operations automatically. For instance, it attempts to load a thread after establishing a connection and, if no thread is available and no pre-chat form is needed, it creates a thread for immediate use. Thus, there is no need to manually call `load(with:)` to recover a previously created thread or create a new one if none is available and no pre-chat form is necessary.

> Important: If the channel is configured with a pre-chat survey, the SDK does not automatically create the thread, and the UI must manage this.


## Example

This example uses some parts of the example application and is an abbreviated snippet to demonstrate this functionality. The full implementation can be found in the [Sample application](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/tree/main/sample) and [UI Module](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/tree/main/cxone-chat-ui) repositories. However, some parts are edited just to demonstrate the ability to handle single thread configuration.

For live chat channel configuration, it is recommended to do following steps:

1. Prepare usage of the CXoneChatSDK via `ConnectionProvider.prepare(environment:brandId:channelId)` method
  - the SDK uses state-based architecture so it is necessary to set the SDK to the correct state before the web socket connection may be established
2. Subscribe to CXone Chat SDK delegate methods
  - Otherwise you will not be able to receive information about the established connection and continue.
3. Connect to the CXone services via `ConnectionProvider.connect()` method
4. Register `onChatUpdated(_:mode:)` and `onThreadUpdated(_:)` delegate methods
  - `onChatUpdated(_:mode:)` method allows to track chat state updates, such as connecting or connected state for logging purposes but required state is a `.ready` state. It indicates the chat is ready for usage. This state is received from the SDK in case there is no thread available for usage and it is necessary to complete the pre-chat. Also, for live chat channel configuration, it is necessary to handle `.offline` state.
  - `onThreadUpdated(_:)` method receives every thread update and also when new thread is created.
5. Handle chat transcript UI with loaded thread data
6. Handle end conversation from a customer/an agent perspective
  - From a customer perspective, the UI should allow trigger `endContact(_:)` SDK API method.
  - From an agent perspective, the `onThreadUpdated(_:)` SDK API method is triggered with chat thread state updated to `.closed`. The chat should have message sending disabled and an overlay of future steps will be displayed.

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
```

### Handle Connection and Loading of the thread - `DefaultChatViewModel.swift`

Full source code available [here](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/cxone-chat-ui/Sources/Presentation/Implementation/Default/Chat/DefaultChatViewModel.swift).

Note that `ConnectionProvider.connect()` (3) is not part of the `DefaultChatViewModel.onAppear()` method because sample application handles all channel configuration and connection has been already established in the `DefaultChatCoordinatorViewModel` which is a screen to decide if the user should be forwarded straight to the chat or to the thread list based on the channel configuration. But the examples demonstrate where the `ConnectionProvider.connect()` method could be used.

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
        case .offline:
            LogManager.trace("CXone chat is offline due to no agents available")
            
            // Handle offline state
            ...
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

            if !isEndConversationVisible, CXoneChat.shared.mode == .liveChat, updatedThread.state == .closed { // (6)
                if updatedThread.state != thread.state {
                    isEndConversationVisible = true
                } else if updatedThread.assignedAgent == nil, thread.assignedAgent != nil {
                    isEndConversationVisible = false
                }
            }
            ..
        }
    }

    ...
}
``` 
