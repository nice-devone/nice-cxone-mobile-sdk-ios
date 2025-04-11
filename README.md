![](https://img.shields.io/badge/security-BlackDuck-blue) ![](https://img.shields.io/badge/security-Veracode-blue)

# CXoneChatSDK

The CXoneChat Mobile SDK empowers developers to build real-time chat applications for mobile platforms using WebSocket communication. With seamless integration, the SDK provides a fast, reliable, and scalable way to connect users with customer service agents or chatbots. By leveraging WebSockets, it ensures low-latency, bi-directional messaging, creating a smooth and responsive chat experience.

## Getting Started

CXone Mobile SDK lets you integrate CXone into your enterprise iOS mobile phone application with operation system iOS 15 and later.

Developing an iOS app using the CXone Mobile package requires the following:
- An Apple Mac computer
- Xcode, downloaded, installed and set up
- Expertise in developing in Swift
- An iPhone or iPad to test push notifications or features related with real device


## Requirements

- iOS 15.0+
- Swift 5+


## Modules

- [Core](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios)
- [UI](https://github.com/nice-devone/nice-cxone-mobile-ui-ios) (⚠️ still under development, not yet actively supported)
- [Sample app](https://github.com/nice-devone/nice-cxone-mobile-sample-ios)


## SDK Integration

1. Open Xcode.
2. Navigate to `File > Swift Packages > Add Package Dependency...`
3. Enter the SDK repository URL https://github.com/nice-devone/nice-cxone-mobile-sdk-ios in the search bar.
4. Select a **Dependency Rule** and specify where you want to save the project. Select your new Xcode project in  **Add to Project**.
5. Finish package import process with click on **Add Package**.

The sample comes from a sample app that you can get from [CXone Mobile SDK sample application](https://github.com/nice-devone/nice-cxone-mobile-sample-ios) or [UI Module](https://github.com/nice-devone/nice-cxone-mobile-ui-ios).


## Connect Your Application to CXone

You need to connect your app to **CXone** to begin communication with the **CXone platform** and to create a *Web Socket* connection. You also need to authorize your app users to use the chat features so they can begin loading threads.

> ⚠️⚠️⚠️ Important: To use the CXone analytic APIs, it is necessary to have the chat in the `.prepared` state, which is achieved using the `ConnectionProvider.prepare(environment:brandId:channelId:)` method, otherwise the SDK will respond with an `illegalChatState` error. Also, the *Web Socket* should only run when necessary. Take care to call `ConnectionProvider.connect()` only for active chat conversations purposes.

1.  Add `ConnectionProvider.connect()` to your app code as early on as possible to fully track user activity. If you've configured OAuth for your app, `connect()` should immediately follow the OAuth code. It uses previously set `Environment`, brandId and channelId using the `ConnectionProvider.prepare(environment:brandId:channelId:)` method.
    ```swift
    try await CXoneChat.shared.connection.connect()
    ```
2. Register `onError(_ error:)` to be able to handle errors occured during thread/s load or other processes.


## Thread handling

You will handle the CXone Mobile SDK for iOS as an extension of a manager. You have the option to use either an asynchronous or live chat channel. The asynchronous channel can be configured in either a single-threaded or multi-threaded configuration.

Set up your app to handle single-thread handling, multi-thread handling, or live chat. If your app is single-threaded, each of your contacts can have only one chat thread. Any interaction they have with your organization takes place in that one chat thread. If your app is multi-threaded, your customer can create as many threads as they want to discuss new topics. These threads can be active at the same time. Live chat is similar to the single-threaded configuration, but with the restriction that conversations cannot be initiated unless an agent is available.

Use the [iOS SDK library](https://nice-devone.github.io/nice-cxone-mobile-sdk-ios/) as you work.

> Important: The SDK utilizes a state-based architecture so it is not necessary to handle everything on your own. For example after establishing a connection, it is not necessary to load thread(s) on your own. The SDK automatically recovers existing or creates a new thread for single-threaded and loads thread metadata for multi-threaded channel configuration. However, if the chat channel contains a pre-chat survey, it is necessary to fill in the survey and manually create a new thread using the `ChatThreadsProvider.create(with:)` method, to which custom fields must be passed. 

1. Choose the manager where you want to add the SDK. Open the file.
2. Import the SDKs into the controller you chose.
    ```swift
    import CXoneChatSDK
    ```
3. Add the inheritance to the manager and set up the delegate. You can define a variable on the class to access the shared functionality from the SDK client or call the SDK singleton directly.
    ```swift
    override func viewDidSubscribe() {
        ...
        CXoneChat.shared.add(delegate: self)
        ...
    }
    ```

### Single-thread - Set Up the Thread Manager

In this moment, you should be already connected to the Web Socket with SDK method `ConnectionProvider.connect()`. As already mentioned, it is not necessary to load previously created thread or create a new one without actual checking it. For single thread continue with following steps:

1. Register `onChatUpdated(_:mode:)` and `onThreadUpdated(_:)` delegate methods in the manager. There are two scenarios:
    a) No thread available and pre-chat has to be completed before creating a new thread – the SDK finished recover process without receiving any thread from the BE. However, it was unable to create a new thread because channel configuration contains pre-chat to be completed. The host application is notified with `onChatUpdated(_:mode:)` delegate method so it can present a form of pre-chat survey custom fields and then provide it to the SDK via `ChatThreadsProvider.create(with:)` method.
    ```swift
    extension Manager: CXoneChatDelegate {

        func onChatUpdated(_ chatState: ChatState, mode: ChatMode) {
            guard chatState >= .ready else {
                return
            }

            ...
            if let preChatSurvey = CXoneChat.shared.threads.preChatSurvey {
                LogManager.trace("Chat(`.singlethread`) is ready to use but there is no thread to use but firstly it is need to fill in the prechat")
        
                let fieldEntities = preChatSurvey.customFields.map(FormCustomFieldTypeMapper.map)

                coordinator.presentForm(title: preChatSurvey.name, customFields: fieldEntities) { [weak self] customFields in
                    LogManager.trace("Pre-chat was filled successfully -> create a new thread")
                        
                    self?.createNewThread(with: customFields)
                }
            } else {
                LogManager.trace("Chat is ready to use but there is no thread to use -> chat mode = `.singlethread` -> creating a new thread")

                createNewThread()
            }
        }
        
        ...
    }
    ```

    b) Thread recovered with previously sent messages or no form needs to be completed – the SDK successfully recovered previously created thread or created a new chat thread. The host application is notified the Manager via `onThreadUpdated(_:)` delegate method. From this point, the UI can be reloaded with thread data and thread is ready to use.
    ```swift
    extension Manager: CXoneChatDelegate {

        func onThreadUpdated(_ thread: ChatThread) {
            ...
        }

        ...
    }
    ```

2. *(optional)* In case you had to complete a pre-chat form, you have to provide those custom fields to the SDK with threads provider method `create(with:)`.
    ```swift
    func createNewThread(with customFields: [String: String]? = nil) {
        do {
            if let customFields {
                try CXoneChat.shared.threads.create(with: customFields)
            } else {
                try CXoneChat.shared.threads.create()
            }
        } catch {
            ...
        }
    }
    ```

> Note: For detailed information on how to handle single-thread channel configuration, see [Case Study: Single Thread](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/tree/main/docs/cs-single-thread.md).

### Multi-thread - Set Up the Thread List

Handling the CXone Mobile SDK thread list is up to you, based on used design pattern. In the examples shown here, sample application is handling the CXoneChatSDK delegate as an extension of the **DefaultChatListViewModel**. After you set up the extension, you don't need to inherit whole CXoneChat delegate - it has its default implementation so you can inherit just those methods you need in the current chat context.

As already mentioned, it is not necessary to load previously created threads because it is automatically handled with `ConnectionProvider.connect()` method. For multi thread continue with following steps:

1. Register `onChatUpdated(_:mode:)` and `onThreadsUpdated(_:)` delegate methods in the manager. There are two scenarios:
    a) No threads available – the SDK finished load process without receiving any threads from the BE -> Empty thread list should be presented.
    ```swift
    extension Manager: CXoneChatDelegate {

        func onChatUpdated(_ chatState: ChatState, mode: ChatMode) {
            ...
        }

        ...
    }
    ```

    b) Threads have been loaded with their metadata – the SDK successfully loaded thread list and also loaded metadata of each thread -> the UI can be reloaded with threads data.
    ```swift
    extension Manager: CXoneChatDelegate {

        func onThreadsUpdated(_ thread: ChatThread) {
            ...
        }

        ...
    }
    ```
2. Multi-threaded channel configuration allows to create a new thread even with another existing one. Also, you can automatically create a new one in case thread list is empty. For a new chat thread, use a threads provider method `create()`.
    
    > Important: If your channel configuration contains pre-chat, it is firstly necessary to fill-in the form and then use `create(with:)` alternative method to provide the custom fields to the SDK.

    ```swift
    func createNewThread(with customFields: [String: String]? = nil) {
        do {
            let threadId: UUID
            
            if let customFields {
                threadId = try CXoneChat.shared.threads.create(with: customFields)
            } else {
                threadId = try CXoneChat.shared.threads.create()
            }
            ...
        } catch {
            ...
        }
    }
    ```

> Note: For detailed information on how to handle multi-thread channel configuration, see [Case Study: Multi Thread](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/tree/main/docs/cs-multi-thread.md).

### LiveChat - Set Up the Thread Manager

Live chat channel may also be offline, based on the chat state `.offline` which can be obtained via `onChatUpdated(_:mode:)` API method. It his case, there is no

In this moment, you should be already connected to the Web Socket with SDK method `ConnectionProvider.connect()`. As already mentioned, it is not necessary to load previously created thread or create a new one without actual checking it. For single thread continue with following steps:

1. Register `onChatUpdated(_:mode:)` and `onThreadUpdated(_:)` delegate methods in the manager. There are two scenarios:
    a) No thread available and pre-chat has to be completed before creating a new thread – the SDK finished recover process without receiving any thread from the BE. However, it was unable to create a new thread because channel configuration contains pre-chat to be completed. The host application is notified with `onChatUpdated(_:mode:)` delegate method so it can present a form of pre-chat survey custom fields and then provide it to the SDK via `ChatThreadsProvider.create(with:)` method.
    ```swift
    extension Manager: CXoneChatDelegate {

        func onChatUpdated(_ chatState: ChatState, mode: ChatMode) {
            guard chatState >= .ready else {
                return
            }

            ...
            if let preChatSurvey = CXoneChat.shared.threads.preChatSurvey {
                LogManager.trace("Chat(`.singlethread`) is ready to use but there is no thread to use but firstly it is need to fill in the prechat")
        
                let fieldEntities = preChatSurvey.customFields.map(FormCustomFieldTypeMapper.map)

                coordinator.presentForm(title: preChatSurvey.name, customFields: fieldEntities) { [weak self] customFields in
                    LogManager.trace("Pre-chat was filled successfully -> create a new thread")
                        
                    self?.createNewThread(with: customFields)
                }
            } else {
                LogManager.trace("Chat is ready to use but there is no thread to use -> chat mode = `.singlethread` -> creating a new thread")

                createNewThread()
            }
        }

        ...
    }
    ```

    b) Thread recovered with previously sent messages or no form needs to be completed – the SDK successfully recovered previously created thread or created a new chat thread. The host application is notified the Manager via `onThreadUpdated(_:)` delegate method. From this point, the UI can be reloaded with thread data and thread is ready to use.
    ```swift
    extension Manager: CXoneChatDelegate {

        func onThreadUpdated(_ thread: ChatThread) {
            ...
        }
        
        ...
    }
    ```

2. *(optional)* In case you had to complete a pre-chat form, you have to provide those custom fields to the SDK with threads provider method `create(with:)`.
    ```swift
    func createNewThread(with customFields: [String: String]? = nil) {
        do {
            if let customFields {
                try CXoneChat.shared.threads.create(with: customFields)
            } else {
                try CXoneChat.shared.threads.create()
            }
        } catch {
            ...
        }
    }
    ```

> Note: For detailed information on how to handle single-thread channel configuration, see [Case Study: LiveChat](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/tree/main/docs/cs-livechat.md).


## Pre-Chat Survey

Before starting a thread you need to check if you need to complete a pre-chat poll. The prechat survey model is available from `ChatThreadsProvider.prechatSurvey`. It consists of mandatory and optional parameters, which can be of 4 types - textfield, e-mail, list and hierarchical. To complete it, you will need:
1. Check that a pre-chat has been defined for the channel.
    ```swift
    if let preChatSurvey = CXoneChat.shared.threads.preChatSurvey {
        ...
    }
    ```
2. Prepare your custom UI form controller where user can fill those required and optional fields. In the sample application this is solved by a `presentForm(title:customFields:onFinished:)` UI module method.
3. Create a new thread with custom fields from the pre-chat survey form controller, as seen in the form completion handler of the code snippet.


## Configure Chat Functions

How you configure your application to send, receive and display chat messages is unique to your situation. The [iOS Samples](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/docs/samples.md) section provides examples of how your application can send messages to an agent, send attachments to an agent, handle messages, perform analytics, and perform other important actions.
