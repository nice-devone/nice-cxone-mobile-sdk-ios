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

/// Text message with buttons. After the customer clicks on one of the buttons, its content is sent as a reply.
///
/// Usually, when a reply is sent, it is no more possible to click again on any button.
/// You can have between two and five (depending on the channel) customizable choices,
/// and the user can select only a single item.
///
/// When a quick reply is tapped, the buttons are dismissed,
///  and the title of the tapped button is posted to the conversation as a message.
public struct MessageQuickReplies: Equatable {
    
    /// Title of the Quick Replies in the conversation
    public let title: String
    
    /// The quick replies button options.
    public let buttons: [MessageReplyButton]
}
