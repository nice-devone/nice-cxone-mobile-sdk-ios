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

struct InternalServerError: LocalizedError, Equatable {

    var eventType: EventType? { nil }

    let eventId: String

    let error: OperationError

    let thread: ThreadDTO?
}

// MARK: - ReceivedEvent

extension InternalServerError: ReceivedEvent {
    static let eventType: EventType? = nil

    var postbackEventType: EventType? { nil }
}

// MARK: - Decodable

extension InternalServerError: Decodable {
    
    enum CodingKeys: CodingKey {
        case eventId
        case error
        case inputData
    }
    
    enum InputDataCodingKeys: CodingKey {
        case thread
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let inputDataContainer = try container.nestedContainer(keyedBy: InputDataCodingKeys.self, forKey: .inputData)
        
        self.eventId = try container.decode(String.self, forKey: .eventId)
        self.error = try container.decode(OperationError.self, forKey: .error)
        self.thread = try inputDataContainer.decodeIfPresent(ThreadDTO.self, forKey: .thread)
    }
}
