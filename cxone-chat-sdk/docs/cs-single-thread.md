# Case Study: Single Thread

The Mobile SDK has support for single-thread and multi-thread channel configuration. In case of single thread, some features are limited or not available, such as thread name update or thread archive. Whenever you want to use only a single thread, regardless of the server-side settings, you'll be able to use
several shortcuts. In particular, you can bypass the thread list and automatically select the first conversation or create a new one.


## Example

This example uses some parts of the example application and is an abbreviated snippet to demonstrate this functionality. The full implementation can be found in the [iOS Sample application](https://github.com/BrandEmbassy/cxone-mobile-sdk-ios-sample) repository. However, some parts are edited just to demonstrate the ability to handle single thread configuration.


### `TheadListViewController.swift`

Full source code available [here](https://github.com/BrandEmbassy/cxone-mobile-sdk-ios-sample/blob/master/iOSSDKExample/Sources/Presentation/Views/ThreadList/TheadListViewController.swift).

```swift
class ThreadListViewController: BaseViewController, ViewRenderable {

    // MARK: - Properties
    
    let presenter: ThreadListPresenter
    ...


    // MARK: - Init
    
    ...
    init(presenter: ThreadListPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }


    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.subscribe(from: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter.onViewDidAppear()
    }
    ...
}
```


### `ThreadListPresenter.swift`

Full source code available [here](https://github.com/BrandEmbassy/cxone-mobile-sdk-ios-sample/blob/master/iOSSDKExample/Sources/Presentation/Views/ThreadList/ThreadListPresenter.swift).

> Warning: To be able to use CXone services, you must first establish a connection. Otherwise the SDK will throw a `CXoneChatError.notConnected` error. In this example the connection flow is included.

```swift
class ThreadListPresenter: BasePresenter<ThreadListPresenter.Input, ThreadListPresenter.Navigation, Void, ThreadListViewState> {

    // MARK: - Structs

    struct Input {
        let configuration: Configuration
        ...
    }

    struct DocumentState {
        ...
        var threads = [ChatThread]()
        ...
        var isMultiThread: Bool { CXoneChat.shared.connection.channelConfiguration.hasMultipleThreadsPerEndUser }
    }
}


// MARK: - Actions

extension ThreadListPresenter {
    
    func onViewDidAppear() {
        CXoneChat.shared.delegate = self // (1)
        
        if documentState.isConnected {
            ...
        } else {
            Task { @MainActor in
                await connect() // (2)
            }
        }
    }
    ...
}


// MARK: - CXoneChatDelegate

extension ThreadListPresenter: CXoneChatDelegate {
    
    func onConnect() {
        ...
        do {
            try loadThreads() // (3)
            ...
        } catch {
            ...
        }
    }

    ...

    func onThreadLoad(_ thread: ChatThread) {
        ...
        // Load its metadata and then open with loaded last message:
        do {
            try CXoneChat.shared.threads.loadInfo(for: thread) // (5)
        } catch {
            ...
        }
    }

    ...

    func onThreadInfoLoad(_ thread: ChatThread) {
        ...
        navigation.navigateToThread(thread) // (6)
        ...
    }
}


// MARK: - Private methods

private extension ThreadListPresenter {

    @MainActor
    func connect() async {
        viewState.toLoading()
        
        do {
            if let env = input.configuration.environment {
                try await CXoneChat.shared.connection.connect(
                    environment: env, 
                    brandId: input.configuration.brandId, 
                    channelId: input.configuration.channelId
                )
            } else {
                try await CXoneChat.shared.connection.connect(
                    chatURL: input.configuration.chatUrl,
                    socketURL: input.configuration.socketUrl,
                    brandId: input.configuration.brandId,
                    channelId: input.configuration.channelId
                )
            }
        } catch {
            ...
        }
    }
    
    func loadThreads() throws {
        if documentState.isMultiThread {
            ...
        } else {
            try CXoneChat.shared.threads.load(with: nil) // (4)
        }
    }
    ...
}
```

- (1) Subscribe to CXone Chat SDK delegate methods
  - Otherwise you will not be able to receive information about the established connection and continue. 
- (2) Connect to CXone services
- (3) Load threads
  - Note that the sample application handles configuration settings for both channels.
- (4) Load the thread, if it exists, using the `load(with: nil)` method.
  - nil' indicates that we want to load an existing thread. However, it cannot be used for multithread configuration.
- (5) Load metadata for the loaded thread
- (6) Open thread details

> Important: `ChatThreadProvider.load(with: nil)` can cause the error `CXoneChatError.recoveringThreadFailed`. However, it indicates that the CXone service does not contain an existing thread. You can handle this as is in the sample application's `onError(_:)` method:
```swift
func onError(_ error: Error) {
    // "recoveringThreadFailed" is a soft error.
    if let error = error as? CXoneChatError, error == CXoneChatError.recoveringThreadFailed {
        Log.info(error.localizedDescription)
    } else {
        error.logError()
    }
        
    viewState.toLoaded(documentState: documentState)
}
```

> Important: To see logged warnings/errors you need to configure the SDK logger. This can be done using the `configureLogger(level:verbosity:)` method available in `CXoneChat`.