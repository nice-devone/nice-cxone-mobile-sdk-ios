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

/// All info about data of a received thread.
struct ReceivedThreadDataDTO: Equatable {
    
    // MARK: - Properties

    /// The unique identifier of the data in the external platform.
    let idOnExternalPlatform: UUID

    /// The unique identifier of the channel.
    let channelId: String

    /// The name given to the thread (for multi-thread channels only).
    let threadName: String

    /// The flag whenever more messages can be added.
    let canAddMoreMessages: Bool
}

// MARK: - Decodable

extension ReceivedThreadDataDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case idOnExternalPlatform
        case channelId
        case threadName
        case canAddMoreMessages
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.idOnExternalPlatform = try container.decode(UUID.self, forKey: .idOnExternalPlatform)
        self.channelId = try container.decode(String.self, forKey: .channelId)
        self.threadName = try container.decode(String.self, forKey: .threadName)
        self.canAddMoreMessages = try container.decode(Bool.self, forKey: .canAddMoreMessages)
    }
}
