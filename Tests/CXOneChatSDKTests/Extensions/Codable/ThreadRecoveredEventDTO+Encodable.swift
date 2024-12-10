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

extension ThreadRecoveredEventDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case eventId
        case postback
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(eventId, forKey: .eventId)
        try container.encode(postback, forKey: .postback)
    }
}

// MARK: - ThreadRecoveredEventPostbackDTO

extension ThreadRecoveredEventPostbackDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case eventType
        case data
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(eventType, forKey: .eventType)
        try container.encode(data, forKey: .data)
    }
}

// MARK: - ThreadRecoveredEventPostbackDTO

extension ThreadRecoveredEventPostbackDataDTO: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var customFieldsContainer = container.nestedContainer(keyedBy: CustomerKeys.self, forKey: .customer)
        
        try container.encode(consumerContact, forKey: .consumerContact)
        try container.encode(messages, forKey: .messages)
        try container.encode(inboxAssignee, forKey: .inboxAssignee)
        try container.encode(thread, forKey: .thread)
        try container.encode(messagesScrollToken, forKey: .messagesScrollToken)
        
        try customFieldsContainer.encode(customerCustomFields, forKey: .customFields)
    }
}
