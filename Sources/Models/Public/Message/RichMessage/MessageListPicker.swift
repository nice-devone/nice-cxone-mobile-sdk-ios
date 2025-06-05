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

/// A list picker displays a list of items, and information about the items.
///
/// It is a list of options, that customers can choose multiple times and are persistent in the conversation.
/// The options/items are usually shown in overlay with richer formatting capabilities (icon, title, subtitle, sections, etc. in future)
/// and with a bigger count than buttons or quick replies.
public struct MessageListPicker: Equatable {
    
    /// Title of the List Picker in the conversation
    public let title: String
    
    /// Additional text to be displayed after clicking on the picker list
    public let text: String
    
    /// The list picker replies button options.
    public let buttons: [MessageSubElementType]
}
