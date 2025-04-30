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

/// Data payload for the load more messages event.
struct LoadMoreMessagesEventDataDTO {
    
    let scrollToken: String
    
    let thread: ThreadDTO
    
    let oldestMessageDatetime: Date
}

// MARK: - Encodable

extension LoadMoreMessagesEventDataDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case scrollToken
        case thread
        case oldestMessageDatetime
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(scrollToken, forKey: .scrollToken)
        try container.encode(thread, forKey: .thread)
        try container.encodeISODate(oldestMessageDatetime, forKey: .oldestMessageDatetime)
    }
}
