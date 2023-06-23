import XCTest
@testable import CXoneChatSDK


class MessagesContentTypeEncoderTests: XCTestCase {
    
    // MARK:  - Properties
    
    private let iso8601Formatter = ISO8601DateFormatter()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    
    // MARK: - ContentType Text
    
    func testContentTypeTextEncodeCorrectly() throws {
        guard let id = UUID(uuidString: "a91082b7-46f8-4d0d-af43-079994de98c6"),
              let threadId = UUID(uuidString: "AD342920-C75E-4B06-B973-00494CC811B7"),
              let createdAt = iso8601Formatter.date(from: "2022-03-15T17:54:50+0000")
        else {
            throw CXoneChatError.invalidData
        }
        
        let message = Message(
            id: id,
            threadId: threadId,
            contentType: .text(MessagePayload(text: "Hello world", postback: "/hello_world")),
            createdAt: createdAt,
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadStubFromBundle(withName: "MessageType/MessageTypeText", extension: "json")
        
        let decodedMessage = try decoder.decode(MessageDTO.self, from: encodedData)
        let expectationMessage = try decoder.decode(MessageDTO.self, from: expectationData)
        
        XCTAssertEqual(decodedMessage.idOnExternalPlatform, expectationMessage.idOnExternalPlatform)
        
        guard case .text(let decodedEntity) = decodedMessage.contentType, case .text(let expectationEntity) = expectationMessage.contentType else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedEntity, expectationEntity)
    }
    
    
    // MARK: - Content Type Rich Link
    
    func testContentTypeRichLinkEncodeCorrectly() throws {
        guard let id = UUID(uuidString: "a91082b7-46f8-4d0d-af43-079994de98c6"),
              let threadId = UUID(uuidString: "AD342920-C75E-4B06-B973-00494CC811B7"),
              let createdAt = iso8601Formatter.date(from: "2022-03-15T17:54:50+0000"),
              let url = URL(string: "https://www.google.com"),
              let fileUrl = URL(string: "https://placekitten.com/200/300")
        else {
            throw CXoneChatError.invalidData
        }
        
        let message = Message(
            id: id,
            threadId: threadId,
            contentType: .richLink(
                MessageRichLink(
                    title: "Check our new gadget!",
                    url: url,
                    fileName: "place-kitten.jpg",
                    fileUrl: fileUrl,
                    mimeType: "image/jpeg"
                )
            ),
            createdAt: createdAt,
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadStubFromBundle(withName: "RichMessages/MessageTypeRichLink", extension: "json")
        
        let decodedMessage = try decoder.decode(MessageDTO.self, from: encodedData)
        let expectationMessage = try decoder.decode(MessageDTO.self, from: expectationData)
        
        XCTAssertEqual(decodedMessage.idOnExternalPlatform, expectationMessage.idOnExternalPlatform)
        
        guard case .richLink(let decodedRichLink) = decodedMessage.contentType,
              case .richLink(let expectationRichLink) = expectationMessage.contentType
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedRichLink, expectationRichLink)
    }
    
    
    // MARK: - Content Type Quick Replies
    
    func testContentTypeQuickRepliesEncodeCorrectly() throws {
        guard let id = UUID(uuidString: "a91082b7-46f8-4d0d-af43-079994de98c6"),
              let threadId = UUID(uuidString: "AD342920-C75E-4B06-B973-00494CC811B7"),
              let createdAt = iso8601Formatter.date(from: "2022-03-15T17:54:50+0000")
        else {
            throw CXoneChatError.invalidData
        }
        
        let message = Message(
            id: id,
            threadId: threadId,
            contentType: .quickReplies(
                MessageQuickReplies(
                    title: "Hello, we will deliver the package between 12:00 and 16:00. Please specify which day.",
                    buttons: [
                        MessageReplyButton(text: "Today", postback: #"{"id":"1"}"#, description: nil, iconName: nil, iconUrl: nil, iconMimeType: nil),
                        MessageReplyButton(text: "Tomorrow", postback: #"{"id":"2"}"#, description: nil, iconName: nil, iconUrl: nil, iconMimeType: nil)
                    ]
                )
            ),
            createdAt: createdAt,
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadStubFromBundle(withName: "RichMessages/MessageTypeQuickReplies", extension: "json")
        
        let decodedMessage = try decoder.decode(MessageDTO.self, from: encodedData)
        let expectationMessage = try decoder.decode(MessageDTO.self, from: expectationData)
        
        XCTAssertEqual(decodedMessage.idOnExternalPlatform, expectationMessage.idOnExternalPlatform)
        
        guard case .quickReplies(let decodedQuickReplies) = decodedMessage.contentType,
              case .quickReplies(let expectationQuickReplies) = expectationMessage.contentType
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedQuickReplies, expectationQuickReplies)
    }
    
    
    // MARK: - Content Type List Picker
    
    func testContentTypeListPickerEncodeCorrectly() throws {
        guard let id = UUID(uuidString: "a91082b7-46f8-4d0d-af43-079994de98c6"),
              let threadId = UUID(uuidString: "AD342920-C75E-4B06-B973-00494CC811B7"),
              let createdAt = iso8601Formatter.date(from: "2022-03-15T17:54:50+0000")
        else {
            throw CXoneChatError.invalidData
        }
        
        let message = Message(
            id: id,
            threadId: threadId,
            contentType: .listPicker(
                MessageListPicker(
                    title: "Choose a color!",
                    text: "What is your favourite color?",
                    elements: [
                        .replyButton(
                            MessageReplyButton(
                                text: "red",
                                postback: "/red",
                                description: "Like a tomato",
                                iconName: "place-kitten.jpg",
                                iconUrl: URL(string: "https://placekitten.com/200/300"),
                                iconMimeType: "image/jpeg"
                            )
                        ),
                        .replyButton(
                            MessageReplyButton(
                                text: "green",
                                postback: "/green",
                                description: "Like an apple",
                                iconName: "place-kitten.jpg",
                                iconUrl: URL(string: "https://placekitten.com/200/300"),
                                iconMimeType: "image/jpeg"
                            )
                        )
                    ]
                )
            ),
            createdAt: createdAt,
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadStubFromBundle(withName: "RichMessages/MessageTypeListPicker", extension: "json")
        
        let decodedMessage = try decoder.decode(MessageDTO.self, from: encodedData)
        let expectationMessage = try decoder.decode(MessageDTO.self, from: expectationData)
        
        XCTAssertEqual(decodedMessage.idOnExternalPlatform, expectationMessage.idOnExternalPlatform)
        
        guard case .listPicker(let decodedListPicker) = decodedMessage.contentType,
              case .listPicker(let expectationListPicker) = expectationMessage.contentType
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedListPicker, expectationListPicker)
    }
    
    
    // MARK: - Content Type Plugin: Deeplink
    
    func testContentTypePluginDeeplinkEncodeCorrectly() throws {
        guard let id = UUID(uuidString: "a91082b7-46f8-4d0d-af43-079994de98c6"),
              let threadId = UUID(uuidString: "AD342920-C75E-4B06-B973-00494CC811B7"),
              let createdAt = iso8601Formatter.date(from: "2022-03-15T17:54:50+0000")
        else {
            throw CXoneChatError.invalidData
        }
        
        let message = Message(
            id: id,
            threadId: threadId,
            contentType: .plugin(
                MessagePlugin(
                    text: nil,
                    postback: "",
                    element: .subElements([
                        .button(
                            PluginMessageButton(
                                id: "Nkm0hRAiE",
                                text: "See this page",
                                postback: nil,
                                url: URL(string: "fb://profile/33138223345"),
                                displayInApp: false
                            )
                        )
                    ])
                )
            ),
            createdAt: createdAt,
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadStubFromBundle(withName: "MessageType/MessageTypePluginDeeplink", extension: "json")
        
        let decodedMessage = try decoder.decode(MessageDTO.self, from: encodedData)
        let expectationMessage = try decoder.decode(MessageDTO.self, from: expectationData)
        
        XCTAssertEqual(decodedMessage.idOnExternalPlatform, expectationMessage.idOnExternalPlatform)
        
        guard case .plugin(let decodedPlugin) = decodedMessage.contentType,
              case .subElements(let entities) = decodedPlugin.element,
              case .button(let decodedDeeplinkButton) = entities.first,
              case .plugin(let expectationPlugin) = expectationMessage.contentType,
              case .subElements(let entities) = expectationPlugin.element,
              case .button(let expectationDeeplinkButton) = entities.first
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedDeeplinkButton.id, expectationDeeplinkButton.id)
        XCTAssertEqual(decodedDeeplinkButton.text, expectationDeeplinkButton.text)
        XCTAssertEqual(decodedDeeplinkButton.url, expectationDeeplinkButton.url)
    }
    
    
    // MARK: - Content Type Plugin: Text And Buttons
    
    func testContentTypePluginTextAndButtonEncodeCorrectly() throws {
        guard let id = UUID(uuidString: "a91082b7-46f8-4d0d-af43-079994de98c6"),
              let threadId = UUID(uuidString: "AD342920-C75E-4B06-B973-00494CC811B7"),
              let createdAt = iso8601Formatter.date(from: "2022-03-15T17:54:50+0000")
        else {
            throw CXoneChatError.invalidData
        }
        
        let message = Message(
            id: id,
            threadId: threadId,
            contentType: .plugin(
                MessagePlugin(
                    text: nil,
                    postback: "",
                    element: .textAndButtons(
                        PluginMessageTextAndButtons(
                            id: "Ek4tPy1h4",
                            elements: [
                                .text(PluginMessageText(id: "Ek4tPy1h1", text: "Lorem Impsum...", mimeType: nil)),
                                .button(PluginMessageButton(
                                    id: "Nkm0hRAiE",
                                    text: "Click me!",
                                    postback: "click-on-button-1",
                                    url: nil,
                                    displayInApp: false)
                                ),
                                .button(PluginMessageButton(
                                    id: "NkGJ6CAiN",
                                    text: "No click me!",
                                    postback: "click-on-button-2",
                                    url: nil,
                                    displayInApp: false)
                                ),
                                .button(PluginMessageButton(
                                    id: "EyCyTRCi4",
                                    text: "Aww don`t click on me",
                                    postback: "click-on-button-2",
                                    url: nil,
                                    displayInApp: false)
                                )
                            ]
                        )
                    )
                )
            ),
            createdAt: createdAt,
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadStubFromBundle(withName: "MessageType/MessageTypePluginTextAndButtons", extension: "json")
        
        let decodedMessage = try decoder.decode(MessageDTO.self, from: encodedData)
        let expectationMessage = try decoder.decode(MessageDTO.self, from: expectationData)
        
        XCTAssertEqual(decodedMessage.idOnExternalPlatform, expectationMessage.idOnExternalPlatform)
        
        guard case .plugin(let decodedPlugin) = decodedMessage.contentType,
              case .textAndButtons(let decodedTextAndButtons) = decodedPlugin.element,
              case .plugin(let expectationPlugin) = expectationMessage.contentType,
              case .textAndButtons(let expectationTextAndButtons) = expectationPlugin.element
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedTextAndButtons.id, expectationTextAndButtons.id)
        XCTAssertEqual(decodedTextAndButtons.elements.count, expectationTextAndButtons.elements.count)
        
        guard case .button(let decodedButton) = decodedTextAndButtons.elements[1],
              case .button(let expectationButton) = expectationTextAndButtons.elements[1]
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedButton.id, expectationButton.id)
        XCTAssertEqual(decodedButton.postback, expectationButton.postback)
        XCTAssertEqual(decodedButton.text, expectationButton.text)
    }
    
    
    // MARK: - Content Type Plugin: Quick Replies
    
    func testContentTypePluginQuickRepliesEncodeCorrectly() throws {
        guard let id = UUID(uuidString: "a91082b7-46f8-4d0d-af43-079994de98c6"),
              let threadId = UUID(uuidString: "AD342920-C75E-4B06-B973-00494CC811B7"),
              let createdAt = iso8601Formatter.date(from: "2022-03-15T17:54:50+0000")
        else {
            throw CXoneChatError.invalidData
        }
        
        let message = Message(
            id: id,
            threadId: threadId,
            contentType: .plugin(
                MessagePlugin(
                    text: nil,
                    postback: "",
                    element: .quickReplies(
                        PluginMessageQuickReplies(
                            id: "Ek4tPy1h4",
                            elements: [
                                .text(PluginMessageText(id: "Akm0hRAiX", text: "This is some text", mimeType: nil)),
                                .button(PluginMessageButton(
                                    id: "Nkm0hRAiE",
                                    text: "Button 1",
                                    postback: "click-on-button-1",
                                    url: nil,
                                    displayInApp: false)
                                ),
                                .button(PluginMessageButton(
                                    id: "TkGJ6CAiN",
                                    text: "Button 2",
                                    postback: "click-on-button-2",
                                    url: nil,
                                    displayInApp: false)
                                ),
                                .button(PluginMessageButton(
                                    id: "EyCyTRCi4",
                                    text: "Button 3",
                                    postback: "click-on-button-2",
                                    url: nil,
                                    displayInApp: false)
                                )
                            ]
                        )
                    )
                )
            ),
            createdAt: createdAt,
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadStubFromBundle(withName: "MessageType/MessageTypePluginQuickReplies", extension: "json")
        
        let decodedMessage = try decoder.decode(MessageDTO.self, from: encodedData)
        let expectationMessage = try decoder.decode(MessageDTO.self, from: expectationData)
        
        XCTAssertEqual(decodedMessage.idOnExternalPlatform, expectationMessage.idOnExternalPlatform)
        
        guard case .plugin(let decodedPlugin) = decodedMessage.contentType,
              case .quickReplies(let decodedQuickReplies) = decodedPlugin.element,
              case .plugin(let expectationPlugin) = expectationMessage.contentType,
              case .quickReplies(let expectationQuickReplies) = expectationPlugin.element
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedQuickReplies.id, expectationQuickReplies.id)
        XCTAssertEqual(decodedQuickReplies.elements.count, expectationQuickReplies.elements.count)
        
        guard case .button(let decodedButton) = decodedQuickReplies.elements[1],
              case .button(let expectationButton) = expectationQuickReplies.elements[1]
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedButton.id, expectationButton.id)
        XCTAssertEqual(decodedButton.postback, expectationButton.postback)
        XCTAssertEqual(decodedButton.text, expectationButton.text)
    }
    
    
    // MARK: - Content Type Plugin: Menu
    
    func testContentTypePluginMenuEncodeCorrectly() throws {
        guard let id = UUID(uuidString: "a91082b7-46f8-4d0d-af43-079994de98c6"),
              let threadId = UUID(uuidString: "AD342920-C75E-4B06-B973-00494CC811B7"),
              let createdAt = iso8601Formatter.date(from: "2022-03-15T17:54:50+0000"),
              let fileURL = URL(string: "https://picsum.photos/300/150")
        else {
            throw CXoneChatError.invalidData
        }
        
        let message = Message(
            id: id,
            threadId: threadId,
            contentType: .plugin(
                MessagePlugin(
                    text: nil,
                    postback: "",
                    element: .menu(
                        PluginMessageMenu(
                            id: "Ek4tPy1h4",
                            elements: [
                                .file(PluginMessageFile(id: "Uk4tPy1h2", fileName: "photo.jpg", url: fileURL, mimeType: "image/jpeg")),
                                .title(PluginMessageTitle(id: "Ck4tPy1h3", text: "Hello!")),
                                .text(PluginMessageText(id: "Ek4tPy1h1", text: "Lorem Impsum...", mimeType: nil)),
                                .button(PluginMessageButton(
                                    id: "Nkm0hRAiE",
                                    text: "Click me!",
                                    postback: "click-on-button-1",
                                    url: nil,
                                    displayInApp: false)
                                ),
                                .button(PluginMessageButton(
                                    id: "NkGJ6CAiN",
                                    text: "No click me!",
                                    postback: "click-on-button-2",
                                    url: nil,
                                    displayInApp: false)
                                ),
                                .button(PluginMessageButton(
                                    id: "EyCyTRCi4",
                                    text: "Aww don`t click on me",
                                    postback: "click-on-button-2",
                                    url: nil,
                                    displayInApp: false)
                                )
                            ]
                        )
                    )
                )
            ),
            createdAt: createdAt,
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadStubFromBundle(withName: "MessageType/MessageTypePluginMenu", extension: "json")
        
        let decodedMessage = try decoder.decode(MessageDTO.self, from: encodedData)
        let expectationMessage = try decoder.decode(MessageDTO.self, from: expectationData)
        
        XCTAssertEqual(decodedMessage.idOnExternalPlatform, expectationMessage.idOnExternalPlatform)
        
        guard case .plugin(let decodedPlugin) = decodedMessage.contentType,
              case .menu(let decodedMenu) = decodedPlugin.element,
              case .plugin(let expectationPlugin) = expectationMessage.contentType,
              case .menu(let expectationMenu) = expectationPlugin.element
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedMenu.id, expectationMenu.id)
        XCTAssertEqual(decodedMenu.elements.count, expectationMenu.elements.count)
        
        guard case .file(let decodedFile) = decodedMenu.elements.first,
              case .file(let expectationFile) = expectationMenu.elements.first
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedFile.id, expectationFile.id)
        XCTAssertEqual(decodedFile.url, expectationFile.url)
        XCTAssertEqual(decodedFile.fileName, expectationFile.fileName)
    }
    
    
    // MARK: - Content Type Plugin: Custom
    
    func testContentTypePluginCustomEncodeCorrectly() throws {
        guard let id = UUID(uuidString: "a91082b7-46f8-4d0d-af43-079994de98c6"),
              let threadId = UUID(uuidString: "AD342920-C75E-4B06-B973-00494CC811B7"),
              let createdAt = iso8601Formatter.date(from: "2022-03-15T17:54:50+0000")
        else {
            throw CXoneChatError.invalidData
        }
        
        let message = Message(
            id: id,
            threadId: threadId,
            contentType: .plugin(
                MessagePlugin(
                    text: nil,
                    postback: "",
                    element: .custom(
                        PluginMessageCustom(
                            id: "Ek4tPy1h4",
                            text: "See this page",
                            variables: [
                                "color": "green",
                                "buttons": [
                                    [
                                        "id": "0edc9bf6-4922-4695-a6ad-1bdb248dd42f",
                                        "name": "Confirm"
                                    ],
                                    [
                                        "id": "0edc9bf6-4922-4695-a6ad-1bdb248dd42f",
                                        "name": "Decline"
                                    ]
                                ],
                                "size": [
                                    "ios": "big",
                                    "android": "middle"
                                ]
                            ]
                        )
                    )
                )
            ),
            createdAt: createdAt,
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadStubFromBundle(withName: "MessageType/MessageTypePluginCustom", extension: "json")
        
        let decodedMessage = try decoder.decode(MessageDTO.self, from: encodedData)
        let expectationMessage = try decoder.decode(MessageDTO.self, from: expectationData)
        
        XCTAssertEqual(decodedMessage.idOnExternalPlatform, expectationMessage.idOnExternalPlatform)
        
        guard case .plugin(let decodedPlugin) = decodedMessage.contentType,
              case .custom(let decodedCustom) = decodedPlugin.element,
              case .plugin(let expectationPlugin) = expectationMessage.contentType,
              case .custom(let expectationCustom) = expectationPlugin.element
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedCustom.id, expectationCustom.id)
        XCTAssertEqual(decodedCustom.variables.count, expectationCustom.variables.count)
        
        XCTAssertEqual(decodedCustom.variables["color"]?.string, expectationCustom.variables["color"]?.string)
    }
    
    
    // MARK: - Content Type Plugin: Satisfaction Survey
    
    func testContentTypePluginSatisfactionSurveyEncodeCorrectly() throws {
        guard let id = UUID(uuidString: "a91082b7-46f8-4d0d-af43-079994de98c6"),
              let threadId = UUID(uuidString: "AD342920-C75E-4B06-B973-00494CC811B7"),
              let createdAt = iso8601Formatter.date(from: "2022-03-15T17:54:50+0000"),
              let surveyURL = URL(string: "http://example.com/1/2/3")
        else {
            throw CXoneChatError.invalidData
        }
        
        let message = Message(
            id: id,
            threadId: threadId,
            contentType: .plugin(
                MessagePlugin(
                    text: nil,
                    postback: "",
                    element: .satisfactionSurvey(
                        PluginMessageSatisfactionSurvey(
                            id: "7a0c5bbe-af0c-47aa-986d-499eb6064811",
                            elements: [
                                .text(PluginMessageText(id: "7a0c5bbe-af0c-47aa-986d-499eb6064811", text: "Please rate us", mimeType: "text/plain")),
                                .button(
                                    PluginMessageButton(
                                        id: "52c804ec-6287-48d9-bc14-55bc531105f9",
                                        text: "Open survey",
                                        postback: nil,
                                        url: surveyURL ,
                                        displayInApp: false
                                    )
                                )
                            ]
                        )
                    )
                )
            ),
            createdAt: createdAt,
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadStubFromBundle(withName: "MessageType/MessageTypePluginSatisfactionSurvey", extension: "json")
        
        let decodedMessage = try decoder.decode(MessageDTO.self, from: encodedData)
        let expectationMessage = try decoder.decode(MessageDTO.self, from: expectationData)
        
        XCTAssertEqual(decodedMessage.idOnExternalPlatform, expectationMessage.idOnExternalPlatform)
        
        guard case .plugin(let decodedPlugin) = decodedMessage.contentType,
              case .satisfactionSurvey(let decodedSurvey) = decodedPlugin.element,
              case .plugin(let expectationPlugin) = expectationMessage.contentType,
              case .satisfactionSurvey(let expectationSurvey) = expectationPlugin.element
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedSurvey.id, expectationSurvey.id)
        XCTAssertEqual(decodedSurvey.elements.count, expectationSurvey.elements.count)
        
        guard case .button(let decodedButton) = decodedSurvey.elements[1],
              case .button(let expectationButton) = expectationSurvey.elements[1]
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedButton.id, expectationButton.id)
        XCTAssertEqual(decodedButton.url, expectationButton.url)
        XCTAssertEqual(decodedButton.text, expectationButton.text)
    }
    
    
    // MARK: - Content Type Plugin: Gallery
 
    func testContentTypePluginGalleryEncodeCorrectly() throws {
        guard let id = UUID(uuidString: "a91082b7-46f8-4d0d-af43-079994de98c6"),
              let threadId = UUID(uuidString: "AD342920-C75E-4B06-B973-00494CC811B7"),
              let createdAt = iso8601Formatter.date(from: "2022-03-15T17:54:50+0000"),
              let fileURL = URL(string: "https://picsum.photos/300/150")
        else {
            throw CXoneChatError.invalidData
        }
        
        let message = Message(
            id: id,
            threadId: threadId,
            contentType: .plugin(
                MessagePlugin(
                    text: nil,
                    postback: "",
                    element: .gallery([
                        .menu(
                            PluginMessageMenu(
                                id: "Ek4tPy1h4",
                                elements: [
                                    .file(PluginMessageFile(id: "Uk4tPy1h2", fileName: "photo.jpg", url: fileURL, mimeType: "image/jpeg")),
                                    .title(PluginMessageTitle(id: "Ck4tPy1h3", text: "Hello!")),
                                    .text(PluginMessageText(id: "Ek4tPy1h1", text: "Lorem Impsum...", mimeType: nil))
                                ]
                            )
                        ),
                        .menu(
                            PluginMessageMenu(
                                id: "SwQ1xGSnX",
                                elements: [
                                    .button(PluginMessageButton(
                                        id: "Nkm0hRAiE",
                                        text: "Click me!",
                                        postback: "click-on-button-1",
                                        url: nil,
                                        displayInApp: false)
                                    ),
                                    .button(PluginMessageButton(
                                        id: "NkGJ6CAiN",
                                        text: "No click me!",
                                        postback: "click-on-button-2",
                                        url: nil,
                                        displayInApp: false)
                                    ),
                                    .button(PluginMessageButton(
                                        id: "EyCyTRCi4",
                                        text: "Aww don`t click on me",
                                        postback: "click-on-button-2",
                                        url: nil,
                                        displayInApp: false)
                                    )
                                ]
                            )
                        )
                    ])
                )
            ),
            createdAt: createdAt,
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadStubFromBundle(withName: "MessageType/MessageTypePluginGallery", extension: "json")
        
        let decodedMessage = try decoder.decode(MessageDTO.self, from: encodedData)
        let expectationMessage = try decoder.decode(MessageDTO.self, from: expectationData)
        
        XCTAssertEqual(decodedMessage.idOnExternalPlatform, expectationMessage.idOnExternalPlatform)
        
        guard case .plugin(let decodedPlugin) = decodedMessage.contentType,
              case .gallery(let decodedGallery) = decodedPlugin.element,
              case .plugin(let expectationPlugin) = expectationMessage.contentType,
              case .gallery(let expectationGallery) = expectationPlugin.element
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedGallery.count, expectationGallery.count)
        
        guard case .menu(let decodedMenu) = decodedGallery.first,
              case .file(let decodedFile) = decodedMenu.elements.first,
              case .menu(let expectationMenu) = expectationGallery.first,
              case .file(let expectationFile) = expectationMenu.elements.first
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(decodedFile.id, expectationFile.id)
        XCTAssertEqual(decodedFile.url, expectationFile.url)
        XCTAssertEqual(decodedFile.fileName, expectationFile.fileName)
    }
}
