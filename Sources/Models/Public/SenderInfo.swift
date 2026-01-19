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

import Foundation

/// Information about the sender of a chat message.
public struct SenderInfo {
    
    // MARK: - Properties
    
    /// The unique id for the sender (agent or customer). Represents the id for a customer and the id for the agent.
    public let id: String
    
    /// The first name of the sender.
    public let firstName: String
    
    /// The last name of the sender.
    public let lastName: String
    
    /// The full name of the sender.
    public var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    // MARK: - Init
    
    /// - Parameter message: The info about a message in a chat.
    public init(message: Message) {
        if message.direction == .toClient {
            self.id = String(message.authorUser?.id ?? 0)
            self.firstName = message.authorUser?.firstName ?? "Automated"
            self.lastName = message.authorUser?.surname ?? "Agent"
        } else {
            self.id = String(message.authorEndUserIdentity?.id ?? LowercaseUUID.provide().uuidString)
            self.firstName = message.authorEndUserIdentity?.firstName ?? "Unknown"
            self.lastName = message.authorEndUserIdentity?.lastName ?? "Customer"
        }
    }
}
