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

/// describes the details of data attached to a `ContentDescriptor`
public enum ContentDescriptorSource {
    /// data is an array of bytes contained in a `Data` object
    case bytes(Data)
    /// data is referenced by URL
    case url(URL)
}

// MARK: - CustomStringConvertible

extension ContentDescriptorSource: CustomStringConvertible {
    public var description: String {
        switch self {
        case .bytes(let data):  return "ContentDescriptorSource.bytes(length=\(data.count))"
        case .url(let url):     return "ContentDescriptorSource.uri(uri=\(url))"
        }
    }
}
