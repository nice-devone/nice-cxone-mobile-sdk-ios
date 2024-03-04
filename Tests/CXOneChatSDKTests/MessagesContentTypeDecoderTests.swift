//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import XCTest
@testable import CXoneChatSDK

class MessagesContentTypeDecoderTests: XCTestCase {
    
    // MARK: - Properties
    
    private let decoder = JSONDecoder()
    
    // MARK: - ContentType Text
    
    func testContentTypeTextDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "MessageType/MessageTypeText", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        switch message.contentType {
        case .text(let entity):
            XCTAssertEqual("Hello world", entity.text)
        default:
            XCTFail("Invalid message content type")
        }
    }
    
    // MARK: - ContentType Rich Link
    
    func testContentTypeRichLinkDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "RichMessages/MessageTypeRichLink", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .richLink(let entity) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.fileName, "place-kitten.jpg")
        XCTAssertEqual(entity.fileUrl, URL(string: "https://placekitten.com/200/300"))
        XCTAssertEqual(entity.mimeType, "image/jpeg")
        XCTAssertEqual(entity.title, "Check our new gadget!")
        XCTAssertEqual(entity.url, URL(string: "https://www.google.com"))
    }
    
    // MARK: - ContentType Quick Replies
    
    func testContentTypeQuickRepliesDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "RichMessages/MessageTypeQuickReplies", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .quickReplies(let entity) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.title, "Hello, we will deliver the package between 12:00 and 16:00. Please specify which day.")
        XCTAssertEqual(entity.buttons.count, 2)
        XCTAssertEqual(entity.buttons[0].text, "Today")
        XCTAssertEqual(entity.buttons[0].postback, #"{"id":"1"}"#)
        XCTAssertEqual(entity.buttons[1].text, "Tomorrow")
        XCTAssertEqual(entity.buttons[1].postback, #"{"id":"2"}"#)
    }
    
    // MARK: - ContentType List Picker
    
    func testContentTypeListPickerDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "RichMessages/MessageTypeListPicker", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .listPicker(let entity) = message.contentType,
              case .replyButton(let firstButton) = entity.elements[safe: 0],
              case .replyButton(let secondButton) = entity.elements[safe: 1]
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.title, "Choose a color!")
        XCTAssertEqual(entity.text, "What is your favourite color?")
        XCTAssertEqual(entity.elements.count, 2)
        
        XCTAssertEqual(firstButton.text, "red")
        XCTAssertEqual(firstButton.description, "Like a tomato")
        XCTAssertEqual(firstButton.postback, "/red")
        XCTAssertEqual(firstButton.iconName, "place-kitten.jpg")
        XCTAssertEqual(firstButton.iconUrl, URL(string: "https://placekitten.com/200/300"))
        XCTAssertEqual(firstButton.iconMimeType, "image/jpeg")
        
        XCTAssertEqual(secondButton.text, "green")
        XCTAssertEqual(secondButton.description, "Like an apple")
        XCTAssertEqual(secondButton.postback, "/green")
        XCTAssertEqual(secondButton.iconName, "place-kitten.jpg")
        XCTAssertEqual(secondButton.iconUrl, URL(string: "https://placekitten.com/200/300"))
        XCTAssertEqual(secondButton.iconMimeType, "image/jpeg")
    }
    
    // MARK: - Content Type Plugin: Deeplink
    
    func testContentTypePluginDeeplinkDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "MessageType/MessageTypePluginDeeplink", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .plugin(let plugin) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        guard case .subElements(let entities) = plugin.element, case .button(let deeplinkButton) = entities.first else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(deeplinkButton.url?.absoluteString, "fb://profile/33138223345")
        XCTAssertEqual(deeplinkButton.text, "See this page")
        XCTAssertEqual(deeplinkButton.id, "Nkm0hRAiE")
    }
    
    // MARK: - Content Type Plugin: Text And Buttons
    
    func testContentTypePluginTextAndButtonsDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "MessageType/MessageTypePluginTextAndButtons", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .plugin(let plugin) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        guard case .textAndButtons(let entity) = plugin.element else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.elements.count, 4)
        
        var subElementTextCount = 0
        var subElementButtonCount = 0
        
        entity.elements.forEach { element in
            if case .text = element {
                subElementTextCount += 1
            } else if case .button = element {
                subElementButtonCount += 1
            }
        }
        
        XCTAssertEqual(subElementTextCount, 1)
        XCTAssertEqual(subElementButtonCount, 3)
    }
    
    // MARK: - Content Type Plugin: Quick Replies
    
    func testContentTypePluginQuickRepliesDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "MessageType/MessageTypePluginQuickReplies", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .plugin(let plugin) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        guard case .quickReplies(let entity) = plugin.element else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.elements.count, 4)
        
        var subElementTextCount = 0
        var subElementButtonCount = 0
        
        entity.elements.forEach { element in
            if case .text = element {
                subElementTextCount += 1
            } else if case .button = element {
                subElementButtonCount += 1
            }
        }
        
        XCTAssertEqual(subElementTextCount, 1)
        XCTAssertEqual(subElementButtonCount, 3)
    }
    
    // MARK: - Content Type Plugin: Menu
    
    func testContentTypePluginMenuDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "MessageType/MessageTypePluginMenu", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .plugin(let plugin) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        guard case .menu(let entity) = plugin.element else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.elements.count, 6)
        
        var subElementTextCount = 0
        var subElementButtonCount = 0
        
        entity.elements.forEach { element in
            if case .text = element {
                subElementTextCount += 1
            } else if case .button = element {
                subElementButtonCount += 1
            }
        }
        
        XCTAssertEqual(subElementTextCount, 1)
        XCTAssertEqual(subElementButtonCount, 3)
    }
    
    // MARK: - Content Type Plugin: Satisfaction Survey
    
    func testContentTypePluginSatisfactionSurveyDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "MessageType/MessageTypePluginSatisfactionSurvey", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .plugin(let plugin) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        guard case .satisfactionSurvey(let entity) = plugin.element else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.elements.count, 2)
        
        var subElementTextCount = 0
        var subElementButtonCount = 0
        
        entity.elements.forEach { element in
            if case .text = element {
                subElementTextCount += 1
            } else if case .button(let button) = element {
                subElementButtonCount += 1
                
                XCTAssertTrue(button.displayInApp)
                
            }
        }
        
        XCTAssertEqual(subElementTextCount, 1)
        XCTAssertEqual(subElementButtonCount, 1)
    }
    
    // MARK: - Content Type Plugin: Custom
    
    func testContentTypePluginCustomDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "MessageType/MessageTypePluginCustom", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .plugin(let plugin) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        guard case .custom(let entity) = plugin.element else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.text, "See this page")
        XCTAssertEqual(entity.variables["color"] as? String, "green")
        XCTAssertEqual((entity.variables["buttons"]as? [Any])?.count, 2)
        XCTAssertEqual(((entity.variables["buttons"] as? [Any])?.first as? [String: Any])?["name"] as? String, "Confirm")
    }
    
    // MARK: - Content Type Plugin: Gallery
    
    func testContentTypePluginGalleryDecodeCorrectly() throws {
        let data = try loadStubFromBundle(withName: "MessageType/MessageTypePluginGallery", extension: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .plugin(let plugin) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        guard case .gallery(let entities) = plugin.element else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entities.count, 2)
    }
}
