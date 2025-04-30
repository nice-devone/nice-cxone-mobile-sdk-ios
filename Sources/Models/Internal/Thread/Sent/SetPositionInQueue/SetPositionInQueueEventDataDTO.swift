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

struct SetPositionInQueueEventDataDTO: Equatable {

    /// The contact ID for which this change applies.
    let consumerContact: String
    
    /// The customer's position in the queue
    let positionInQueue: Int
}

// MARK: - Decodable

extension SetPositionInQueueEventDataDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case consumerContact
        case positionInQueue
    }
    
    enum ConsumerContactCodingKeys: CodingKey {
        case id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.positionInQueue = try container.decode(Int.self, forKey: .positionInQueue)
        
        let consumerContainer = try container.nestedContainer(keyedBy: ConsumerContactCodingKeys.self, forKey: .consumerContact)
        self.consumerContact = try consumerContainer.decode(String.self, forKey: .id)
    }
}
