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

class MessagesContentTypeEncoderTests: XCTestCase {
    
    // MARK: - Properties
    
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
            authorEndUserIdentity: nil,
            status: .seen
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadBundleData(from: "MessageType/MessageTypeText", type: "json")

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
              let imageUrl = URL(string: "https://placekitten.com/200/300")
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
                    fileUrl: imageUrl,
                    mimeType: "image/jpeg"
                )
            ),
            createdAt: createdAt,
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil,
            status: .seen
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadBundleData(from: "RichMessages/MessageTypeRichLink", type: "json")

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
                        MessageReplyButton(text: "Today", description: nil, postback: #"{"id":"1"}"#, iconName: nil, iconUrl: nil, iconMimeType: nil),
                        MessageReplyButton(text: "Tomorrow", description: nil, postback: #"{"id":"2"}"#, iconName: nil, iconUrl: nil, iconMimeType: nil)
                    ]
                )
            ),
            createdAt: createdAt,
            attachments: [],
            direction: .toAgent,
            userStatistics: UserStatistics(seenAt: nil, readAt: nil),
            authorUser: nil,
            authorEndUserIdentity: nil,
            status: .seen
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadBundleData(from: "RichMessages/MessageTypeQuickReplies", type: "json")

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
                    buttons: [
                        .replyButton(
                            MessageReplyButton(
                                text: "red",
                                description: "Like a tomato",
                                postback: "/red",
                                iconName: "place-kitten.jpg",
                                iconUrl: URL(string: "https://placekitten.com/200/300"),
                                iconMimeType: "image/jpeg"
                            )
                        ),
                        .replyButton(
                            MessageReplyButton(
                                text: "green",
                                description: "Like an apple",
                                postback: "/green",
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
            authorEndUserIdentity: nil,
            status: .seen
        )
        
        let encodedData = try encoder.encode(MessageMapper.map(message))
        let expectationData = try loadBundleData(from: "RichMessages/MessageTypeListPicker", type: "json")
        
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

}
