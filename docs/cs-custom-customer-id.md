# Case Study: Custom Customer ID

> Warning: Although this feature is supported by the CXone SDK, it is an **insecure** identity management solution and it is recommended to use an OAuth provider instead of manual management. If a provider cannot be used, it is recommended to use a generated unique identifier with a low chance of guessability for the identity value, which is then stored in a secure store in the host application (the SDK uses Keychain storage).

CXone provides the ability to define your own unique customer identifier. This functionality allows the host application to use the identity on multiple devices, as it does when using an OAuth provider. To set a custom customer ID, the following method must be called before initializing the CXone to the `.prepared` state, which is done using the `func prepare(environment: Environment, brandId: Int, channelId: String) async throws` method available within the ConnectionProvider.

```swift
func set(_ customer: CustomerIdentity?) throws
```

In the CXone chat sample application, you can find the usage example in the `ConfigurationViewModel`. The configuration scene of the sample application shows a text field where the customer ID can be set. If it is left empty, the SDK will generate the ID internally as usual.

```swift
func  onConfirmButtonTapped() {
    ...
    do {
        if !customerId.isEmpty {
            try CXoneChat.shared.customer.set(customer: CustomerIdentity(id: customerId, firstName: nil, lastName: nil))
        }

        navigateToLogin()
    } catch {
        ...
    }
}
```
