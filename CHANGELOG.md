<a name="3.0.0"></a>
# [3.0.0] - 2025-06-04

## Breaking Changes
- Message's SenderInfo is optional due to possible automated messages without sender identity (e.g. Welcome Message)
- SenderInfo attributes `firstName`, `lastName` and `fullName` are optional 

## Features
- Add ChatConfiguration to be able to add additional configuration to the CXoneChatSDK
- Integrate CXoneGuideUtility

## Fixes
- Fix thread state persistence to prevent closed threads from incorrectly changing back to ready state after receiving messages or assignee changes.
- Fix OAuth connection flow


<a name="2.3.2"></a>
# [2.3.2] - 2025-05-19

## Fixes
- Fix OAuth connection flow


<a name="2.3.1"></a>
# [2.3.1] - 2025-04-11

## Fixes
- Add chat URLSession instance instead of URLSession.shared one


<a name="2.3.0"></a>
# [2.3.0] - 2025-02-12

## Features
- Add logging for URLSession responses
- Enhanced SDK create(with:) method to support custom fields with prechat validation and additional contact field storage

## Fixes
- Increased timeout duration again to match with Android's setting.
- A copy of the thread is no longer delegated by `sendMessage(_:for:)` method


<a name="2.2.1"></a>
# [2.2.1] - 2024-12-06

## Fixes
- Set customer custom fields correctly for Livechat mode


<a name="2.2.0"></a>
# [2.2.0] - 2024-11-04

## Features
- Enhance AuthorizeCustomer of new attributes
- Map actual agent image URL to Agent's imageUrl
- Hide `inContactId` from Agent
- Expanded Unit Testing
- Deprecate `inContactId`, `loginUsername` and `emailAddress` for an Agent object
- Improve handling of archiveThread
- Added additional HTTP headers for `URLRequest`
- Deprecate CXoneChat.delegate in favor of CXoneChat.add/remove(delegate:)
- Change `set(_:)` to `set(customer:)` in CustomerProvider
- Deprecate `CXoneChatDelegate.onAgentTyping(_:threadId:)` in favor of `CXoneChatDelegate.onAgentTyping(_:agent:threadId:)`

## Fixes
- Increased the timeout duration for the server response during the ping/pong checks.
- Handle properly chat states after connect and when thread recover fails
- Handle disconnect based on expectation state (disconnect triggered by host application vs. disconnect due to websocket pong not received)


<a name="2.1.0"></a>
# [2.1.0] - 2024-07-29

## Features
- Custom Customer ID
- Remove custom field definitions validation
- Update minimum iOS deployment target to 15

## Fixes
- Prefill prechat survey with customer data
- correct check for locally created thread
- "properly" handle start/stopSecurelyScopedResource
- Working Live chat set position in queue

## Chore
- Change version to 2.1.0
- Resolve SwiftLint warnings


<a name="2.0.1"></a>
# [2.0.1] - 2024-07-11

## Bug Fixes
- Correct live chat set position in queue


<a name="2.0.0"></a>
# [2.0.0] - 2024-05-22

## Features
- Better welcome message handling
- Disable modification for archived thread
- Add localized strings to sdk package
- implement file restrictions parsing and publication
- update DeviceFingerprint with new expectations from web team
- Add Live chat mode
- Deprecate legacy plugins
- Attachments validation in the SDK
- Attachments Restrictions - file type
- Handle sent message via `onThreadUpdated(_:)`
- Privacy Manifest
- Implement Feature Toggles
- Create SDK's UserDefaults + Better Keychain handling
- Process large events from S3

## Bug Fixes
- Update ListFieldView behavior for iOS 14
- Exclude links from multiattachments view
- correct check for locally created thread
- Rotation bug on iOS15
- Incorrect attachment size displayed for single attachment
- append UTType.movie for all videos
- remove validation for Prechat survey
- Fix installation of SwiftGen with homebrew disabling swiftgen
- Fix Build/test break
- "properly" handle start/stopSecurelyScopedResource


<a name="1.3.3"></a>
# [1.3.3] - 2024-05-15

## Bug Fixes
- make assignedAgent optional for the event


<a name="1.3.2"></a>
# [1.3.2] - 2024-03-21

## Features
- Create SDK's UserDefaults + Better Keychain handling


<a name="1.3.1"></a>
# [1.3.1] - 2024-03-12

## Features
- Privacy Manifest


<a name="1.3.0"></a>
# [1.3.0] - 2024-03-12

## Features
- add login error state in case of unreachable API
- Add basic validation for brandId and channelId
- Login with Amazon SDK update + fixed Launch screen storyboard
- Trigger Analytics events with correct createdAt format
- Create tag with deploy to TestFlight
- Add GitHub action for generating IPA
- Deploy to TestFlight
- change open Chat button background color
- Re-write ThreadList from UIKit to SwiftUI
- Implementation of UI Module
- Add License
- Add section how to run Sample Application
- Integrate Crashlytics
- Enhance SDK Architecture
- Correct handling of welcome message

### Bug Fixes
- Fixed deeplink format
- Correct CreateOrUpdateVisitor URL
- Resolve issue with submodules for GitHub Actions
- working Login preview
- checkout submodules for Deploy to TestFlight GH action
- Bottom offset for older devices
- Don't create customer with setting name
- duplicate SFSymbol image to SwiftUI + remove conversion from UIImage to Image
- Fix installation of SwiftGen with homebrew disabling swiftgen
- Correct API call in onAppear + adjust logging
- Handle RecoverThreadFailedEvent internally + prevent from archiving not yet existing thread
- Correct path for publishing build to TestFlight
- Working Remote Notifications
- Remove reporting viewPage for chat related
- Archive sample app for TestFlight GH Action
- edit configuration for archiving app
- Correct title when enter thread detail
- Fixed problem in hexString where wrong color was being created.
- fix UI issues related to iOS14
- Fix Deploy to TestFlight action
- Handle different thread correctly
- Fix issue when multiple messages with matching ids are received


<a name="1.2.0"></a>
# [1.2.0] - 2023-09-22

## Features
- change open Chat button background color
- Login with Amazon SDK update + fixed Launch screen storyboard
- Update version to 1.2.0
- remove deprecated API + rename uri to url in the rest of the project
- Event Type Unification
- Add basic validation for brandId and channelId
- Connect Chat flow from Store
- Use web-analytics for analytics events
- Add case studies + change jazzy output file
- Remote Push Notifications Manager
- Implement E-shop
- Create or Update Visitor via REST API
- Update decoding of ThreadRecoveredEvent
- Implement pageViewEnded
- Analytics Usage in E-shop

## Bug Fixes
- working Login preview
- Remove reporting viewPage for chat related
- duplicate SFSymbol image to SwiftUI + remove conversion from UIImage to Image
- Bottom offset for older devices
- Working Remote Notifications
- Correct API call in onAppear + adjust logging
- Analytics Provider Error Handling + Connect in Login
- Cart and ProductDetail summary backgroundColor
- Replaced usage of keychain with UserDefaults
- Setting image as brand logo not working as expected
- Fixed issue where SettingsView was crashing
- Correct title when enter thread detail
- Fixed problem in hexString where wrong color was being created.


<a name="1.1.1"></a>
# [1.1.1] - 2023-07-10

## Features
- Update decoding of ThreadRecoveredEvent


<a name="1.1.0"></a>
# [1.1.0] - 2023-06-23

## Features
- SwiftLint explicit init
- Event Type Unification
- use Codable only in valid cases + Encodable in test target
- Dependencies version update
- Message send returns Message model
- Dynamic Pre-chat Survey
- Implementation of the quick replies message type
- Implement List Picker and update previous rich message type
- Implementation of the rich link message type
- notify about close connection
- Postback for plugin messages
- Fresh Event Naming
- Add case studies + change jazzy output file

## Bug Fixes
- Remove not supported fields in ReceivedThreadRecoveredPostbackData
- Return message with attachments
- use correct EventDataType for loadThreadData and messageSeenByCustomer
- dont clear keychain with disconnect
- working action for Changelog
- use Docker image for changelog GitHub action
- use correct UUID for thread
- access file stored in Documents


<a name="1.0.1"></a>
# [1.0.1] - 2023-03-14

## Features
- notify about close connection


<a name="1.0.0"></a>
# 1.0.0 - 2023-01-31

## Features
- Logging PoC
- Error handling
- Connection
  - Ping to ensure connection state
  - Execute trigger manually
  - Handle unexpected disconnect
- Customer
  - Save customer credentials
  - Customer authorisation
  - Customer reconnect
  - OAuth
- Customer Custom Fields
  - Save customer custom fields
- Threads
  - Update thread name
  - „Read“ flag
  - „Delivered“ flag
  - Threads load
  - Contact inbox assignee change
  - Recover thread
  - Typing indicator
  - Archive thread
  - Load thread metadada
  - Handle proactive action
    - Welcome message
    - Custom popup box
- Contact Custom Fields
  - Save contact custom fields
- Messages
  - Send/Receive attachments
    - Image
    - Video
    - Documents
  - Handle a message
    - Text
    - Plugin
      - Gallery
      - Menu
      - Text and Buttons
      - Quick Replies
      - Satisfaction Survey
      - Custom
      - Sub Elements
        - Text
        - Title
        - File
        - Button/iFrame Button
  - Previous message load
- Analytics
  - Page view
  - Chat window open
  - App visit
  - Conversion
  - Custom visitor event
  - Proactive action
    - display
    - success
    - failure
  - typing start/end

[Unreleased]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/3.0.0...HEAD
[3.0.0]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/2.3.0...3.0.0
[2.3.0]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/2.2.1...2.3.0
[2.2.1]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/2.2.0...2.2.1
[2.2.0]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/2.0.1...2.1.0
[2.0.1]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/1.3.3...2.0.0
[1.3.3]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/1.3.2...1.3.3
[1.3.2]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/1.3.1...1.3.2
[1.3.1]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/1.3.0...1.3.1
[1.3.0]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/1.1.1...1.2.0
[1.1.1]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/compare/1.0.0...1.0.1
