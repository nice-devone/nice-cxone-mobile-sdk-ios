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

/// Information about the sender of a chat message.
public struct SenderInfo {
    
    // MARK: - Properties
    
    private static let personNameComponentsFormatter = PersonNameComponentsFormatter()
    
    /// The unique id for the sender (agent or customer). Represents the id for a customer and the id for the agent.
    public let id: String
    
    /// The first name of the sender.
    public let firstName: String?
    
    /// The last name of the sender.
    public let lastName: String?
    
    /// The full name of the sender.
    public var fullName: String? {
        var nameComponents = PersonNameComponents()
        nameComponents.givenName = firstName
        nameComponents.familyName = lastName
        
        return Self.personNameComponentsFormatter.string(from: nameComponents)
    }
    
    // MARK: - Init
    
    /// - Parameter message: The info about a message in a chat.
    public init?(message: Message) {
        if message.direction == .toClient {
            guard let agent = message.authorUser else {
                return nil
            }
            
            self.id = String(agent.id)
            self.firstName = agent.firstName
            self.lastName = agent.surname
        } else {
            guard let customer = message.authorEndUserIdentity else {
                return nil
            }
            
            self.id = customer.id
            self.firstName = customer.firstName
            self.lastName = customer.lastName
        }
    }
}
