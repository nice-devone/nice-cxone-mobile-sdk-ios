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

/// Enum representing different modes for chat functionality.
///
/// This enum defines various modes for chat operations, allowing customization based on specific use cases.
///
/// | Mode                            | Description
/// | ------------------------------ | -----------------------------------------------------
/// | ``singlethread`` | Indicates a single-threaded chat mode.
/// | ``multithread``   | Indicates a multi-threaded chat mode.
/// | ``liveChat``          | Indicates a live chat mode.
public enum ChatMode {
    
    /// Indicates a single-threaded chat mode.
    case singlethread

    /// Indicates a multi-threaded chat mode.
    case multithread

    /// Indicates a live chat mode.
    case liveChat
}
