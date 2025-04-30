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

/// The different types of elements of message content.
public enum MessageContentType: Equatable {
    
    /// A basic text message.
    case text(MessagePayload)
    
    /// It is a URL link with an image preview and a defined title.
    ///
    /// The customer is able to click on it to be forwarded to the particular page.
    case richLink(MessageRichLink)
    
    /// Text message with buttons. After the customer clicks on one of the buttons, its content is sent as a reply.
    ///
    /// Usually, when a reply is sent, it is no more possible to click again on any button.
    case quickReplies(MessageQuickReplies)
    
    /// A list picker displays a list of items, and information about the items.
    ///
    /// It is a list of options, that customers can choose multiple times and are persistent in the conversation.
    /// The options/items are usually shown in overlay with richer formatting capabilities (icon, title, subtitle, sections, etc. in future)
    /// and with a bigger count than buttons or quick replies.
    case listPicker(MessageListPicker)
    
    /// An unknown content type.
    case unknown
}
