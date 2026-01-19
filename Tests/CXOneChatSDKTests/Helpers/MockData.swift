//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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
        firstName: "John",
        surname: "Doe",
        nickname: "Johney",
        isBotUser: false,
        isSurveyUser: false,
        publicImageUrl: imageUrl
    )
    static let customerIdentity = CustomerIdentityDTO(
        idOnExternalPlatform: LowercaseUUID().uuidString,
        firstName: nil,
        lastName: nil
    )
    
    static let optionsHierarchicalCustomField = CustomFieldHierarchicalDTO(
        ident: "options",
        label: "Options",
        value: nil,
        updatedAt: dateProvider.now,
        nodes: [
            CustomFieldHierarchicalNodeDTO(key: "a", value: "A", children: [.init(key: "a-1", value: "A1")]),
            CustomFieldHierarchicalNodeDTO(key: "b", value: "B", children: [.init(key: "b-1", value: "B1")])
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
    
    static func getChannelConfiguration(
        isMultithread: Bool = false,
        prechatSurvey: PreChatSurveyDTO? = nil,
        fileRestrictions: FileRestrictionsDTO = FileRestrictionsDTO(
            allowedFileSize: 40,
            allowedFileTypes: [AllowedFileTypeDTO(mimeType: "image/*", details: "images"), AllowedFileTypeDTO(mimeType: "video/*", details: "videos")],
            isAttachmentsEnabled: true
        ),
        features: [String: Bool] = [:],
        isOnline: Bool = false,
        isLiveChat: Bool = false
    ) -> ChannelConfigurationDTO {
        ChannelConfigurationDTO(
            settings: ChannelSettingsDTO(
                hasMultipleThreadsPerEndUser: isMultithread,
                isProactiveChatEnabled: false,
                fileRestrictions: fileRestrictions,
                features: features
            ),
            isAuthorizationEnabled: false,
            prechatSurvey: prechatSurvey,
            liveChatAvailability: CurrentLiveChatAvailability(isChannelLiveChat: isLiveChat, isOnline: isOnline, expires: .distantFuture)
        )
    }
    
    static func getThread(
        threadId: String = LowercaseUUID().uuidString,
        scrollToken: String = LowercaseUUID().uuidString,
        withMessages: Bool = true,
        contactId: String = LowercaseUUID().uuidString
    ) -> ChatThreadDTO {
        ChatThreadDTO(
            idOnExternalPlatform: threadId,
            threadName: MockData.agent.fullName,
            messages: withMessages ? [getMessage(threadId: threadId, isSenderAgent: false)] : [],
            inboxAssignee: MockData.agent,
            previousInboxAssignee: nil,
            contactId: contactId,
            scrollToken: scrollToken,
            state: .ready
        )
    }
    
    static func getMessage(
        threadId: String = LowercaseUUID().uuidString,
        messageId: String = LowercaseUUID().uuidString,
        isSenderAgent: Bool,
        createdAt: Date = dateProvider.now
    ) -> MessageDTO {
        MessageDTO(
            idOnExternalPlatform: UUID(),
            idOnExternalPlatformString: messageId,
            threadIdOnExternalPlatform: UUID(),
            threadIdOnExternalPlatformString: threadId,
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
