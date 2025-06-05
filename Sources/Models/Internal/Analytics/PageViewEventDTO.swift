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

struct PageViewEventDTO {

    let title: String
    
    let url: String
    
    // Used for ``AnalyticsProvider/viewPageEnded(title:url:)`` method to be able to calculate a time spent on page.
    let timestamp: Date
}

// MARK: - Encodable

extension PageViewEventDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case title
        case url
    }
}
