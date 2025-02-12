# Samples

The following sample code is provided to help configure and customize application integration with Digital First Omnichannel chat. The samples come from a sample app that you can get from the [Sample app](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/tree/master/sample).


## Chat Provider

The SDK is available with shared instance via `CXoneChat.shared` which provides `ChatProvider` with available delegates, feature providers and more.

### SDK Version

CXoneChat provides an interface to be able to check version of the SDK runtime. For this case, it is accessible with `CXoneChat.version` property. 

### SDK Chat State

The state defines whether it is necessary to set up the SDK, connect to the CXone services or start communication with an agent.

### SDK Chat Mode

Chat mode based on the channel configuration

### SDK Logging

CXoneChat SDK provides its own logging to be able to track its flow or detect errors occured during events. Internal **LogManager** forwards errors to the host application via `CXoneChatDelegate.onError(_:)` delegate method. You can it to your Log manager or just print messages.

```swift
extension Manager: LogDelegate {
    
    func logError(_ message: String) {
        Log.message("[SDK] \(message)")
    }
    
    func logWarning(_ message: String) {
        Log.message("[SDK] \(message)")
    }
    
    func logInfo(_ message: String) {
        Log.message("[SDK] \(message)")
    }
    
    func logTrace(_ message: String) {
        Log.message("[SDK] \(message)")
    }
}
```

### Chat Delegates

Host application triggers events for various situations - load threads, send message, report sender did start typing etc. Those actions are triggered manually but some events are received as a consequences of sent event. For example, when host application is about to load threads, SDK receives an event `proactiveAction` with welcome message which is not necessary connected with required thread `load()` action. SDK provides several methods described in sections [Event Delegates](#event-delegates).

Host application doesn't necessarily have to register all those methods - the SDK handles this with a default implements. Chat delegate manager can register only those are related to current scene context.

### Logger Configuration

To be able to use internal logger, it is necessary to setup it with a `CXoneChat.configureLogger(level:verbosity:)` method. The method parameters specify log level and verbosity. The `LogManager.Level` determines which messages are going to be forwarded to the host application - `error`, `warning`, `info`, `trace`. The `error` level should be the one, if you want to receive just necessary and serious messages from the SDK. On the other hand, `trace` is the lowest level for tracking SDK so it provides detailed information about what is happening in the SDK. `LogManager.Verbosity` specify how detailed are messages from the internal Log manager - simple, medium, full. The minimum level is a **simple** one which logs occurrence date time and its message. The **full**, apart of that, logs file, line number and function name.

Configure the logger before first interaction with the SDK and register the log delegate.
```swift
CXoneChat.configureLogger(level: .trace, verbosity: .full)
CXoneChat.shared.logDelegate = self
```

### Sign Out

Whenever user are about to log out or end the chat, the SDK provides method to signs the customer out, disconnect from the web socket and reset its services.

> Important: This action also remove all stored data - customer, visitor ID, keychain etc, and creates new instance of the SDK!

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
if let triggerId = UUID(uuidString: "1a2bc345-6789-12a3-4Bbc-d67890e12fhg") {
    do {
        try CXoneChat.shared.connection.executeTrigger(triggerId)
    } catch {
        ...
    }
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

> Important: This feature has to be called before the SDK initialization, via `ConnectionProvider.prepare(brandId:channelId:)` method, or after the sign out. Otherwise, it throws an error.

> Important: Some features are available only when any customer is set. Setting `nil` customer might impact usability of the SDK.

```swift
// Update current
var customer = CXoneChat.shared.customer.get()
customer.firstName = "John"
customer.lastName = "Doe"
try CXoneChat.shared.customer.set(customer: customer)

// Create new
let customer = Customer(id: UUID().uuidString, firstName: "John", lastName: "Doe")
try CXoneChat.shared.customer.set(customer: customer)

// Reset current
try CXoneChat.shared.customer.set(customer: nil)
```

> Important: Setting this feature can lead to security vulnerability. We don't take any responsibility if you will to use your own customer ID. It is recommended to use the SDK generated customer ID.

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
do {
    try CXoneChat.shared.customeFields.set(["age": "29"])
} catch {
    ...
}
```


## Chat Threads

The application can be single- or multi-threaded. If your app is single-threaded, each of your contacts can have only one chat thread. Any interaction they have with your organization takes place in that one chat thread. If your app is multi-threaded, your contacts can create as many threads as they want to discuss new topics. These threads can be active at the same time.

Threads provider allows to get current or load thread/s, create new one, archive or even mark thread a read.
 
Following features are provided via `CXoneChat.shared.threads` provider.

> Important: Threads provider also contain providers for message and contact custom fields according to its context.

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

Retrieving an array of current threads is provided with the `ChatThreadsProvider.get()` method. It returns threads if any exist; otherwise, it returns empty array.

```swift
chatThreads = CXoneChat.shared.threads
    .get()
    .filter { $0.state != .closed }
```

### Create New Thread

For creating a new thread, the SDK provides `ChatThreadsProvider.create()` and `ChatThreadsProvider.create(with:)` methods. The second one is for creation with custom fields from pre-chat survey. You must establish connection to the CXone service via `connect()` before calling this method. If your channel does not support multi-channel configuration, you should not call this method if you already have a thread. If you call this method without first calling `connect()` or if multichannel configurations are not supported, the SDK throws  `unsupportedChannelConfig` error. This method returns the unique identifier of the newly created thread.

```swift
let threadId = try CXoneChat.shared.threads.create()

guard let thread = CXoneChat.shared.threads.get().thread(by: threadId) else {
    ...
}
...
```

### Load Thread(s)

The SDK automatically loads thread(s) when establishing connection to the CXone services and it is not necessary to handle it manually. However, it is necessary to manually load thread for multi-threaded channel configuration because thread list does not contain all previously sent/received messages. When any thread from thread list is selected, host application should use `ChatThreadsProvider.load(with:)` method to recover thread data. The SDK will then notify the application with `onThreadUpdated(_:)` delegate method about recovered thread with all possible data and thread is ready for usage.

> Important: `load(with:)` should no longer be used for loading thread after connection.

```swift
func onAppear() {
    ...

    do {
        ...
        guard CXoneChat.shared.mode == .multithread else {
            return
        }

        try CXoneChat.shared.threads.load(with: thread.id)
    } catch {
        ...
    }
}
```

### Update Thread Name

Updating thread name with `ChatThreadsProvider.updateName(_:for:)` method is available only for multi-thread channel configuration. Also it has to be called only when connection is established and for existing thread. If one of this condition is not satisifed, it throws an error.

```swift
do {
    try CXoneChat.shared.threads.updateName(title, for: self.documentState.thread.id)
} catch {
    ...
}
```

### Archive Thread

`ChatThreadsProvider.archive(_:)` method change thread property `canAddMoreMessages` so user can not communicate with an agent in selected thread. Method is available only for multi-thread channel configuration and with established connection. Any other way it throws an error.

```swift
func onSwipeToDelete(offsets: IndexSet) {
    ...
    do {
        try CXoneChat.shared.threads.archive(deletedThread)
        ...
    } catch {
        ...
    }
}
```

### Mark Thread as Read

The SDK provides `ChatThreadsProvider.markRead(_:)` method which reports that the most recept message, of the specific thread, was ready by the customer.

```swift
func onAppear() {
    ...    
    do {
        ...
        try CXoneChat.shared.threads.markRead(thread)
        ...
    } catch {
        ...
    }
}
```

### End Contact

To be able to end live chat conversation from a customer's perspective, the SDK provides `endContact_:)` method.

> Important: As mentioned above, this method is only available for live chat channel configuration. Otherwise, the SDK will throw an `CXoneChatError.illegalChatState` error.

```swift
func onEndConversation() {
    guard thread.state != .closed else {
        ...
        return
    }
        
    ...
        
    do {
        try CXoneChat.shared.threads.endContact(thread)
        ...
    } catch {
        ...
    }
}
```

### Report Typing Start/End

`ChatThreadsProvider.reportTypingStart(_: in:)` reports the customer has started or finished typing in the specified chat thread. It is necessary to have established connection; otherwise, it throws an error.

```swift
func onUserTyping() {
    ...
    
    do {
        try CXoneChat.shared.threads.reportTypingStart(isUserTyping, in: thread)
    } catch {
        ...
    }
}
```


## Thread Messages

Section with thread messages related methods. These methods allows to load additional messages and send a message.

Following features are provided via `CXoneChat.shared.threads.messages` provider.

### Load More Messages

 `MessagesProvider.loadMore(for:)` loads another page of messages for the thread. By default, when a user loads an old thread, they see a page of 20 messages. This function loads 20 more messages if the user scrolls up and swipe down to load more.

> Important: Should be triggered only in case thread has more messages to load!

```swift
func onPullToRefresh(refreshControl: UIRefreshControl) {
    guard thread.hasMoreMessagesToLoad else {
        ...
        return
    }

    ...
        
    do {
        try CXoneChat.shared.threads.messages.loadMore(for: thread)
    } catch {
       ...
    }
}
```

### Send a Message

Sends the contact's message string, via `MessagesProvider.send(_:for:)` method, through the WebSocket to the thread it belongs to. It is necessary to have established connection; otherwise, it throws an error.

```swift
@MainActor
func onSendMessage(_ messageType: ChatMessageType, attachments: [AttachmentItem], postback: String? = nil) {
    ...
        
    Task { @MainActor in
        do {
            ...
            try await CXoneChat.shared.threads.messages.send(message, for: thread)
            ...
        } catch {
            ...
        }
    }
}
```
Where `message` stands for `OutboundMessage(text:attachments:postback:)`.


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
...
defaultChatCoordinator.presentForm(title: "Custom Fields", customFields: entities) { [weak self] customFields in
    ...
    do {
        try CXoneChat.shared.threads.customFields.set(customFields, for: thread.id)
    } catch {
        ...
    }
}
```


## Analytics

The SDK can report several events from the client side. You can report opening the application, page view, proactive actions or even when customer did start typing.

Following features are provided via `CXoneChat.shared.analytics` provider.

> Important: For Analytics usage, it is necessary to have chat atleast in `.prepared` state!

### Get VisitorID

Whenever you need customer visitor identifier, this provider allows it. In order to create it, it is necessary to previously establish connection or call one of the available analytics methods. Otherwise, it returns nil.

```swift
let visitorId = CXoneChat.shared.analytics.visitorId
```

### View Page

The SDK provides `AnalyticsProvider.viewPage(title:uri:)` method which reports to CXone service some page in the application has been viewed by the visitor. It reports its title and uri.

```swift
func onAppear() {
    Task {
        do {
            try await CXoneChat.shared.analytics.viewPage(title: "products?smartphones", uri: "/products/smartphones")
        } catch {
            ...
        }
    }
    
    ...
}
```

### View Page Ended

The SDK provides `AnalyticsProvider.viewPageEnded(title:uri:)` method which reports to CXone service some page in the application is being closed. It reports its title, uri and internally also current timestamp.

```swift
func willDisappear() {
    Task {
        do {
            try await CXoneChat.shared.analytics.viewPageEnded(title: "products?smartphones", uri: "/products/smartphones")
        } catch {
            ...
        }
    }
    
    ...
}
```

### Chat Window Open

`AnalyticsProvider.chatWindowOpen()` reports to CXone the chat window has been opened by the visitor. It is necessary to have established connection; otherwise, it throws an error.

```swift
func onAppear() {
    ...
    do {
        Task {
            // Report chat window opened
            try await CXoneChat.shared.analytics.chatWindowOpen()
        }
    ...    
    } catch {
        ...
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

### Custom Visitor Event

`AnalyticsProvidercustomVisitorEvent(data:)` can report to CXone service some event, which is not covered by other existing methods, occurred with the visitor. It is necessary to have established connection; otherwise, it throws an error.

```swift
try CXoneChat.analytics.customVisitorEvent(data: .custom(eventData))
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

### On Threads Updated

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
func onAgentTyping(_ isTyping: Bool, threadId: UUID) {
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

### On Proactive Popup Action

Callback to be called when a custom popup proactive action is received.

```swift
func onProactivePopupAction(data: [String: Any], actionId: UUID) {
    ...
}
```
