# Case Study: Analytics

Analytics is a useful and powerful feature. However, it needs to have set-up rules on your backend. iOS SDK provides several methods for tracking customer in the application:

- `viewPage(title:url:)`
- `viewPageEnded(title:url:)`
- `chatWindowOpen()`
- `conversion(type:value:)`
- `proactiveActionDisplay(data:)`
- `proactiveActionClick(data:)`
- `proactiveActionSuccess(_:,data:)`
- `customVisitorEvent(data:)`

> Important: As our product follows the framework design rules, the public API also includes a `visit()` method that should no longer be called, as this logic has been moved as part of the internal flow when connecting to the server via a web socket.

It is important that the integrating application uses the analytical methods correctly, i.e. in the right place and in the right order.

## Tracking Customer Flow
Events `viewPage(title:url:)` and `viewPageEnded(title:url:)` can help you with tracking customer visits within your application. Also, these events store timestamps and with `viewPageEnded`, you know exactly how long the user spends on specific screens.

> Important: Integrator must handle entering background on its own, the SDK does not handle this behavior. Implement method `willEnterBackground()` with `viewPageEnded`. `viewWillAppear` for `UIViewController` or `onAppear` for SwiftUI should be sufficient for appearing from different screen and even entering foreground.

> Important: Thread list, chat transcript, etc. should not be generating page view events. For tracing chatting with the agent, the SDK includes the `chatWindowOpen()` method.
