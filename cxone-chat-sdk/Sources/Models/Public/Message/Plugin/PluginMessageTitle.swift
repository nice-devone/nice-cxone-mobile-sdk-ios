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

/// A title subelement.
public struct PluginMessageTitle {
    
    // MARK: - Properties
    
    /// The unique identifier of the subelement.
    public let id: String
    
    /// The content of the sub element.
    public let text: String
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique identifier of the subelement.
    ///   - text: The content of the sub element.
    public init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}
