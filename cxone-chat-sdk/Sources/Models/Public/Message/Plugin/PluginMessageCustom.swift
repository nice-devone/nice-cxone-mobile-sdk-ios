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

/// A custom  plugin message type.
public struct PluginMessageCustom {
    
    // MARK: - Properties
    
    /// The unique identifier of the element.
    public let id: String
    
    /// Text to display in place of the UI element.
    public let text: String?
    
    /// Key-value pairs with content of the element.
    public let variables: [String: Any]
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique identifier of the element.
    ///   - text: Text to display in place of the UI element.
    ///   - variables: Key-value pairs with content of the element.
    public init(id: String, text: String?, variables: [String: Any]) {
        self.id = id
        self.text = text
        self.variables = variables
    }
}
