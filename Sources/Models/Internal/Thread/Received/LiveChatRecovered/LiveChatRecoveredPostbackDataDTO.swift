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

import Foundation

struct LiveChatRecoveredPostbackDataDTO: Equatable {
    
    // MARK: - Properties
    
    /// The info about a contact (case).
    let contact: ContactDTO
    
    /// The info about an agent.
    let inboxAssignee: AgentDTO?
    
    /// The last agent that has been assigned to the thread
    let previousInboxAssignee: AgentDTO?
    
    /// The list of messages on the thread.
    let messages: [MessageDTO]
    
    let messagesScrollToken: String
    
    /// The info abount about received thread.
    let thread: ReceivedThreadDataDTO
    
    let customerCustomFields: [CustomFieldDTO]
}

// MARK: - Decodable

extension LiveChatRecoveredPostbackDataDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case contact
        case inboxAssignee
        case previousInboxAssignee
        case messages
        case messagesScrollToken
        case thread
        case customer
    }
    
    enum CustomerKeys: CodingKey {
        case customFields
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let customerContainer = try container.nestedContainer(keyedBy: CustomerKeys.self, forKey: .customer)
        
        self.contact = try container.decode(ContactDTO.self, forKey: .contact)
        self.inboxAssignee = try container.decodeIfPresent(AgentDTO.self, forKey: .inboxAssignee)
        self.previousInboxAssignee = try container.decodeIfPresent(AgentDTO.self, forKey: .previousInboxAssignee)
        self.messages = try container.decode([MessageDTO].self, forKey: .messages)
        self.messagesScrollToken = try container.decode(String.self, forKey: .messagesScrollToken)
        self.thread = try container.decode(ReceivedThreadDataDTO.self, forKey: .thread)
        self.customerCustomFields = try customerContainer.decode([CustomFieldDTO].self, forKey: .customFields)
    }
}
