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

/// Represents info about a postback of a generic event.
struct GenericEventPostbackDTO: Equatable {
    
    // MARK: - Properties
    
    /// The type of the event.
    let eventType: EventType?

    /// The data of the received threads.
    let threads: [ReceivedThreadDataDTO]?
}

// MARK: - Decodable

extension GenericEventPostbackDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case eventType
        case data
    }
    
    enum ReceivedThreadsKeys: CodingKey {
        case threads
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let receivedThreadsContainer = try? container.nestedContainer(keyedBy: ReceivedThreadsKeys.self, forKey: .data)
        
        self.eventType = try container.decodeIfPresent(EventType.self, forKey: .eventType)
        self.threads = try receivedThreadsContainer?.decodeIfPresent([ReceivedThreadDataDTO].self, forKey: .threads)
    }
}
