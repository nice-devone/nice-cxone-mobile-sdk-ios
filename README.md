# Get Started with CXone Mobile SDK for iOS

CXone Mobile SDK lets you integrate CXone into your enterprise iOS mobile phone application with operation system iOS 13 and later.

Developing an iOS app using the CXone Mobile package requires the following:
- An Apple Mac computer
- Xcode, downloaded, installed and set up
- Expertise in developing in Swift
- An iPhone or iPad to test push notifications or features related with real device

The following are optional:
- A third-party UI development package, such as MessageKit. This can save you time, but it could be limiting. Full documentation for MessageKit is available at [messagekit.github.io](https://messagekit.github.io/).

    > Important
    > NICE CXone doesn't own MessageKit or any other UI development package. Problems with using it are outside of NICE         CXone control and support.

## SDK Integration
The sample codes come from a sample app that you can get from [CXone Mobile SDK sample application](https://github.com/nice-devone/nice-cxone-mobile-sample-ios).

> Important
> Complete each of these tasks in given order.

### Import SDK Package to Xcode

1.  Open Xcode.
2.  Create a new project.
3.  Goto **File** and click **Add Packages**.
4.  Enter the SDK repository URL, *https://github.com/nice-devone/nice-cxone-mobile-sdk-ios*, in the search bar.
5.  Select a **Dependency Rule** and specify where you want to save the project. Select your new Xcode project in  **Add to Project**.
6.  Finish package import process with click on **Add Package**.


### Configure OAuth
If you're using OAuth to authenticate your app users, use the steps below. Otherwise, skip this section. This must occur just before the  `connect()` method in your application.

CXone Mobile SDK  supports OAuth 2.0. You can access OAuth 2.0 APIs using a bearer token. A bearer token is a single string sent in an HTTP Authorization header to act as the authentication of the API request. The string can be any length.

> Important
> The code examples in this section use Login with Amazon. Your implementation will look different, depending on your OAuth provider.
1. Configure your chat channel for use with OAuth in  CXone.

    ![](https://help.incontact.com/Dk204am2Whc/Content/CXoneMobileSDK/iOS/Images/OAuthForm.png)

2. Configure your application to prompt the user to sign in with your chosen OAuth service.
    ```swift
    let request = AMZNAuthorizeRequest()
    request.scopes = [AMZNProfileScope.userID(), AMZNProfileScope.profile()]
    request.codeChallengeMethod = "S256"
    request.grantType = .code
    ```

3. If your OAuth service requires a code verifier and code challenge, have your app generate those and pass the code verifier to the SDK with the [setCodeVerifier(_:)](https://help.nice-incontact.com/content/acd/digital/mobilesdk/ios/sdklibrary/protocols/customerprovider.htm#CustomerProvider) method.
    ```swift
    do {
        let codeVerifier = try generateCodeVerifier()
        request.codeChallenge = try generateCodeChallenge(for: codeVerifier)
        
        CXOneChat.shared.customer.setCodeVerifier(codeVerifier)
    } catch {
        ...
    }
    ```
4. Configure your app to receive the authorization code when the user signs in and pass it to the SDK using the [setAuthorizationCode(_:)](https://help.nice-incontact.com/content/acd/digital/mobilesdk/ios/sdklibrary/protocols/customerprovider.htm#CustomerProvider) method.
    ```swift
    AMZNAuthorizationManager.shared().authorize(request) { [weak self] result, _, error in
        ...
        CXOneChat.shared.customer.setAuthorizationCode(result.authorizationCode)
        ...
    }
    ```
5. Have your app navigate the user to the chat view once authentication is complete.

### Connect Your Application to CXone
You need to connect your app to **CXone** to begin communication with the **CXone platform** and to create a *Web Socket* connection. You also need to authorize your app users to use the chat features so they can begin loading threads.

> Important
> The *Web Socket* should only run when necessary. Take care to call `connect()` only for active chat conversations and analytics purposes.

1.  Add [connect(environment:brandId:channelId:)](https://help.nice-incontact.com/content/acd/digital/mobilesdk/ios/sdklibrary/protocols/connectionprovider.htm) to your app code as early on as possible to fully track user activity. If you've configured OAuth for your app, `connect()` should immediately follow the OAuth code. It uses prepared [`Environment`](https://help.nice-incontact.com/content/acd/digital/mobilesdk/ios/sdklibrary/enumerations/environment.htm) with list of regions.
    ```swift
    try  await CXoneChat.shared.connection.connect(
        environment: .NA1, 
        brandId: 1234, 
        channelId: "chat_abcdefgh-1234-5678-ijkl-mnopqrstuvwx"
    )
    ```
    In the sample application, connection is established right after thread list controller subscribed the presenter.
    ```swift
    override func viewDidSubscribe() {
        super.viewDidSubscribe()

        ...
        Task { @MainActor in
            ...
            
            do {
                try await connect()
            } catch {
                ...
            }
        }
    }
    
    ...

    @MainActor
    func connect() async throws {
        let config = input.connectionConfiguration
        
        if config.isCustomEnvironment {
            ...
        } else {
            guard let environment = config.environment else {
                throw CommonError.unableToParse("environment", from: config)
            }
        
            try await CXoneChat.shared.connection.connect(
                environment: environment, 
                brandId: config.brandId, 
                channelId: config.channelId
            )
        }
    }
    ```
3. 4. Register `onThreadLoadFail(_ error:)` to be able to handle errors occured during thread/s load process. Take into account when there are no thread to load, SDK returns `RecoveringThreadFailed` which should be marked as a soft error.

### Thread handling
You will handle the CXone Mobile SDK for iOS as an extension of a manager. You can make your app single- or multi-threaded. 

Set up your app to handle single-thread handling, multi-thread handling, or both. If your app is single-threaded, each of your contacts can have only one chat thread. Any interaction they have with your organization takes place in that one chat thread. If your app is multi-threaded, your customer can create as many threads as they want to discuss new topics. These threads can be active at the same time.

Use the [iOS SDK library](https://help.nice-incontact.com/content/acd/digital/mobilesdk/ios/iossdklibrary.htm?tocpath=MobileSDK%7CCXone%20Mobile%20SDK%7CGet%20Started%20with%20CXone%20Mobile%20SDK%20for%20iOS%7C_____2) as you work.

1. Choose the manager where you want to add the SDK. Open the file.
2. Import the SDKs into the controller you chose.
    ```swift
    import CXoneChatSDK
    ```
3. Add the inheritance to the manager and set up the delegate. You can define a variable on the class to access the shared functionality from the SDK client or call the SDK singleton directly.
    ```swift
    override func viewDidSubscribe() {
        super.viewDidSubscribe()

        CXoneChat.shared.delegate = self
        ...
    }
    ```

#### Single-thread - Set Up the Thread Manager
In this moment, you should be already connected to the Web Socket with SDK method `connect()`. For single thread continue with following steps:

1. Load existing chat thread with threads provider method `load(with:)`. Passing `nil` will attempt to load customer's active thread. If you pass non existing thread ID, it returns `invalidThread` error.
    ```swift
    do {
        try CXoneChat.shared.threads.load(with: nil)
    } catch {
        ...
    }
    ```
2. Register `onThreadLoad(_:)` delegate method in the manager to able to handle loaded thread and navigate user to the chat. 
    ```swift
    extension Manager: CXoneChatDelegate {

    func onThreadLoad(_ thread: ChatThread) {
        ...
        navigation.navigateToThread(thread)
    }
    ```
3. *(optional)* In case you don't have existing thread, create one with threads provider method `create()`.  This method returns `UUID` of a newly created thread to be able to manage new thread directly. For example, if a pre-chat survey is presented right before new thread is created, thread identifier is available right after you create it.
    ```swift
    func  promptContactCustomFields() {
        ...
        let controller = FormViewController(entity: formTextFieldEntity) { [weak self] customFields in
            do {
                let threadId = try CXoneChat.shared.threads.create()
        
                guard let thread = CXoneChat.shared.threads.get().thread(by: threadId) else {
                    ...
                    return
                }

                try CXoneChat.shared.customFields.setContactFields(customFields, for: threadId)
        
                self?.navigation.navigateToThread(thread)
            } catch {
            ...
            }
        }
        ...
    }
    ```

#### Multi-thread - Set Up the Thread List
Handling the CXone Mobile SDK thread list is up to you, based on used design pattern. In the examples shown here, sample application uses MVP pattern which means handling is part of the **Thread List Presenter** as an extension. After you set up the extension, you don't need to inherit whole CXoneChat delegate - it has its default implementation so you can inherit just those methods you need in the current application context.

1. Build the thread table view. For inspiration you can check [implementation for the sample application](https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/iOSSDKExample/Sources/Presentation/Views/ThreadList/ThreadListViewController.swift).
2. Load existing chat threads with threads provider method `load()`. This operation should be called only for multi-thread configuration or when there are no existing threads; otherwise, it throws `unsupportedChannelConfig` error.
    ```swift
    do {
        try CXoneChat.shared.threads.load()
    } catch {
        ...
    }
    ```
3. Register `onThreadLoads(_:)` delegate method to able to handle loaded threads and fill the table.
    ```swift
    extension Manager: CXoneChatDelegate {

    func onThreadLoads(_ threads: [ChatThread]) {
        ...
    }
    ```
4. *(optional)* In case you don't have existing threads, create one with threads provider method `create()`.  This method returns `UUID` of a newly created thread to be able to manage new thread directly. For example, if a pre-chat survey is presented right before new thread is created, thread identifier is available right after you create it.
    ```swift
    func  promptContactCustomFields() {
        ...
        let controller = FormViewController(entity: formTextFieldEntity) { [weak self] customFields in
            do {
                let threadId = try CXoneChat.shared.threads.create()
        
                guard let thread = CXoneChat.shared.threads.get().thread(by: threadId) else {
                    ...
                    return
                }

                try CXoneChat.shared.customFields.setContactFields(customFields, for: threadId)
        
                self?.navigation.navigateToThread(thread)
            } catch {
            ...
            }
        }
        ...
    }
    ```

## Configure Chat Functions

How you configure your app to send, receive, and display chat messages is unique to your situation. Use the  [iOS sample codes](https://help.nice-incontact.com/content/acd/digital/mobilesdk/ios/iossamplecode.htm?tocpath=MobileSDK%7CCXone%20Mobile%20SDK%7CGet%20Started%20with%20CXone%20Mobile%20SDK%20for%20iOS%7CiOS%20Sample%20Code%7C_____0) section to show you examples of how you could have your application send messages to an agent, send attachments to an agent, handle message, analytics and other important actions.
