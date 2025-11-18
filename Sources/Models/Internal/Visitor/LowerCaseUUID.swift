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

/// Class for operating with UUID values to ensure that they are sent in lowercase format.
///
/// This is required because with Swift, all `UUID` values are uppercase and cannot be
/// changed while keeping the `UUID` type. Currently, the back end doesn't support these
/// uppercase values on certain events (visitor events), so this is done as a workaround.
struct LowerCaseUUID: Equatable {

    // MARK: - Properties

    let uuid: UUID

    // MARK: - Init

    init(uuid: UUID = UUID()) {
        self.uuid = UUID(uuidString: uuid.uuidString.lowercased()) ?? uuid
    }
}

// MARK: - Codable

extension LowerCaseUUID: Codable {
    
    init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()

        self.uuid = try values.decode(UUID.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(self.uuid.uuidString.lowercased())
    }
}

extension UUID {
    
    var asLowerCaseUUID: LowerCaseUUID {
        LowerCaseUUID(uuid: self)
    }
}
