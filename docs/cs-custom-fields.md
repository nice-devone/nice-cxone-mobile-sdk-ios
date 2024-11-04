# Case Study: Custom Fields

CXone provides the capability to define custom fields for both the chat itself as well as for the user. These can be identified in the mobile SDK as `caseCustomFields` and `customerCustomFields`. To get the actual custom fields the mobile SDK has separate providers - `CaseCustomFieldsProvider` and `CustomerCustomFieldsProvider`. The `CaseCustomFieldsProvider' depends on chat threads, so it can be found as a variable within the `ChatThreadsProvider'. On the other hand the `CustomerCustomFieldsProvider` represents generic custom fields for users and can therefore be found directly within `CXoneChat`.

> Important: When setting custom fields it is necessary to respect their definitions. The definitions are available as variables of the `channelConfiguration` object available in the `ConnectionProvider`. If an attempt is made to set a custom field that is not defined for the selected brand, it will be ignored from the CXone perspective.  If the requirements are not met, an error will be logged via ``LogDelegate.logError(_:)`` The error will be either `.unknownCaseCustomFields` or `.unknownCustomerCustomFields` depending on the provider of the definitions.

> Note: **Case** custom fields are custom fields associated with a single chat conversation/thread, whereas **Customer** custom fields are custom fields associated with a customer. This information is available for all conversations


## Static/Dynamic Custom Fields

Occasionally you may need to modify custom fields or add to existing ones to get the most detailed information before communicating with an agent or chat bot. In this case you can use i.e. pre-chat, which is a form that can contain custom fields that can be easily changed dynamically in the channel settings. As mentioned, this is a chat thread dependent object, so it is located in the `ChatThreadsProvider`. This form can have 3 types of user input - text field, list, or hierarchical. Definitions marked `isRequired` must have a corresponding value defined. In addition, text fields with `isEmail` set will be validated according to the CXone email address rules.

> Warning: If the channel configuration includes a dynamic pre-chat survey, it must be filled in before starting a thread. Otherwise the thread will not be created and the SDK will throw a `CXoneChatError.missingPreChatCustomFields` error in response to the `ChatThreadsProvider.create` method.

Since it is possible to change custom fields during the lifetime of a channel, they must always be validly populated. It is also possible that the definitions of these custom fields may change and the previously filled fields may no longer be valid or even exist. If an existing thread was created with a pre-chat form and that form has subsequently been changed, the SDK will only offer the custom fields that currently have definitions and the others will not be offered at all.


## Edit of Custom Fields

As well as being able to fill in custom fields before creating a chat thread to get the necessary information, it is also useful to edit these values if they have been filled in incorrectly. In this case, it is only possible to edit those custom fields for which definitions exist. Otherwise the values will be ignored and the SDK will log an error.

> Important: To see logged warnings/errors you need to configure the SDK logger. This can be done using the `configureLogger(level:verbosity:)` method available in `CXoneChat`.
