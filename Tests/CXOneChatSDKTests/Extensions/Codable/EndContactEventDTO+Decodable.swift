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

@testable import CXoneChatSDK
import Foundation

extension EndContactEventDTO: Swift.Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.init(
            eventType: try container.decode(EventType.self, forKey: .eventType),
            data: try container.decode(EndContactEventDataDTO.self, forKey: .data)
        )
    }
}

extension EndContactEventDataDTO: Swift.Decodable {
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let threadContainer = try container.nestedContainer(keyedBy: ThreadCodingKeys.self, forKey: .thread)
        let contactContainer = try container.nestedContainer(keyedBy: ContactCodingKeys.self, forKey: .contact)
        
        self.init(
            thread: try threadContainer.decode(String.self, forKey: .idOnExternalPlatform),
            contact: try contactContainer.decode(String.self, forKey: .id)
        )
    }
}
