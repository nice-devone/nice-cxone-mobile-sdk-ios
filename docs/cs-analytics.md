# Case Study: Analytics

> **Quick Overview**: The SDK provides rich analytics capabilities to track user interactions, page views, and conversions. These events can trigger automations through CXone's WorkFlow Automation (WFA) system.

## What are Analytics Events?

Analytics events allow you to track the customer's journey through your application. In the CXone Mobile SDK, analytics events:

1. Can work even when the chat is in offline mode
2. Help trigger automations through WorkFlow Automation
3. Provide insights into user behavior and engagement
4. Track important business metrics like conversions

## Key Analytics Events

The SDK provides the following analytics events via `chatProvider.analytics`:

| Method | Description | Use Case |
|--------|-------------|----------|
| `viewPage(title:url:)` | Records when a user visits a page/screen | Track navigation paths |
| `viewPageEnded(title:url:)` | Records when a user exits a page/screen | Measure time spent on pages |
| `chatWindowOpen()` | Records when chat UI is displayed | Trigger welcome messages |
| `conversion(type:value:)` | Records business conversion events | Track purchases, signups |
| `proactiveActionDisplay(data:)` | Records when proactive UI is shown | Measure impression rates |
| `proactiveActionClick(data:)` | Records when proactive UI is clicked | Measure click-through rates |
| `proactiveActionSuccess(_:data:)` | Records if proactive action converted | Track effectiveness |

> **Important**: Analytics methods require the SDK to be at least in the `.prepared` state. Methods will throw an `illegalChatState` error if called in an invalid state.

## Implementation Examples

### Page View Tracking

To properly track page views, implement both `viewPage` and `viewPageEnded`:

```swift
class ProductScreenViewModel {
    let analyticsTitle = "product_detail"
    let analyticsUrl = "/products/12345"
    
    func onAppear() {
        Task {
            do {
                // Report page view when screen appears
                try await chatProvider.analytics.viewPage(
                    title: analyticsTitle, 
                    url: analyticsUrl
                )
            } catch {
                print("Analytics error: \(error)")
            }
        }
    }
    
    func onDisappear() {
        Task {
            do {
                // Report page exit when screen disappears
                try await chatProvider.analytics.viewPageEnded(
                    title: analyticsTitle,
                    url: analyticsUrl
                )
            } catch {
                print("Analytics error: \(error)")
            }
        }
    }
}
```

### App State Handling

Ensure proper tracking when your app enters background/foreground:

```swift
class AnalyticsManager {
    private var currentPageTitle: String?
    private var currentPageUrl: String?
    
    init() {
        // Register for app state notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    func setCurrentPage(title: String, url: String) {
        currentPageTitle = title
        currentPageUrl = url
        
        Task {
            do {
                try await chatProvider.analytics.viewPage(title: title, url: url)
            } catch {
                print("Analytics error: \(error)")
            }
        }
    }
    
    @objc func appDidEnterBackground() {
        guard let title = currentPageTitle, let url = currentPageUrl else { return }
        
        Task {
            do {
                try await chatProvider.analytics.viewPageEnded(title: title, url: url)
            } catch {
                print("Analytics error: \(error)")
            }
        }
    }
    
    @objc func appWillEnterForeground() {
        guard let title = currentPageTitle, let url = currentPageUrl else { return }
        
        Task {
            do {
                try await chatProvider.analytics.viewPage(title: title, url: url)
            } catch {
                print("Analytics error: \(error)")
            }
        }
    }
}
```

### Chat Window Opening

Track when users open the chat interface:

```swift
func showChatUI() {
    Task {
        do {
            // Report chat window opening
            try await chatProvider.analytics.chatWindowOpen()
            
            // Present chat UI
            chatCoordinator.start(
                threadId: nil,
                in: self,
                presentModally: true
            )
        } catch {
            print("Error reporting chat window open: \(error)")
        }
    }
}
```

### Tracking Conversions

Record business-critical events:

```swift
func completePurchase(orderId: String, amount: Double) {
    Task {
        do {
            // Record a purchase conversion
            try await chatProvider.analytics.conversion(
                type: "purchase", 
                value: amount
            )
            
            // Show confirmation
            showConfirmationScreen(orderId: orderId)
        } catch {
            print("Error recording conversion: \(error)")
        }
    }
}
```


## Getting the Visitor ID

To access the unique visitor identifier:

```swift
func getVisitorIdentifier() -> String? {
    return chatProvider.analytics.visitorId
}
```

## Best Practices

1. **State Management**
   - Call analytics methods only after the SDK is prepared
   - Handle errors properly (most common: `illegalChatState`)

2. **Accurate Page Tracking**
   - Always pair `viewPage` with `viewPageEnded`
   - Handle app background/foreground transitions
   - Use consistent title/URL pairs

3. **Don't Track Chat UI Pages**
   - The SDK's internal screens (thread list, chat transcript) should not generate page view events
   - Use `chatWindowOpen()` for tracking chat engagement

4. **Thread Safety**
   - All analytics calls are asynchronous (use `await`)
   - Always wrap in `Task` blocks

5. **When to Report**
   - Page views: `onAppear`/`viewDidAppear` and `onDisappear`/`viewDidDisappear`
   - Chat window: before showing chat UI
   - Conversions: after successful action completion

## WorkFlow Automation Integration

Analytics events can trigger automations in CXone:

1. **Welcome Messages**: Triggered by `chatWindowOpen()` event
2. **Targeted Offers**: Based on page view patterns
3. **Proactive Chat**: Triggered by specific visitor events
4. **Re-engagement**: Based on conversion patterns

## Sample Implementation

For a complete implementation reference, see the [Sample Application's AnalyticsReporter](https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/Sources/Utilities/Manager/AnalyticsReporter.swift).
