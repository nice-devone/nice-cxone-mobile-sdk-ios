# Case Study: Custom Fields

## Overview

CXone Mobile SDK provides the capability to handle custom fields for both conversations (contact/case custom fields) and customers (customer custom fields). Custom fields allow you to enrich your chat experience with additional data and enable deeper integration with your business processes.

> **Note:** This guide focuses on implementations using the core SDK module. Developers using the pre-built UI module will have many of these features handled automatically.

## Key Concepts

The SDK supports two types of custom fields:

- **Contact Custom Fields**: Associated with a specific conversation thread
- **Customer Custom Fields**: Associated with a customer across all their conversations

Each type of custom field is accessed through a different provider:

- `ContactCustomFieldsProvider`: Available via `CXoneChat.shared.threads.customFields`
- `CustomerCustomFieldsProvider`: Available directly via `CXoneChat.shared.customerCustomFields`

## Implementation Steps

### 1. Working with Contact Custom Fields

Contact custom fields are specific to individual conversation threads:

```swift
// Get custom fields for a specific thread
let threadId = UUID() // Your thread ID
let contactFields = CXoneChat.shared.threads.customFields.get(for: threadId)

// Set custom fields for a specific thread
let newContactFields = [
    "orderNumber": "12345",
    "department": "support"
]

Task {
    do {
        try await CXoneChat.shared.threads.customFields.set(newContactFields, for: threadId)
    } catch {
        // Handle error
    }
}
```

### 2. Working with Customer Custom Fields

Customer custom fields are associated with the customer across all conversations:

```swift
// Get customer custom fields
let customerFields = CXoneChat.shared.customerCustomFields.get()

// Set customer custom fields
let newCustomerFields = [
    "customerType": "premium",
    "accountNumber": "A98765"
]

Task {
    do {
        try await CXoneChat.shared.customerCustomFields.set(newCustomerFields)
    } catch {
        // Handle error
    }
}
```

### 3. Handling Pre-Chat Surveys

Pre-chat surveys are forms that collect custom field values before a conversation starts:

```swift
// Check if pre-chat survey is required
if let preChatSurvey = CXoneChat.shared.threads.preChatSurvey {
    // Display pre-chat form to collect required information
    // preChatSurvey.name contains the form title
    // preChatSurvey.customFields contains field definitions
    
    // After collecting values from the user:
    let customFields = [
        "firstName": "John",
        "lastName": "Smith",
        "email": "john.smith@example.com"
    ]
    
    // Create thread with pre-chat survey fields
    Task {
        do {
            let threadProvider = try await CXoneChat.shared.threads.create(with: customFields)
            // Continue with the created thread
        } catch {
            // Handle error (e.g., CXoneChatError.missingPreChatCustomFields)
        }
    }
} else {
    // No pre-chat survey required, create thread normally
    // ...
}
```

## Understanding Custom Field Types

The SDK supports three types of custom field inputs:

1. **Text Fields**: Simple text input (may include email validation)
2. **Selectors**: Dropdown selection from predefined options
3. **Hierarchical**: Multi-level selection (e.g., categories and subcategories)

Each field can be marked as `isRequired`, which means it must be filled in before a thread can be created.

## Best Practices

1. **Respect Field Definitions**: Only set custom fields that are defined in your channel configuration
2. **Validate Required Fields**: Ensure all required fields have values before creating a thread
3. **Handle Validation Errors**: Create appropriate UI feedback for validation failures
4. **Enable Logging**: Configure the SDK logger to catch custom field validation issues

```swift
CXoneChat.shared.configureLogger(level: .warning, verbosity: .verbose)
```

## Sample Code

For a complete implementation example, refer to the [Sample application](https://github.com/nice-devone/nice-cxone-mobile-sample-ios) which demonstrates handling both contact and customer custom fields.

## Related Resources

- [Single Thread Chat](cs-single-thread.md)
- [Multi Thread Chat](cs-multi-thread.md)
- [Rich Content Messages](cs-rich-content-messages.md)
