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

/// Event received when a token has been successfully refreshed.
struct TokenRefreshedEventDTO: Decodable {

    let eventId: UUID
    
    /// Type of event
    let eventType: EventType?

    let postback: TokenRefreshedEventPostbackDTO

    // MARK: - constructor

    init(eventId: UUID, eventType: EventType? = .tokenRefreshed, postback: TokenRefreshedEventPostbackDTO) {
        self.eventId = eventId
        self.eventType = eventType
        self.postback = postback
    }
}

// MARK: - ReceivedEvent

extension TokenRefreshedEventDTO: ReceivedEvent {
    static let eventType: EventType? = .tokenRefreshed

    var postbackEventType: EventType? { postback.eventType }
}
