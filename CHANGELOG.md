<a name="1.3.1"></a>
## [1.3.1] - 2024-03-12

### Features
- Privacy Manifest

<a name="1.3.0"></a>
## [1.3.0] - 2024-03-12

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
### Features
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

<a name="1.2.0"></a>
## [1.2.0] - 2023-09-22

### Bug Fixes
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
### Features
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

<a name="1.1.1"></a>
## [1.1.1] - 2023-07-10

### Features
- Update decoding of ThreadRecoveredEvent

<a name="1.1.0"></a>
## [1.1.0] - 2023-06-23

### Bug Fixes
- Remove not supported fields in ReceivedThreadRecoveredPostbackData
- Return message with attachments
- use correct EventDataType for loadThreadData and messageSeenByCustomer
- dont clear keychain with disconnect
- working action for Changelog
- use Docker image for changelog GitHub action
- use correct UUID for thread
- access file stored in Documents
### Features
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

<a name="1.0.1"></a>
## [1.0.1] - 2023-03-14

### Features
- notify about close connection

<a name="1.0.0"></a>
## 1.0.0 - 2023-01-31

### Features
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

[Unreleased]: https://github.com/BrandEmbassy/cxone-mobile-sdk-ios/compare/1.3.1...HEAD
[1.3.1]: https://github.com/BrandEmbassy/cxone-mobile-sdk-ios/compare/1.3.0...1.3.1
[1.3.0]: https://github.com/BrandEmbassy/cxone-mobile-sdk-ios/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/BrandEmbassy/cxone-mobile-sdk-ios/compare/1.1.1...1.2.0
[1.1.1]: https://github.com/BrandEmbassy/cxone-mobile-sdk-ios/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/BrandEmbassy/cxone-mobile-sdk-ios/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/BrandEmbassy/cxone-mobile-sdk-ios/compare/1.0.0...1.0.1
