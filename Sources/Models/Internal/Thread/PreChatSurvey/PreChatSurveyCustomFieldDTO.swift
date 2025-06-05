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

struct PreChatSurveyCustomFieldDTO {
    
    let isRequired: Bool
    
    let type: CustomFieldDTOType
}

// MARK: - Decodable

extension PreChatSurveyCustomFieldDTO: Decodable {
    
    enum CodingKeys: CodingKey {
        case isRequired
        case definition
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.isRequired = try container.decode(Bool.self, forKey: .isRequired)
        self.type = try container.decode(CustomFieldDTOType.self, forKey: .definition)
    }
}
