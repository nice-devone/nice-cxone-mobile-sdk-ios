# Case Study: Analytics

Analytics is a useful and powerful feature. The iOS SDK provides several methods for tracking the customer's journey through the application. Additionally, the CXone backend offers WorkFlow Automation (WFA) functionality, which is based on Chat SDK reporting of analytics events that serve as triggers for automation. More information about WFA can be found in the [CXone documentation](https://help.nice-incontact.com/content/acd/digital/chat/workflowautomation.htm).


## Events

- `viewPage(title:url:)`
  - This event is triggered when a user has visited a page or screen in the host application. The exact definition of a page or screen is up to the implementer, but should be fine-grained enough for analytics purposes.
    A PageView event must be generated for each page visited.
- `viewPageEnded(title:url:)`
  - This event is triggered when the user exits a page or screen previously recorded by a Page View event.
    A Page View Ended event should be generated as each page is exited.
- `chatWindowOpen()`
  - This event is triggered when a specific chat screen (conversation) is opened.
  - Correct reporting of this event is required for a welcome message automation.
- `conversion(type:value:)`
  - This event tracks instances where a user was redirected from other media (link, etc.), made a purchase, or read an article.
    Anything your company has internally defined as a conversion.
- `proactiveActionDisplay(data:)`
  - This event is associated with the `onProactivePopupAction(data:actionId:)` delegate method.
- `proactiveActionClick(data:)`
  - This event is associated with the `onProactivePopupAction(data:actionId:)` delegate method.
- `proactiveActionSuccess(_:data:)`
  - This event is associated with the `onProactivePopupAction(data:actionId:)` delegate method.
- `customVisitorEvent(data:)`
  - This event is used to track any custom event you would like to monitor.

> Important: The SDK is using state-based architecture and the methods have to be called when the SDK is in correct state. Otherwise, invoked method throws an `illegalChatState` error.

It is important that the integrating application uses the analytical methods correctly, i.e. in the right place and in the right order.

```swift
    func onAppear() {
        ...
        
        do {
            ...

            Task {
                LogManager.trace("Reporting chat window open event")
                
                try await chatProvider.analytics.chatWindowOpen()
            }
        }
    }
```


## Tracking Customer Flow

vents `viewPage(title:url:)` and `viewPageEnded(title:url:)` can help you with tracing customer visit within your application. With correct usage of `viewPage` and `viewPageEnded`, you know exactly how long does the user spent on the specific screen.

> Important: Integrator must handle entering background on its own, the SDK does not handle this behavior. Implement method `willEnterBackground()` with `viewPageEnded`. `viewWillAppear` for `UIViewController` or `onAppear` for SwiftUI should be sufficient for appearing from different screen and even entering foreground.

> Important: Thread list, chat transcript, etc. should not be generating page view events. For tracing chatting with the agent, the SDK includes the `chatWindowOpen()` method.
