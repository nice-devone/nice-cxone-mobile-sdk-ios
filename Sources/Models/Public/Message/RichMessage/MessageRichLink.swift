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

/// It is a URL link with an image preview and a defined title.
///
/// The customer is able to click on it to be forwarded to the particular page.
public struct MessageRichLink: Equatable {
    
    /// Title of the Rich Link in the conversation
    public let title: String
    
    /// URL link to the address we are linking to
    public let url: URL
    
    /// The image name that will be displayed in the rich link​ (256 KiB)
    public let fileName: String
    
    /// The image URL that will be displayed in the rich link​ (256 KiB)
    public let fileUrl: URL
    
    /// The image MIME type that will be displayed in the rich link​ (256 KiB)
    public let mimeType: String
}
