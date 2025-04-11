# Case Study: Rich Content Messages

In addition to sending and receiving classic text messages or attachments—which can include visual forms like audio files displayed with an audio player—the SDK supports content-rich messages. This enables a Truly Omnichannel Rich Messaging (TORM) approach.More information about Rich content messages can be found in the [CXone documentation](https://help.nice-incontact.com/content/acd/digital/channelfeatures/richmessagesettings.htm?tocpath=Digital%20Experience%7CDigital%20Experience%20%7C_____2).


## Types

- Rich Link
  - Message with a title, an image and a URL address. The link can be a deeplink or an ordinary url.
- Quick Replies
  - Message with a list of buttons. Only one action can be selected from the options provided, and once selected, it should be made inactive.
- List Picker
  - Message with title, body and list of buttons (possibly with images). Each action in the list can be selected multiple times.

- Sub Elements
  - Reply Button
    - Button with a text label and a postback value.

## Postback

When users interact with a content-rich message, it is necessary to provide the selected subelement's 'postback' value, if it exists. This is necessary because the user may be interacting with a chatbot that doesn't provide a content-rich response but instead responds with the mentioned 'postback' value.

> Warning: If you don't provide TORM sub-element `postback`, chat bot integration may not work correctly!

### Button

```swift
/// A reply button rich message sub element.
public struct MessageReplyButton {
    ...
    /// The postback of the button.
    ///
    /// Postback functionality should be used only for some extra automation processing (usually bots)
    /// in a way that the bot is not considering the content of the message but postback of the message
    /// where he can inject some better (more automatically readable) identifiers than what customer/agent
    /// can see in the UI as the content of the message.
    public let postback: String?
    ...
}
```

To send a message with postback, you can use a method `func send(_ message: OutboundMessage, for chatThread: ChatThread) async throws` available in `MessagesProvider`.

The sample application handles this via UI Module's `DefaultChatViewModel` with a custom `onRichMessageElementSelected(textToSend:element:)` method:
```swift
@MainActor
func onRichMessageElementSelected(textToSend: String?, element: RichMessageSubElementType) {
    LogManager.trace("Did select rich content message")
    
    ...
    
    if let textToSend {
        onSendMessage(.text(textToSend), attachments: [], postback: element.postback)
    }
}

...

@MainActor
func onSendMessage(_ messageType: ChatMessageType, attachments: [AttachmentItem], postback: String? = nil) {
    LogManager.trace("Sending a message")
      
    ...
    
    Task { @MainActor in
        do {
            ...
            try await CXoneChat.shared.threads.messages.send(message, for: thread)
            ...
        } catch {
            error.logError()
        }
    }
}
```

Full source code available [here](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/cxone-chat-ui/Sources/Presentation/Implementation/Default/Chat/DefaultChatViewModel.swift).
