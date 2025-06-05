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

/// Event received when thread metadata has been loaded.
struct ThreadMetadataLoadedEventDTO: Decodable, Equatable {

    let eventId: UUID

    /// Type of event
    let eventType: EventType?

    let postback: ThreadMetadataLoadedEventPostbackDTO
}

// MARK: - ReceivedEvent

extension ThreadMetadataLoadedEventDTO: ReceivedEvent {
    
    static let eventType: EventType? = .threadMetadataLoaded

    var postbackEventType: EventType? { postback.eventType }
}
