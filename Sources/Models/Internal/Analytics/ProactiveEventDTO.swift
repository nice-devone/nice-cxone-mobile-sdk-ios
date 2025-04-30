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

struct ProactiveEventDTO: Equatable {

    // MARK: - Properties

    let id: UUID
    let name: String
    let type: ActionType
}

// MARK: - Mapper

extension ProactiveEventDTO {
    init(from: ProactiveActionDetails) {
        id = from.id
        name = from.name
        type = from.type
    }
}

// MARK: - Encodable

extension ProactiveEventDTO: Encodable {
    enum CodingKeys: String, CodingKey {
        case id = "actionId"
        case name = "actionName"
        case type = "actionType"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
    }
}
