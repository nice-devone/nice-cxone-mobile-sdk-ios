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

enum MessageParameter: String {
    case isBeginLiveChatConversation = "isInitialMessage"
    case isUnsupportedMessageTypeAnswer
    case isInactivityPopupAnswer
}

/// All info about a message payload.
struct MessagePayloadDTO: Equatable {
    
    // MARK: - Properties
    
    /// The content of the payload.
    let text: String
    
    /// Optional parameters
    let parameters: [String: AnyValue]
    
    /// The postback of the payload.
    let postback: String?
    
    // MARK: - Init
    
    init(text: String, postback: String?, parameters: [String: AnyValue]) {
        self.text = text
        self.postback = postback
        self.parameters = parameters
    }
    
    init(text: String, postback: String?, parameters: [MessageParameter: AnyValue]) {
        self.text = text
        self.postback = postback
        self.parameters = parameters.reduce(into: [String: AnyValue]()) { partialResult, parameter in
            partialResult[parameter.key.rawValue] = parameter.value
        }
    }
}
