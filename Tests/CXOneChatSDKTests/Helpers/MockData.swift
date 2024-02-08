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

@testable import CXoneChatSDK
import Foundation

enum MockData {
    
    // MARK: - Properties
    
    static let dateProvider = DateProviderMock()
    
    static let imageUrl = "https://picsum.photos/200"
    
    static let agent = AgentDTO(
        id: Int.random(in: 1..<1000),
        inContactId: UUID().uuidString,
        emailAddress: "john.doe@nice.com",
        loginUsername: "jDoe",
        firstName: "John",
        surname: "Doe",
        nickname: "Johney",
        isBotUser: false,
        isSurveyUser: false,
        imageUrl: imageUrl
    )
    static let customerIdentity = CustomerIdentityDTO(idOnExternalPlatform: UUID().uuidString, firstName: nil, lastName: nil)
    
    static let optionsHierarchicalCustomField = CustomFieldHierarchicalDTO(
        ident: "options",
        label: "Options",
        value: nil,
        updatedAt: dateProvider.now,
        nodes: [
            CustomFieldHierarchicalNodeDTO(value: "a", label: "A", children: [.init(value: "a-1", label: "A1")]),
            CustomFieldHierarchicalNodeDTO(value: "b", label: "B", children: [.init(value: "b-1", label: "B1")])
        ]
    )
    
    static let nameTextCustomField = CustomFieldTextFieldDTO(
        ident: "firstName",
        label: "First Name",
        value: "Peter",
        updatedAt: dateProvider.now,
        isEmail: false
    )
    static let emailTextCustomField = CustomFieldTextFieldDTO(
        ident: "email",
        label: "E-mail",
        value: "peter.parker@gmail.com",
        updatedAt: dateProvider.now,
        isEmail: true
    )
    static let genderSelectorCustomField = CustomFieldSelectorDTO(
        ident: "gender",
        label: "Gender",
        value: "Male",
        updatedAt: dateProvider.now,
        options: ["gender-male": "Male", "gender-female": "Female"]
    )
    
    static let attachment = AttachmentUploadDTO(
        attachmentData: "attachment".data(using: .utf8)!,
        mimeType: "image/jpg",
        fileName: "file",
        friendlyName: "friendly"
    )

    
    // MARK: - Methods
    
    static func getThread(
        threadId: UUID = UUID(),
        scrollToken: String = UUID().uuidString,
        withMessages: Bool = true
    ) -> ChatThreadDTO {
        return ChatThreadDTO(
            idOnExternalPlatform: threadId,
            threadName: MockData.agent.fullName,
            messages: withMessages ? [getMessage(threadId: threadId, isSenderAgent: false)] : [],
            threadAgent: MockData.agent,
            contactId: UUID().uuidString,
            scrollToken: scrollToken,
            state: .ready
        )
    }
    
    static func getMessage(
        threadId: UUID = UUID(),
        messageId: UUID = UUID(),
        isSenderAgent: Bool,
        createdAt: Date = dateProvider.now
    ) -> MessageDTO {
        MessageDTO(
            idOnExternalPlatform: messageId,
            threadIdOnExternalPlatform: threadId,
            contentType: .text(MessagePayloadDTO(text: "text", postback: nil)),
            createdAt: createdAt,
            attachments: [],
            direction: isSenderAgent ? .outbound : .inbound,
            userStatistics: UserStatisticsDTO(seenAt: nil, readAt: nil),
            authorUser: isSenderAgent ? agent : nil,
            authorEndUserIdentity: isSenderAgent ? nil : customerIdentity
        )
    }
}
