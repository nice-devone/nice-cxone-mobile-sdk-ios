//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
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
        let data = try loadBundleData(from: "MessageType/MessageTypeText", type: "json")

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
        let data = try loadBundleData(from: "RichMessages/MessageTypeRichLink", type: "json")

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
        let data = try loadBundleData(from: "RichMessages/MessageTypeQuickReplies", type: "json")

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
        let data = try loadBundleData(from: "RichMessages/MessageTypeListPicker", type: "json")
        
        let message = MessageMapper.map(try decoder.decode(MessageDTO.self, from: data))
        
        guard case .listPicker(let entity) = message.contentType,
              case .replyButton(let firstButton) = entity.buttons[safe: 0],
              case .replyButton(let secondButton) = entity.buttons[safe: 1]
        else {
            throw CXoneChatError.invalidData
        }
        
        XCTAssertEqual(entity.title, "Choose a color!")
        XCTAssertEqual(entity.text, "What is your favourite color?")
        XCTAssertEqual(entity.buttons.count, 2)
        
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
}
