# Case Study: Analytics

Analytics is a useful and powerful feature.  iOS SDK provides several methods for tracking the customers journey through the application:

- `viewPage(title:url:)`
- `viewPageEnded(title:url:)`
- `chatWindowOpen()`
- `conversion(type:value:)`
- `proactiveActionDisplay(data:)`
- `proactiveActionClick(data:)`
- `proactiveActionSuccess(_:data:)`
- `customVisitorEvent(data:)`

> Important: The SDK is using state-based architecture and the methods have to be called when the SDK is in correct state. Otherwise, invoked method throws an `illegalChatState` error.

It is important that the integrating application uses the analytical methods correctly, i.e. in the right place and in the right order.

## Tracking Customer Flow
vents `viewPage(title:url:)` and `viewPageEnded(title:url:)` can help you with tracing customer visit within your application. With correct usage of `viewPage` and `viewPageEnded`, you know exactly how long does the user spent on the specific screen.

> Important: Integrator must handle entering background on its own, the SDK does not handle this behavior. Implement method `willEnterBackground()` with `viewPageEnded`. `viewWillAppear` for `UIViewController` or `onAppear` for SwiftUI should be sufficient for appearing from different screen and even entering foreground.

> Important: Thread list, chat transcript, etc. should not be generating page view events. For tracing chatting with the agent, the SDK includes the `chatWindowOpen()` method.
