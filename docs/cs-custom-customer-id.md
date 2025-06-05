# Case Study: Custom Customer ID

> **Security Warning**: While the CXone SDK supports custom customer IDs, this is considered an **insecure** identity management solution. It's strongly recommended to use an OAuth provider instead. If OAuth isn't available, generate a unique identifier with a very low chance of being guessed, and store it securely in your application (the SDK itself uses Keychain storage).

## What is Custom Customer ID?

The CXone SDK allows you to define your own unique customer identifier instead of letting the SDK generate one automatically. This functionality enables your application to:

1. Maintain a consistent user identity across multiple devices
2. Tie conversations to your existing user identification system
3. Provide a seamless experience for returning users

## When to Use Custom Customer IDs

Custom customer IDs are appropriate when:

- You need to associate chat conversations with your existing user database
- You want consistent identification across multiple devices for the same user
- You have a secure, unique identifier for users that you want to reuse

## Implementation

### Setting a Custom Customer ID

To set a custom customer ID, call the following method **before** initializing the CXone SDK to the `.prepared` state:

```swift
// Must be called before prepare()
try CXoneChat.shared.customer.set(
    customer: CustomerIdentity(
        id: yourUniqueCustomerId,
        firstName: userFirstName,  // Optional
        lastName: userLastName     // Optional
    )
)

// Then prepare the SDK
try await CXoneChat.shared.connection.prepare(
    environment: yourEnvironment,
    brandId: yourBrandId,
    channelId: yourChannelId
)
```

### Implementation Sequence

The correct sequence for implementing custom customer IDs is:

1. Get or create your unique customer ID
2. Call `customer.set()` with your ID
3. Call `connection.prepare()` to initialize the SDK
4. Proceed with chat functionality

### Complete Example

Here's a complete example showing how to implement custom customer ID:

```swift
class ChatManager {
    private let secureStorage: SecureStorage
    
    init(secureStorage: SecureStorage) {
        self.secureStorage = secureStorage
    }
    
    func initializeChat() async throws {
        // 1. Get customer ID (either from secure storage or create new one)
        let customerId = secureStorage.retrieveCustomerId() ?? UUID().uuidString
        
        // If this is a new ID, save it securely
        if secureStorage.retrieveCustomerId() == nil {
            secureStorage.storeCustomerId(customerId)
        }
        
        // 2. Set the customer ID in the SDK
        try CXoneChat.shared.customer.set(customer: CustomerIdentity(
            id: customerId,
            firstName: secureStorage.retrieveFirstName(),
            lastName: secureStorage.retrieveLastName()
        ))
        
        // 3. Initialize the SDK
        try await CXoneChat.shared.connection.prepare(
            environment: .NA1,
            brandId: 12345,
            channelId: "your_channel_id"
        )
        
        // 4. Now you can show chat or perform other operations
    }
}
```

## Security Considerations

If you choose to use custom customer IDs, follow these security practices:

1. **Use High-Entropy IDs**: Generate IDs with sufficient randomness (like UUIDs)
2. **Secure Storage**: Store IDs in secure storage like the Keychain
3. **Authentication**: Tie customer IDs to authenticated users when possible
4. **Don't Use Predictable IDs**: Never use sequential numbers, usernames, or emails as IDs
5. **Consider OAuth**: When available, OAuth is the most secure approach

## Error Handling

The `set(customer:)` method will throw an `illegalChatState` error if called after the SDK has been initialized. Always call it before `prepare()`.

```swift
do {
    try CXoneChat.shared.customer.set(customer: yourCustomerIdentity)
} catch CXoneChatError.illegalChatState {
    // Handle the error - you're trying to set the ID too late
} catch {
    // Handle other potential errors
}
```

## Related Topics

- [OAuth Integration](cs-oauth.md): The recommended approach for secure customer identity management
- [Live Chat](cs-livechat.md): Using custom customer IDs with live chat
- [Multi-Thread Chat](cs-multi-thread.md): How custom IDs affect thread management

## Best Practices

1. **Set Early**: Always set custom IDs before calling `prepare()`
2. **Store Securely**: Use Keychain or other secure storage for IDs
3. **Include Names**: When available, provide first and last names for better agent experience
4. **Consistent IDs**: Use the same ID across sessions for the same user
5. **Error Handling**: Properly handle any errors during the setting process
