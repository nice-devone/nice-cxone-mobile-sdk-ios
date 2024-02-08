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

/// A button subelement.
public struct PluginMessageButton {
    
    // MARK: - Properties
    
    /// The unique identifier of the subelement.
    public let id: String
    
    /// The content of the sub element.
    public let text: String
    
    /// The postback of the sub element.
    public let postback: String?
    
    /// The URL which can lead to the external browser/webview or might contain a deeplink.
    ///
    /// Deeplink is associated with a specific application,
    /// for example you might want to use it to redirect the user directly to a Facebook profile or perform other similar action.
    public let url: URL?
    
    /// Determines if URL should be displayed in the current context of application.
    public let displayInApp: Bool
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - id: The unique identifier of the subelement.
    ///   - text: The content of the sub element.
    ///   - postback: The postback of the sub element.
    ///   - url: The URL which can lead to the external browser/webview or contain deeplink.
    public init(id: String, text: String, postback: String?, url: URL?, displayInApp: Bool) {
        self.id = id
        self.text = text
        self.postback = postback
        self.url = url
        self.displayInApp = displayInApp
    }
}
