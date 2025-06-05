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

/// A pre-chat survey field element which should be presented to user before chat thread is created.
public struct PreChatSurveyCustomField {
    
    /// Determines if it is necessary to fill out this custom field and send it via method ``ContactCustomFieldsProvider/set(_:for:)`` to the SDK.
    public let isRequired: Bool
    
    /// The type of element that can be present in the content of a dynamic pre-chat survey.
    public let type: CustomFieldType
}
