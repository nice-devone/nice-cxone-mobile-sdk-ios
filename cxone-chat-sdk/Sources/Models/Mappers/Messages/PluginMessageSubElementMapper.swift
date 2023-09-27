//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

enum PluginMessageSubElementMapper {
    
    static func map(_ entity: PluginMessageSubElementDTOType) -> PluginMessageSubElementType {
        switch entity {
        case .text(let entity):
            return .text(
                PluginMessageText(id: entity.id, text: entity.text, mimeType: entity.mimeType)
            )
        case .button(let entity):
            return .button(
                PluginMessageButton(id: entity.id, text: entity.text, postback: entity.postback, url: entity.url, displayInApp: entity.displayInApp)
            )
        case .file(let entity):
            return .file(
                PluginMessageFile(id: entity.id, fileName: entity.fileName, url: entity.url, mimeType: entity.mimeType)
            )
        case .title(let entity):
            return .title(
                PluginMessageTitle(id: entity.id, text: entity.text)
            )
        }
    }
    
    static func map(_ entity: PluginMessageSubElementType) -> PluginMessageSubElementDTOType {
        switch entity {
        case .text(let entity):
            return .text(
                PluginMessageTextDTO(id: entity.id, text: entity.text, mimeType: entity.mimeType)
            )
        case .button(let entity):
            return .button(
                PluginMessageButtonDTO(id: entity.id, text: entity.text, postback: entity.postback, url: entity.url, displayInApp: entity.displayInApp)
            )
        case .file(let entity):
            return .file(
                
                PluginMessageFileDTO(id: entity.id, fileName: entity.fileName, url: entity.url, mimeType: entity.mimeType))
        case .title(let entity):
            return .title(
                PluginMessageTitleDTO(id: entity.id, text: entity.text)
            )
        }
    }
}
