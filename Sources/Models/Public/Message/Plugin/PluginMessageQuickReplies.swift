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

/// A quick replies plugin message type.
public struct PluginMessageQuickReplies {
    
    // MARK: - Properties
    
    /// The unique identifier of the element.
    public let id: String
    
    /// The list of sub element components.
    ///
    /// In most cases, it will be a list of ``PluginMessageButton`` elements.
    /// However, it could also contain a ``PluginMessageText`` or ``PluginMessageTitle`` element
    /// to describe the content of the component.
    public let elements: [PluginMessageSubElementType]
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique identifier of the element.
    ///   - elements: The array of sub elements.
    public init(id: String, elements: [PluginMessageSubElementType]) {
        self.id = id
        self.elements = elements
    }
}
