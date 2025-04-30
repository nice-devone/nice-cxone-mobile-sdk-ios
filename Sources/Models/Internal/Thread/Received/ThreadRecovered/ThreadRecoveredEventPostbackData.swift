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

/// Represents data about a thread recovered event postback.
struct ThreadRecoveredEventPostbackDataDTO: Equatable {
    
    // MARK: - Properties
    
    /// The info about a contact (case).
    let consumerContact: ContactDTO

    /// The list of messages on the thread.
    let messages: [MessageDTO]

    /// The info about an agent.
    let inboxAssignee: AgentDTO?

    /// The info abount about received thread.
    let thread: ReceivedThreadDataDTO

    /// The scroll token of the messages.
    let messagesScrollToken: String
    
    let customerCustomFields: [CustomFieldDTO]
}

// MARK: - Decodable

extension ThreadRecoveredEventPostbackDataDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case consumerContact
        case contact
        case messages
        case inboxAssignee
        case thread
        case messagesScrollToken
        case customer
    }
    
    enum CustomerKeys: CodingKey {
        case customFields
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let customerContainer = try container.nestedContainer(keyedBy: CustomerKeys.self, forKey: .customer)
        
        if let contact = try container.decodeIfPresent(ContactDTO.self, forKey: .contact) {
            self.consumerContact = contact
        } else {
            self.consumerContact = try container.decode(ContactDTO.self, forKey: .consumerContact)
        }

        self.messages = try container.decode([MessageDTO].self, forKey: .messages)
        self.inboxAssignee = try container.decodeIfPresent(AgentDTO.self, forKey: .inboxAssignee)
        self.thread = try container.decode(ReceivedThreadDataDTO.self, forKey: .thread)
        self.messagesScrollToken = try container.decode(String.self, forKey: .messagesScrollToken)
        self.customerCustomFields = try customerContainer.decode([CustomFieldDTO].self, forKey: .customFields)
    }
}
