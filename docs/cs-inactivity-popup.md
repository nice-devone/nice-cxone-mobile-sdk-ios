# Case Study: Inactivity Popup

> **Quick Start**: The inactivity popup feature automatically detects when users are inactive during a live chat session and presents them with options to continue or close the session. This provides a better user experience. **Note**: This feature is only available for live chat channels, not messaging.

## What is the Inactivity Popup?

The inactivity popup is a proactive feature that:

- **Monitors user activity** during live chat sessions
- **Automatically displays** a popup when inactivity is detected
- **Gives users choices** to continue or close their session
- **Works with live chat only** (not available for messaging channels)

## How It Works

1. **Server Detection**: The backend monitors user activity and sends inactivity popup events
2. **SDK Processing**: The SDK receives these events and creates `InactivityPopup` objects
3. **UI Display**: The popup is shown to the user (backend handles timing and expiration)
4. **User Response**: User chooses to continue or close the session
5. **Backend Update**: The SDK sends the user's choice to the server

**Important**: The backend automatically handles session timing and expiration. The frontend only needs to display the popup and handle user interactions.

**Channel Limitation**: This feature only works with live chat channels. Messaging channels do not support inactivity popups.

## Prerequisites

Before using this feature, ensure that:

1. **Portal Configuration**: Inactivity popups must be enabled and configured in the CXone web portal/admin interface
2. **Live Chat Channel**: Your channel must be configured for live chat
3. **SDK Connection**: Your app must be connected to the CXone service

**Note**: No code changes or server API calls are needed to enable this feature - it's purely a web portal configuration.

## Integration Options

### Option 1: Use the UI Module (Recommended)

If you're already using the UI module (ChatCoordinator), **the inactivity popup feature works automatically with no additional setup required**.

**No extra code needed!** If your app already has:

```swift
let chatCoordinator = ChatCoordinator()
chatCoordinator.start(threadId: nil, in: self, presentModally: true)
```

Then the inactivity popup feature is **already working**. The UI module automatically:
- Receives inactivity popup events internally
- Shows the popup with proper styling
- Manages user interactions
- Sends responses to the server
- Handles session management

**Note**: You do NOT need to implement `CXoneChatDelegate` or add any additional code when using the UI module - it handles everything internally.

### Option 2: Custom UI Implementation

If you want to create your own UI, you'll need to handle the popup display and user interactions manually:

#### Step 1: Handle the Popup Event

```swift
extension YourViewController: CXoneChatDelegate {
    
    func onProactiveActionReceived(of type: ProactiveActionType) {
        switch action {
        case .inactivityPopup(let popup):
            // Show your custom popup UI
            showCustomInactivityPopup(popup)
        case .customPopupBox:
            ...
        }
    }
}
```

#### Step 2: Create Your Custom Popup UI

**Example using UIAlertController** (you can implement any custom UI approach):

```swift
func showInactivityPopup(_ popup: InactivityPopup) {
    ...
}
```

#### Step 3: Handle User Response

```swift
func handleInactivityPopupResponse(continueSession: Bool, popup: InactivityPopup) {
    Task {
        do {
            if continueSession {
                // User chose to continue
                try await CXoneChat.shared.proactiveAction.trigger(.refreshSession(popup))
            } else {
                // User chose to close
                try await CXoneChat.shared.proactiveAction.trigger(.expireSession(popup))
            }
        } catch {
            print("Failed to handle inactivity popup response: \(error)")
        }
    }
}
```

## Common Scenarios

### Scenario 1: User Continues Session

```swift
// User taps "Continue Session"
try await CXoneChat.shared.proactiveAction.trigger(.refreshSession(popup))
// Session continues normally
```

### Scenario 2: User Closes Session

```swift
// User taps "Close Session"  
try await CXoneChat.shared.proactiveAction.trigger(.expireSession(popup))
```

## Troubleshooting

### Popup Not Showing?

**For UI Module users:**
1. **Verify connection**: Make sure the SDK is connected
2. **Check portal configuration**: Inactivity popup must be enabled in the CXone web portal
3. **Check chat setup**: Ensure ChatCoordinator is properly initialized

**For Custom UI implementation:**
1. **Check delegate implementation**: Ensure `onProactiveActionReceived` is implemented
2. **Verify connection**: Make sure the SDK is connected  
3. **Check portal configuration**: Inactivity popup must be enabled in the CXone web portal

### Response Not Sending? (Custom UI only)

1. **Check network connection**: Ensure the device has internet access
2. **Verify thread state**: The thread must be in a valid state
3. **Check error handling**: Look for error messages in the console

### UI Not Updating? (Custom UI only)

1. **Check main thread**: Ensure UI updates happen on the main thread
2. **Verify state management**: Make sure your UI state is properly managed
3. **Check delegate calls**: Ensure the delegate method is being called

## Summary

The inactivity popup feature provides a robust way to manage user sessions. The UI module handles all complexity automatically with no additional code required. You can also implement custom UI if you prefer full control over the user experience.

For most integrators, using the UI module is the recommended approach as it handles edge cases automatically and provides a consistent user experience.

## Sample Implementation

For a complete implementation reference, see:

- [Sample Application](https://github.com/nice-devone/nice-cxone-mobile-sample-ios)
- [UI Module](https://github.com/nice-devone/nice-cxone-mobile-ui-ios)

