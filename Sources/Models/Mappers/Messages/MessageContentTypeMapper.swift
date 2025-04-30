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

enum MessageContentTypeMapper {
    
    static func map(_ entity: MessageContentDTOType) -> MessageContentType {
        switch entity {
        case .text(let entity):
            return .text(MessagePayloadMapper.map(entity))
        case .richLink(let entity):
            return .richLink(MessageRichLinkMapper.map(from: entity))
        case .quickReplies(let entity):
            return .quickReplies(MessageQuickRepliesMapper.map(from: entity))
        case .listPicker(let entity):
            return .listPicker(MessageListPickerMapper.map(from: entity))
        case .unknown:
            return .unknown
        }
    }
}
