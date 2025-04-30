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

enum MessageContentDTOType: Equatable {
    
    case text(MessagePayloadDTO)
        
    case richLink(MessageRichLinkDTO)
    
    case quickReplies(MessageQuickRepliesDTO)
    
    case listPicker(MessageListPickerDTO)
    
    case unknown
}

// MARK: - Codable

extension MessageContentDTOType: Codable {
    
    enum CodingKeys: CodingKey {
        case type
        case payload
        case postback
    }
    
    enum TextPayloadKeys: CodingKey {
        case text
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        switch try container.decode(ElementType.self, forKey: .type) {
        case .text:
            let payloadContainer = try container.nestedContainer(keyedBy: TextPayloadKeys.self, forKey: .payload)
            
            self = .text(
                MessagePayloadDTO(
                    text: try payloadContainer.decode(String.self, forKey: .text),
                    postback: try container.decodeIfPresent(String.self, forKey: .postback))
            )
        case .richLink:
            self = .richLink(try container.decode(MessageRichLinkDTO.self, forKey: .payload))
        case .quickReplies:
            self = .quickReplies(try container.decode(MessageQuickRepliesDTO.self, forKey: .payload))
        case .listPicker:
            self = .listPicker(try container.decode(MessageListPickerDTO.self, forKey: .payload))
        default:
            self = .unknown
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .text(let text):
            var payloadContainer = container.nestedContainer(keyedBy: TextPayloadKeys.self, forKey: .payload)
            
            try container.encode(ElementType.text.rawValue, forKey: .type)
            try payloadContainer.encode(text.text, forKey: .text)
            try container.encode(text.postback, forKey: .postback)
        case .richLink(let richLink):
            try container.encode(ElementType.richLink.rawValue, forKey: .type)
            try container.encode(richLink, forKey: .payload)
        case .quickReplies(let quickReplies):
            try container.encode(ElementType.quickReplies.rawValue, forKey: .type)
            try container.encode(quickReplies, forKey: .payload)
        case .listPicker(let listPicker):
            try container.encode(ElementType.listPicker.rawValue, forKey: .type)
            try container.encode(listPicker, forKey: .payload)
        case .unknown:
            break
        }
    }
}
