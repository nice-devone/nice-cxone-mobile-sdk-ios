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

enum InactivityPopupMapper {
    
    /// - Throws: ``CXoneChatError/invalidData`` if the message content type is not `.inactivityPopup`.
    static func map(from message: MessageDTO) throws -> InactivityPopup {
        guard case .inactivityPopup(let entity) = message.contentType else {
            throw CXoneChatError.invalidData
        }
        
        return InactivityPopup(
            title: entity.title.text,
            message: "\(entity.body.text) \(entity.callToAction.text)",
            numberOfSeconds: entity.countdown.numberOfSeconds,
            startedAt: entity.countdown.startedAt,
            threadId: message.threadIdOnExternalPlatform,
            refreshButton: InactivityPopupButton(from: entity.refreshButton),
            expireButton: InactivityPopupButton(from: entity.expireButton)
        )
    }
}

// MARK: - Helpers

private extension InactivityPopupButton {
    
    init(from entity: InactivityPopupButtonElementDTO) {
        self.init(
            id: entity.id,
            text: entity.text,
            postback: entity.postback
        )
    }
}
