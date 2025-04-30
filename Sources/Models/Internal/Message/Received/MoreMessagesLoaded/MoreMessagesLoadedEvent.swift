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

/// Event received when more messages are loaded.
struct MoreMessagesLoadedEventDTO: Decodable, Equatable {

    /// The unique identifier of the event.
    let eventId: UUID

    /// Type of event
    let eventType: EventType?

    /// The postback of the more message loaded event.
    let postback: MoreMessagesLoadedEventPostbackDTO
}

// MARK: - ReceivedEvent

extension MoreMessagesLoadedEventDTO: ReceivedEvent {
    
    static let eventType: EventType? = .moreMessagesLoaded

    var postbackEventType: EventType? { postback.eventType }
}
