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

/// The different types of elements that can be present in the content of a message.
public enum PluginMessageType {
    
    /// A gallery plugin message type. It contains list of other plugin message elements.
    case gallery([PluginMessageType])
    
    /// A menu plugin message type.
    case menu(PluginMessageMenu)
    
    /// A text and buttons plugin message type.
    case textAndButtons(PluginMessageTextAndButtons)
    
    /// A quick replies plugin message type.
    case quickReplies(PluginMessageQuickReplies)
    
    /// A satisfaction survey plugin message type.
    case satisfactionSurvey(PluginMessageSatisfactionSurvey)
    
    /// A custom plugin message type.
    case custom(PluginMessageCustom)
    
    /// A plugin with directly used sub elements, e.g. buttons, files etc.
    case subElements([PluginMessageSubElementType])
}
