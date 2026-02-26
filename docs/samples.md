# Samples

The following sample code is provided to help configure and customize application integration with Digital First Omnichannel chat. The samples come from a sample app that you can get from the [Sample app](https://github.com/nice-devone/nice-cxone-mobile-sample-ios).


## Chat Provider

The SDK is available with shared instance via `CXoneChat.shared` which provides `ChatProvider` with available delegates, feature providers and more.

### SDK Version

CXoneChat provides an interface to be able to check version of the SDK runtime. For this case, it is accessible with `CXoneChat.version` property. 

### SDK Chat State

The state defines whether it is necessary to set up the SDK, connect to the CXone services or start communication with an agent.

### SDK Chat Mode

Chat mode based on the channel configuration

### SDK Logging

Effective logging is essential for troubleshooting issues, monitoring application behavior, and providing a clear audit trail of events. The CXone Mobile SDK's logging system allows developers to:

 1. Configure log levels to control verbosity
 2. Direct logs to multiple destinations (console, file, crash reporting services)
 3. Format log messages with different levels of detail
 4. Filter logs by category or level
 5. Integrate with existing application logging systems

The SDK includes several implementations:

- `PrintLogWriter`: Outputs logs to the console
- `FileLogWriter`: Writes logs to a file
- `SystemLogWriter`: Sends logs to the system's os.Logger
- `ForkLogWriter`: Distributes logs to multiple LogWriters

The SDK's logging system can be configured by setting the `CXoneChat.logWriter` property:

```swift
 // Use a simple console logger
CXoneChat.logWriter = PrintLogWriter()

// Or configure a more complex setup with filtering and multiple destinations
CXoneChat.logWriter = ForkLogWriter(
    PrintLogWriter().format(.simple),
    FileLogWriter(path: logFileURL).format(.full)
).filter(minLevel: .warning)
```

### Chat Delegates

The host application triggers events for various situations: loading threads, sending messages, reporting typing status, etc. While these actions are triggered manually, some events are received as consequences of other actions. For example, when the host application loads threads, the SDK may receive a `proactiveAction` event with a welcome message that isn't directly related to the `load()` action. The SDK provides several delegate methods described in [Event Delegates](#event-delegates).

The host application doesn't need to register all delegate methods - the SDK provides default implementations. The chat delegate manager can register only those methods relevant to the current scene context.

### Logger Configuration

To be able to use internal logger, it is necessary to set it up with a `CXoneChat.logWriter` property. The logger allows to specify log level and verbosity. The `LogLevel` determines which messages are going to be forwarded to the host application:

- `trace` - Most detailed level for tracing execution flow
- `debug` - Debugging information
- `info` - General informational messages
- `warning` - Potential issues
- `error` - Error conditions
- `fatal` - Critical unrecoverable errors
 
The `error` level should be the one, if you want to receive just necessary and serious messages from the SDK. On the other hand, `trace` is the lowest level for tracking SDK so it provides detailed information about what is happening in the SDK. `LogFormatter` specifies how detailed are messages from the internal Log manager - `simple`, `medium`, `full`. The minimum level is a **simple** one which logs level, category and the message. The **full** level, apart from that, logs timestamp, level, category, location (file + line) and the message.

Configure the logger before first interaction with the SDK and register the log delegate.
```swift
class func configure(
    format: LogFormatter = .full,
    isPrintEnabled: Bool = true,
    isWriteToFileEnabled: Bool = false,
    isCrashlyticsEnabled: Bool = false,
    isSystemEnabled: Bool = false
) {
    var loggers = [any LogWriter]()

    if isPrintEnabled {
        loggers.append(PrintLogWriter())
    }
    
    if isWriteToFileEnabled, let url = getCurrentLogUrl() {
        loggers.append(FileLogWriter(path: url))
    }

    if isCrashlyticsEnabled {
        loggers.append(CrashlyticsLogWriter())
    }

    if isSystemEnabled {
        let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!, // swiftlint:disable:this force_unwrapping
            category: "Application"
        )
            
        loggers.append(SystemLogWriter(logger: logger))
    }

    let instance = loggers.isEmpty ? nil : ForkLogWriter(loggers: loggers).format(format)

    Self.instance = instance
    CXoneChat.logWriter = instance
    ...
}
```

### Chat State

The chat state represents the current status of the chat session and is managed internally by the SDK.

For example, in a live chat channel, when a thread is closed (either by the agent or the customer), the application should present an "End Conversation" experience to the user. You can achieve this by checking the chat mode and the thread state as shown below:

```swift
...
if chatProvider.mode == .liveChat, updatedThread?.state == .closed {
    showEndConversation()
}
...
```

### Chat Mode

The chat mode defines the type of chat experience available to the user, based on the channel configuration.

For example, in a live chat channel, when a thread is closed (either by the agent or the customer), the application should present an "End Conversation" experience to the user. You can achieve this by checking the chat mode and the thread state as shown below:

```swift
...
if chatProvider.mode == .liveChat, updatedThread?.state == .closed {
    showEndConversation()
}
...
```

### Add Delegate

To receive chat events and updates from the SDK, your application should register your delegate instance using the `add(delegate:)` method. This allows your app to respond to events such as thread updates, agent typing, errors, and more.


```swift
func onAppear() {
    ...
    CXoneChat.shared.add(delegate: self)
    ...
}
...
func onThreadUpdated(_ updatedThread: ChatThread) {
    ...
}
```

### Remove Delegate

When the user flow exits a screen or navigates to another context where chat events are no longer relevant, unregister your delegate instance using the `remove(delegate:)` method. This ensures your class stops receiving chat updates and prevents memory leaks or unwanted callbacks.

```swift
func onDisappear() {
    ... 
    CXoneChat.shared.remove(delegate: self)
    ...
}
```
### Sign Out

When users log out or end the chat, use the SDK method that signs the customer out, disconnects from the WebSocket, and resets services.

> ⚠️ Important: This action removes all stored data (customer info, visitor ID, keychain, etc.) and creates a new SDK instance.

```swift
func onSignOutTapped() {
    CXoneChat.signOut()
    ...
}
```


## Connection

Section with connection related methods and properties. These methods allows to get channel configuration, connect to the to the CXone service or send a ping to ensure connection connection is established.

Following features are provided via `CXoneChat.shared.connection` provider.

### Get Channel Configuration

The SDK provides two ways for channel configuration. In case host application is already connected to the CXone service, it is possible to use `ConnectionProvider.channelConfiguration` which returns current configuration. If you call this property without established connection, it returns default configuration which is might not be related to required channel configuration.

```swift
let configuration = CXoneChat.shared.connection.channelConfiguration

// Channel is a multi-thread
if configuration.hasMultipleThreadsPerEndUser {
    ...
} else {
    ...
}
```
In case you need configuration before establishing connection or even preparing for the establishing, there is a `ConnectionProvider.getChannelConfiguration(environment:brandId:channelId:)` method which uses prepared `CXoneChat.Environemnt`.

For example: Get the configuration for brand **1234**, channel **"chat_abcd_1234_efgh"** and located in the **Europe**.

```swift
let configuration = try await CXoneChat.shared.connection.getChannelConfiguration(
    environment: .EU1,
    brandId: 1234,
    channelId: "chat_abcd_1234_efgh"
)
```

The method throws `channelConfigFailure` or `DecodingError.dataCorrupted(_:)` error when it is not possible to initialize connection URL or decode URL response.

### Prepare the SDK for Usage

Before the SDK can be used for any functionality (analytics or chat communication features) it is necessary to prepare it for usage. This is achieved with `prepare(environment:brandId:channelId:)` method. It requires pre-defined `CXoneChat.Environment`,brand ID and channel ID.

For example: Prepareusage of to the brand **1234**, channel **"chat_abcd_1234_efgh"** and located in the **Europe**.

```swift
try await CXoneChat.shared.connection.prepare(
    environment: .EU1, 
    brandId: 1234, 
    channelId: "chat_abcd_1234_efgh"
)
```

### Establish the Connection

The SDK uses state-based architecture, so it is necessary to have the SDK in the correct state. For establishing web socket connection, it is necessary to firstly call `ConnectionProvider.prepare(environment:brandId:channelId:)` which set the SDK to the `.prepared` state. With everything set, the web socket connection can be easily established with `ConnectionProvider.connect` method.

```swift
try await CXoneChat.shared.connection.connect()
```

### Disconnect from CXone Service

Whenever host application should keep customer logged in and sign out from CXone service, use `ConnectionProvider.disconnect()`. It keep connection context and just invalides the web socket.

```swift
CXoneChatSDK.shared.connection.disconnect()
```

### Execute Trigger Manually

CXone platform can contain various triggers related to specific events. Host application can trigger it manually via `ConnectionProvider.executeTrigger(_:)` method based on its unique identifier.

```swift
do {
    try await CXoneChat.shared.connection.executeTrigger("1a2bc345-6789-12a3-4Bbc-d67890e12fhg")
} catch {
    ...
}
```


## Customer

Section with customer related methods and properties. These methods allows to retrieve or set current customer, set OAuth stuff or just update customer credentials.

Following features are provided via `CXoneChat.shared.customer` provider.

### Get Current Customer

The `CustomerProvider.get()` returns a customer who is currently using host application. When establishing a connection, the SDK initialize new customer with empty credentials, so this method returns a customer with nil first and last name.

```swift
let customer = CXoneChat.shared.customer.get()
```

### Set Current Customer

`CustomerProvider.set(_:)` a customer can be used to update empty credentials, creating new one or removing the current.

> ⚠️ Important: This feature has to be called before the SDK initialization, via `ConnectionProvider.prepare(brandId:channelId:)` method, or after the sign out. Otherwise, it throws an error.

> ⚠️ Important: Some features are available only when any customer is set. Setting `nil` customer might impact usability of the SDK.

```swift
// Update current
var customer = CXoneChat.shared.customer.get()
customer.firstName = "John"
customer.lastName = "Doe"
try CXoneChat.shared.customer.set(customer: customer)

// Create new
let customer = Customer(id: UUID().uuidString.lowercased(), firstName: "John", lastName: "Doe")
try CXoneChat.shared.customer.set(customer: customer)

// Reset current
try CXoneChat.shared.customer.set(customer: nil)
```

> ⚠️ Important: Setting this feature can lead to security vulnerability. We don't take any responsibility if you will to use your own customer ID. It is recommended to use the SDK generated customer ID.

### Set Device Token

It is necessary to register the device to be able to use push notifications. For this case the SDK provides two methods `CustomerProvider.setDeviceToken(_:)` - the first one uses a `String` representation of the token, the second one uses the `Data` datatype.
```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    CXoneChat.shared.customer.setDeviceToken(deviceToken)
}
```

### Set Authorization Code

The SDK supports OAuth user authorization. For this feature, application has to provide the code with `CustomerProvider.setAuthorizationCode(_:)` to be able to obtain an access token. It has to be obtained before establishing a connection via `connect()` methods. 

Example from he sample application uses Amazon OAuth:

```swift
AMZNAuthorizationManager.shared().authorize(request) { [weak self] result, _, error in
    ...
    CXoneChat.shared.customer.setAuthorizationCode(result.authorizationCode)
    ...
}
```

### Set Code Verifier

The SDK supports OAuth 2.0 which uses proof key for code exchange - [PKCE](https://oauth.net/2/pkce/). Above setting the authorization code, it is necessary to provide a code verifier with `CustomerProvider.setCodeVerifier(_:)`, which is forwarded in the request to the OAuth authorization manager. Code verifier has to be passed so CXone can retrieve an authorization token. 

The sample application uses third party framework [Swift-PKCE](https://github.com/hendrickson-tyler/swift-pkce) to be able to generate code verifier.

```swift
let request = AMZNAuthorizeRequest()
...

do {
    let codeVerifier = try generateCodeVerifier()
    request.codeChallenge = try generateCodeChallenge(for: codeVerifier)

    CXoneChat.shared.customer.setCodeVerifier(codeVerifier)
} catch {
    ...
}

AMZNAuthorizationManager.shared().authorize(request) { [weak self] result, _, error in
    ...
}
```

### Set Customer Name

Method `CustomerProvider.setName(firstName:lastName:)` updates a customer name, even with empty values or initialize new one when the customer has been set to `nil` with `CustomerProvider.set(_:)` method.

In the sample application, user credentials are provided with pre-chat survey and parsed from the custom fields.

```swift
let controller = FormViewController(entity: entity) { [weak self] customFields in
    CXoneChat.shared.customer.setName(
        firstName: customFields.first { $0.key == "firstName" }.map(\.value) ?? "",
        lastName: customFields.first { $0.key == "lastName" }.map(\.value) ?? ""
    )

    ...
}
```


## Customer Custom Fields

Section with custom fields related methods. These methods allows to contact, specific thread, or customer, persists across all threads, custom fields.

Following features are provided via `CXoneChat.shared.customFields` provider.

### Get Customer Custom Fields

Method `CustomerCustomFieldsProvider.get()` returns array of `CustomFieldType`, that can be a textfield, selector or hierarchical type, if any customer custom fields exists; otherwise, it returns empty array.

```swift
let customerCustomFields: [CustomFieldType] = CXoneChat.shared.customerCustomFields.get()
let ageCustomField = customerCustomFields.first { type in
    guard case .textField(let entity) = type else {
        return false
    }

    return entity.ident == "age"
}
```

### Set Customer Custom Fields

Customer custom fields are related to the customer and across all chat cases (threads). The `CustomerCustomFieldsProvider.set(_:)` method has to be called only with established connection to the CXone service; otherwise, it throws an error.

```swift
func handleAdditionalConfigurationIfNeeded() {
    Task {
        do {
            if !chatConfiguration.additionalCustomerCustomFields.isEmpty {
                // Provide additional customer custom fields
                try await chatProvider.customerCustomFields.set(chatConfiguration.additionalCustomerCustomFields)
            }
        } catch {
            ...
        }
    }
}
```


## Chat Thread List

The application can be single- or multi-threaded. If your app is single-threaded, each of your contacts can have only one chat thread. Any interaction they have with your organization takes place in that one chat thread. If your app is multi-threaded, your contacts can create as many threads as they want to discuss new topics. These threads can be active at the same time.

The Thread List provider allows you to get current threads, load existing threads, create new threads, or obtain a provider to manage individual chat threads.
 
Following features are provided via `CXoneChat.shared.threads` provider.

> ⚠️ Important: Thread List provider also contain providers for chat thread and contact custom fields according to its context.

### Pre-chat Survey

Object representing the form that must be filled in before a new chat thread is created. It contains several fields to be filled in by a customer to be able to get some additional stuff that may solve the reason why the customer wants to communicate with an agent. These fields are both required and optional.

```swift
if let preChatSurvey = CXoneChat.shared.threads.preChatSurvey {
    promptContactCustomFields(with: preChatSurvey)
} else {
    createNewThread()
}
```

### Get Current Threads

Use `ChatThreadListProvider.get()` to retrieve an array of current threads. Returns existing threads or an empty array if none exist.

```swift
chatThreads = CXoneChat.shared.threads
    .get()
    .filter { $0.state != .closed }
```

### Create New Thread

For creating a new thread, the SDK provides `ChatThreadListProvider.create()` and `ChatThreadListProvider.create(with:)` methods. The second one is for creation with custom fields from pre-chat survey. You must establish connection to the CXone service via `connect()` before calling this method. If your channel does not support multi-channel configuration, you should not call this method if you already have a thread. If you call this method without first calling `connect()` or if multichannel configurations are not supported, the SDK throws  `unsupportedChannelConfig` error. This method returns the `ChatThreadProvider` that allows to manage newly created thread. It is also possible to access the thread via the `ChatThreadProvider.chatThread` property

```swift
...
func createNewThread(with customFields: [String: String]? = nil) async throws -> ChatThreadProvider {
    if let customFields {
        return try await chatProvider.threads.create(with: customFields)
    } else {
        return try await chatProvider.threads.create()
    }
}
...
```

### Load Thread(s)

The SDK automatically loads thread(s) when establishing connection to the CXone services and it is not necessary to handle it manually. However, it is necessary to manually load thread for multi-threaded channel configuration because thread list does not contain all previously sent/received messages. When any thread from thread list is selected, host application should use `ChatThreadListProvider.load(with:)` method to recover thread data. The SDK will then notify the application with `onThreadUpdated(_:)` delegate method about recovered thread with all possible data and thread is ready for usage.

> ⚠️ Important: `load(with:)` should no longer be used for loading thread after connection.

```swift
func reloadThread(with id: String) {
    ...

    Task {
        do {
            try await chatProvider.threads.load(with: id)
        } catch {
            ...
        }

        ...
    }
}
```

### Get ChatThread Provider

Obtain a `ChatThreadProvider `instance using either the thread's unique identifier or the `ChatThread` object itself. This provider enables thread management operations like sending messages, marking as read, or ending the conversation.
Retrieve a `ChatThreadProvider` by calling the appropriate method on `ChatThreadListProvider`:

- `provider(for threadId: String)`: Returns the provider for the chat thread with the specified unique identifier.
- `provider(for thread: ChatThread)`: Returns the provider for the given `ChatThread` object.

> ⚠️ Important: If the provided thread identifier or object is invalid, the SDK will throw the `CXoneChatError.invalidThread` error.

```swift
Task { @MainActor in
    do {
        let provider = try chatProvider.threads.provider(for: thread.idString)

        try await provider.archive()
    } catch {
        ...
    }
}
```


## ChatThread Provider

The `ChatThreadProvider` protocol manages individual chat threads. Once you obtain a `ChatThreadProvider` instance (see [Get ChatThread Provider](#get-chatthread-provider)), you can interact with that specific thread.

Key features include:
- Sending messages
- Marking threads as read
- Archiving threads

### Load More Messages


> ⚠️ Important: Should be triggered only in case thread has more messages to load!
`ChatThreadProvider.loadMoreMessages()` loads another page of messages for the thread. By default, when a user loads an old thread, they see a page of 20 messages. This function loads 20 more messages if the user scrolls up and swipe down to load more.

```swift
func loadMoreMessages() async {
    LogManager.trace("Trying to load more messages")
        
    guard let thread, thread.hasMoreMessagesToLoad, let threadProvider = try? chatProvider.threads.provider(for: thread.idString) else {
        ...
        return
    }
        
    do {
        try await threadProvider.loadMoreMessages()
    } catch {
        ...
    }
}
```

### Send a Message

Sends the contact's message string, via `ChatThreadProvider.send(_:)` method, through the WebSocket to the thread it belongs to. It is necessary to have established connection; otherwise, it throws an error.

```swift
func onSendMessage(_ messageType: ChatMessageType, attachments: [AttachmentItem], postback: String? = nil) {
    ...

    guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.idString) else {
        ...
        return
    }

    let message: OutboundMessage

    switch messageType {
    case .text(let text):
        message = OutboundMessage(text: text, attachments: attachments.compactMap(AttachmentItemMapper.map), postback: postback)
    case .audio(let item):
        message = OutboundMessage(text: "", attachments: [AttachmentItemMapper.map(item)], postback: postback)
    default:
        ...
        return
    }

    Task { @MainActor in
        do {
            try await threadProvider.send(message)
        } catch {
            ...
        }
    }
}
```
Where `message` stands for `OutboundMessage(text:attachments:postback:)`.

### Update Thread Name

The `ChatThreadProvider.updateName(_:)` method updates a thread's name. Requirements:
- Multi-thread channel configuration
- Established connection
- Existing thread
Throws an error if any requirement is not met.

```swift
func setThread(name: String) {
    ...

    guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.idString) else {
        ...
        return
    }

    Task {
        do {
            try await threadProvider.updateName(name)
        } catch {
        ...
        }
    }
}
```

### Archive Thread

The `ChatThreadProvider.archive()` method sets the thread's `canAddMoreMessages` property to prevent further communication with the agent. This method requires a multi-thread channel configuration and an established connection, otherwise it throws an error.

```swift
func onArchive(_ thread: CXoneChatUI.ChatThread) {
    ...
 
    Task { @MainActor in
        do {
            let provider = try chatProvider.threads.provider(for: thread.idString)
            
            try await provider.archive()
        } catch {
            ...
        }
    }
}
```

### Mark Thread as Read

Use `ChatThreadListProvider.markRead(_:)` to mark the most recent message in a thread as read by the customer

```swift
func onAppear() {
    ...    
    guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.idString) else {
        ...
        return
    }
                
    if thread.state == .ready {
        ...
         
        try await threadProvider.markRead()
    }
}
```

### End Contact

To be able to end live chat conversation from a customer's perspective, the SDK provides `endContact_:)` method.

> ⚠️ Important: As mentioned above, this method is only available for live chat channel configuration. Otherwise, the SDK will throw an `CXoneChatError.illegalChatState` error.

```swift
func onEndConversation() {
    guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.idString) else {
        ...
        return
    }

    Task { @MainActor in
        ...
 
        do {
            try await threadProvider.endContact()
            
            showEndConversation()
        } catch {
            ...
        }
    }
}
```

### Report Typing Start/End

`ChatThreadProvider.reportTypingStart(_:)` reports the customer has started or finished typing in the specified chat thread. It is necessary to have established connection; otherwise, it throws an error.

```swift
func onUserTyping() {
    LogManager.trace("User has \(isUserTyping ? "started" : "ended") typing")

    guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.idString) else {
        ...
        return
    }

    Task {
        do {
            try await threadProvider.reportTypingStart(isUserTyping)
        } catch {
            ...
        }
    }
}
```


## Thread Custom Fields

Section with contact custom fields related methods. These methods allows to get and set contact, specific thread, custom fields.

Following features are provided via `CXoneChat.shared.threads.customFields` provider.

### Get Customer Custom Fields

Method `ContactCustomFieldsProvider.get(for:)` returns array of `CustomFieldType`, that can be a textfield, selector or hierarchical type, if any customer custom fields exists; otherwise, it returns empty array.

```swift
let contactCustomFields: [CustomFieldType] = CXoneChat.shared.threads.customFields.get()
let locationCustomField = contactCustomFields.first { type in
    guard case .textField(let entity) = type else {
        return false
    }

    return entity.ident == "location"
}
```

### Set Contact Custom Fields

Contact custom fields are related to the customer and specific chat case (thread). `ContactCustomFieldsProvider.set(_:for:)` stores custom fields based on thread unique identifier. This method has to be called only with established connection to the CXone service; otherwise, it throws an error.

```swift
func onEditPrechatField() {
    ...

    Task {
        guard let answers = await containerViewModel?.showForm(title: localization.alertEditPrechatCustomFieldsTitle, fields: customFields) else {
            return
        }

        do {
            try await chatProvider.threads.customFields.set(answers, for: thread.idString)
        } catch {
            ...
        }
    }
}
```


## Analytics

The SDK can report several events from the client side. You can report opening the application, page view, proactive actions or even when customer did start typing.

Following features are provided via `CXoneChat.shared.analytics` provider.

> ⚠️ Important: For Analytics usage, it is necessary to have chat at least in `.prepared` state!

### Get VisitorID

Whenever you need customer visitor identifier, this provider allows it. In order to create it, it is necessary to previously establish connection or call one of the available analytics methods. Otherwise, it returns nil.

```swift
let visitorId = CXoneChat.shared.analytics.visitorId
```

### View Page

The SDK provides `AnalyticsProvider.viewPage(title:uri:)` method which reports to CXone service some page in the application has been viewed by the visitor. It reports its title and uri.

```swift
class CartViewModel: AnalyticsReporter, ObservableObject {

    init(
        ...
    ) {
        ...
        super.init(analyticsTitle: "cart", analyticsUrl: "/cart")
    }
}
...
class AnalyticsReporter {
    ...
    @objc
    func onViewDidAppear() {
        ...

        guard !analyticsTitle.isEmpty, !analyticsUrl.isEmpty else {
            ...
        }

        Task {
            do {
                try await CXoneChat.shared.analytics.viewPage(title: analyticsTitle, url: analyticsUrl)
            } catch {
                ...
            }
        }
    }
}
```

### View Page Ended

The SDK provides `AnalyticsProvider.viewPageEnded(title:uri:)` method which reports to CXone service some page in the application is being closed. It reports its title, uri and internally also current timestamp.

```swift
@objc
func didEnterBackground() {
    ...
 
    guard !analyticsTitle.isEmpty, !analyticsUrl.isEmpty else {
        ...
    }

    Task {
        do {
            try await CXoneChat.shared.analytics.viewPageEnded(title: analyticsTitle, url: analyticsUrl)
        } catch {
            ...
        }
    }
}
```

### Chat Window Open

`AnalyticsProvider.chatWindowOpen()` reports to CXone the chat window has been opened by the visitor. It is necessary to have established connection; otherwise, it throws an error.

```swift
func onChatUpdated(_ chatState: ChatState, mode: ChatMode) {
    LogManager.scope {
        ...
            
        switch chatState {
            ...
            case .connected:
                ...

                Task {
                    do {
                        ...
                        
                        try await self.chatProvider.analytics.chatWindowOpen()
                    } catch {
                        ...
                    }
                }
            ...
        ...
        }
    }
}
```

### Conversion

`AnalyticsProvider.conversion(type:value:)` is an event which notifes the backend that a conversion has been made. Conversions are understood as a completed activities that are important to your business. It is necessary to have established connection; otherwise, it throws an error.is an event which notifes the backend that a conversion has been made. Conversions are completed activities as defined by your business requirements, typically this would be a completed sale or other "final" event. It is necessary to have established connection; otherwise, it throws an error.

```swift
@MainActor
func checkout() async {
    ...
    
    Task {
        do {
            try await CXoneChat.shared.analytics.conversion(type: "purchase", value: totalAmount)
        } catch {
            ...
        }
    }
        
    ...
}
```

### Proactive Action Display

`AnalyticsProvider.proactiveActionDisplay(data:)` reports proactive action was displayed to the visitor in the application. It is necessary to have established connection; otherwise, it throws an error.

```swift
func setup() {
    ...
    Task {
        do {
            try await CXoneChat.shared.analytics.proactiveActionDisplay(data: actionDetails)
        } catch {
            ...
        }
    }
        
    ...
}
```

### Proactive Action Analytics

> **Note**: The following analytics methods are deprecated. For new implementations, use the `ProactiveActionProvider.trigger()` method instead. See the [Inactivity Popup Case Study](cs-inactivity-popup.md) for the recommended approach.

### Proactive Action Click

`AnalyticsProvider.proactiveActionClick(data:)` reports proactive action was clicked or acted upon by the visitor. It is necessary to have established connection; otherwise, it throws an error.

```swift
func onProactiveActionClicked() {
    ...
    
    Task {
        do {
            try await CXoneChat.shared.analytics.proactiveActionClick(data: self.actionDetails)
        } catch {
            ...
        }
    }
    
    ...
}
```

### Proactive Action Success/Failure

`AnalyticsProvider.proactiveActionSuccess(_: data:)` reports proactive action was successful or fails and lead to a conversion based on `Bool` given in the parameter. It is necessary to have established connection; otherwise, it throws an error.

```swift
func reportProactiveAction(successful: Bool) {
    ...

    Task {
        do {
            try await CXoneChat.shared.analytics.proactiveActionSuccess(successful, data: self.actionDetails)
        } catch {
            ...
        }
    }

    ...
}
```

## Proactive Actions

The SDK provides a modern API for handling proactive actions like inactivity popups. Use the `ProactiveActionProvider` for type-safe, semantic action handling.

### Using the Proactive Action Provider

```swift
// Get the proactive action provider
let proactiveAction = CXoneChat.shared.proactiveAction

// Handle different action types
Task {
    do {
        switch actionType {
        case .refreshSession:
            try await proactiveAction.trigger(.refreshSession(popup))
        case .expireSession:
            try await proactiveAction.trigger(.expireSession(popup))
        }
    } catch {
        print("Failed to trigger proactive action: \(error)")
    }
}
```

**Benefits of the New API:**
- Type-safe action handling with associated data
- Clear separation of concerns
- Automatic response formatting
- Better error handling
- Consistent with modern Swift patterns

For complete implementation details, see our [Inactivity Popup Case Study](cs-inactivity-popup.md).

## Event Delegates

The following are examples, from the sample application, of actions that can occur during a chat that you might want to have trigger an action. These `CXoneChatDelegate` events might cause a notification to appear, a new page to open, or some other action to occur.

### On Chat Updated

Callback to be called when the chat state has been updated. it can handle loading while preparing or connecting to the CXone services or trigger new chat thread creation.

```swift
func onChatUpdated(_ chatState: ChatState, mode: ChatMode) {
    ...
}
```


### On Unexpected Disconnect
Callback to be called when the connection unexpectedly drops. If possible, you can immediately reconnect to the CXone services.

```swift
func onUnexpectedDisconnect() {
    ...

    Task { @MainActor in
        do {
            try await connect()
        } catch {
            ...
        }
    }
}
```

### On Thread Updated

Callback to be called when a thread has been recovered with all data. This event is fired whenever a chat thread is modified, e.g. thread name updated, agent changed, more messages loaded or received/sent message.

It is necessary to handle everything that was previously handled via `onAgentChanged(_:for:)`, `onThreadUpdate()`, `onAgentReadMessage(threadId:)`, etc. within this delegate method.

```swift
func onThreadUpdated(_ chatThread: ChatThread) {
    ...
}
```

### On Threads Updated

Callback to be called when a threads have been loaded with metadata and ready to use. This event is fired whenever a chat threads are modified, e.g. thread archived.

```swift
func onThreadsUpdated(_ chatThreads: [ChatThread]) {
    ...
}
```

### On Custom Message

Callback to be called when a custom message is received.

```swift
func onCustomEventMessage(_ messageData: Data) {
    ...
}
```

### On Agent Typing Started/Ended

Callback to be called when the agent has stared/stopped typing.

```swift
func onAgentTyping(_ isTyping: Bool, threadId: String) {
    ...
}
```

### On Contact Custom Fields Set

Callback to be called when the custom fields are set for a contact.

```swift
func onContactCustomFieldsSet() {
    ...
}
```

### On Customer Custom Fields Set

Callback to be called when the custom fields are set for a customer.

```swift
func onCustomerCustomFieldsSet() {
    ...
}
```

### On Error

Callback to be called when an error occurs.

```swift
func onError(_ error: Error) {
    ...
}
```

### On Token Refresh Failed

Callback to be called when refreshing the token has failed.

```swift
func onTokenRefreshFailed() {
    ...
}
```

### On Proactive Action Received

Callback to be called when a proactive action with typed data is received.

```swift
func onProactiveActionReceived(of type: ProactiveActionType) {
    switch type {
    case .inactivityPopup(let popup):
        // Handle inactivity popup
        handleInactivityPopup(popup)
    case .customPopupBox:
        ...
    }
}

private func handleInactivityPopup(_ popup: InactivityPopup) {
    ...
}
```

**Important Notes:**
- The inactivity popup feature works for live chat channels only (not available for messaging)
- You must implement this delegate method to handle inactivity popups
- Use the `ProactiveActionTrigger` enum for type-safe responses
- The SDK automatically handles the response formatting and server communication
- **Architecture**: The backend handles session timing and expiration - don't implement custom timers
- For a complete implementation, see our [Inactivity Popup Case Study](cs-inactivity-popup.md)
