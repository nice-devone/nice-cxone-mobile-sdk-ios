# Case Study: Rich Content Messages

## Overview

The CXone Mobile SDK supports rich content messages in addition to standard text and file attachments. This enables a Truly Omnichannel Rich Messaging (TORM) approach, allowing for more engaging and interactive conversations with customers.

> **Note:** This guide focuses on implementations using the core SDK module. Developers using the pre-built UI module will have many of these features handled automatically.

## Key Concepts

Rich content messages come in several formats:

- **Rich Link**: Message with a title, image and URL that can be a deeplink or standard web URL
- **Quick Replies**: Message with a list of buttons where only one can be selected
- **List Picker**: Message with title, body and list of buttons (optionally with images) that can be selected multiple times

The SDK handles proper rendering of these message types and manages the interactions with them.

## Implementation Steps

### 1. Receiving Rich Content Messages

The SDK automatically processes incoming rich content messages, making them available through the standard message delegates:

```swift
func onThreadUpdated(_ chatThread: ChatThread) {
    // The SDK provides rich content messages through the standard delegate
    // Your UI layer should handle rendering these content types:
    // - .richLink(let content) - Rich links with title, image, and URL
    // - .quickReplies(let content) - Quick reply buttons (single selection)
    // - .listPicker(let content) - List picker with multiple options
    // - Standard message types (text, attachments, etc.)
    
    // Update your UI with the latest thread data
    ...
}
```

### 2. Handling Rich Message Interactions

When a user interacts with rich content (like clicking a button), you need to send the appropriate response:

```swift
// Handle button click in a rich message
func onRichMessageButtonTapped(button: MessageReplyButton) {
    guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.id) else {
        LogManager.error("Unexpected nil thread")
        return
    }
    
    // Create a message with the button's text and postback value
    let message = OutboundMessage(
        text: button.text,
        attachments: [],
        postback: button.postback
    )
    
    // Send the message through the thread provider
    Task {
        do {
            try await threadProvider.send(message)
        } catch {
            // Handle error
        }
    }
}
```

### 3. Understanding Postback Values

Postback values are critical for proper bot integration and automated workflows. When handling rich content interactions:

```swift
// Example rich message button structure
struct MessageReplyButton {
    let text: String
    let description: String?
    let postback: String?  // This must be included in your response
    let iconUrl: URL?
}
```

> **Warning:** If you don't include the postback value when responding to rich content interactions, chatbot integrations may not work correctly.

## Best Practices

1. **Always Include Postbacks**: Always send the postback value when responding to rich content interactions
2. **Proper Rendering**: Ensure your UI can properly render all supported rich content types
3. **Button States**: For Quick Replies, disable buttons after selection since they should only be used once
4. **Error Handling**: Handle scenarios where rich content can't be displayed properly

## Related Resources

- [Single Thread Chat](cs-single-thread.md)
- [Multi Thread Chat](cs-multi-thread.md)
- [Custom Fields](cs-custom-fields.md)
