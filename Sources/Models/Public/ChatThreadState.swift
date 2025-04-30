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

/// Enum representing the possible states of a chat thread.
///
/// | State                       | Description
/// | ------------------------- | -----------------------------------------------------------------------------------------------------------------
/// | ``pending``       | Thread has been created locally.
/// | ``received``     | Thread has been received from the server (not yet loaded).
/// | ``loaded``         | Thread has been loaded (not yet recovered).
/// | ``ready``           | Thread has been prepared to use (loaded metadata and recovered all messages).
/// | ``closed``         | Thread has been archived or closed.
///
/// Each case corresponds to a specific state of the chat thread, providing clarity on its current status.
public enum ChatThreadState: Comparable {

    // MARK: - Cases
    
    /// Thread has been created locally
    case pending

    /// Thread has been received from the server (not yet loaded)
    case received

    /// Thread has been loaded (not yet recovered)
    case loaded

    /// Thread has been prepared to use (loaded metadata and recovered all messages)
    case ready

    /// Thread has been archived or closed
    case closed
    
    // MARK: - Properties
    
    /// Check if chat thread has been loaded
    ///
    /// - Attention: State is either ``loaded``, ``ready``or ``closed``.
    public var isLoaded: Bool {
        [.loaded, .ready, .closed].contains(self)
    }
}
