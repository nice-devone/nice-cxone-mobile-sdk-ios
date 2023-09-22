# Case Study: Multi Thread

The Mobile SDK has support for single-thread and multi-thread channel configuration. This case study provides an example of how a multi-threaded configuration could be handled.


## Example

This example uses some parts of the sample application and is an abbreviated snippet to demonstrate this functionality. The full implementation can be found in the [iOS Sample Application](https://github.com/BrandEmbassy/cxone-mobile-sdk-ios-sample) repository.


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

    func onThreadsLoad(_ threads: [ChatThread]) {
        documentState.threads = threads.filter { documentState.isCurrentThreadsSegmentSelected ? $0.canAddMoreMessages : !$0.canAddMoreMessages }
        
        if !documentState.threads.isEmpty {
            documentState.threads.forEach { thread in
                do {
                    try CXoneChat.shared.threads.loadInfo(for: thread) // (5)
                } catch {
                    error.logError()
                }
            }
        } else {
            viewState.toLoaded(documentState: documentState)
        }
    }

    ...

    func onThreadInfoLoad(_ thread: ChatThread) {
        documentState.threads = getThreads() // (6)
        
        ...
    }
}


// MARK: - Private methods

private extension ThreadListPresenter {

    @MainActor
    func connect() async {
        viewState.toLoading()
        
        ...
        try await CXoneChat.shared.connection.connect(
            environment: env, 
            brandId: input.configuration.brandId, 
            channelId: input.configuration.channelId
        )
        ...
    }
    
    func loadThreads() throws {
        if documentState.isMultiThread {
            try CXoneChat.shared.threads.load() // (4)
        } else {
            ...
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
- (4) Load threads, if available, with the `load()` method.
- (5) Handle loaded threads
  - Load thread information for existing threads
- (6) Store updated threads locally and let the user choose one

> Important: `ChatThreadProvider.load()` may trigger an error `CXoneChatError.recoveringThreadFailed`. However, it indicates CXone service does not contain any existing thread. You can handle this as is in the sample application `onError(_:)` method:
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
