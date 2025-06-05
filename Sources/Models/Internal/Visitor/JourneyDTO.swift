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

struct JourneyDTO {
    
    let url: String
    
    let utm: UTMDTO
}

// MARK: - Encodable

extension JourneyDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case referrer
        case utm
    }
    
    enum ReferrerKeys: CodingKey {
        case url
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var referrerCOntainer = container.nestedContainer(keyedBy: ReferrerKeys.self, forKey: .referrer)
        
        try referrerCOntainer.encode(url, forKey: .url)
        try container.encode(utm, forKey: .utm)
    }
}
