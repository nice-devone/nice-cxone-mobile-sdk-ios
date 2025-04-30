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

/// The different types of elements that can be present in the content of a dynamic pre-chat survey.
///
/// Each type represents different UI element which is necessary to implement in the integration application.
/// Also, each element contains attribute `isRequired` which determines if it is necessary
/// pass filled values with method ``ContactCustomFieldsProvider/set(_:for:)``.
///
/// - Warning: If ``ChannelConfiguration`` contains some pre-chat survey elements
/// and application did not pass then with method ``ContactCustomFieldsProvider/set(_:for:)``
/// SDK throws an ``CXoneChatError/missingPreChatCustomFields``.
public enum CustomFieldType: Equatable {
    
    /// A textfield element which contains simple textfield or e-mail.
    ///
    /// In case of e-mail, BE requires proper e-mail validation on the application side.
    case textField(CustomFieldTextField)
    
    /// A list/selector element type. It contains list of options which are selected via dropdown picker, table or related UI element.
    case selector(CustomFieldSelector)
    
    /// complex type with subelements represented as a tree data structure.
    case hierarchical(CustomFieldHierarchical)
}
