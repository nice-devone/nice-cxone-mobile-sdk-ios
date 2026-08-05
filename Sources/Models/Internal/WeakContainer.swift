//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneGuideUtility
import Foundation

/// A reference-type wrapper that holds a weak reference to an `AnyObject` instance.
///
/// Use `WeakContainer` when you need to store weak references in collections such as arrays
/// or `SafeAccessContainer`. As a `final class`, it has stable reference identity — copying
/// the container does not duplicate the weak-reference slot, ensuring that all holders
/// observe the same liveness state.
///
/// `@unchecked Sendable` is safe here because `SafeAccessContainer` serialises all
/// access to collections of `WeakContainer`, so the `weak var` slot is never accessed
/// from multiple threads simultaneously without external synchronisation.
final class WeakContainer<Object: AnyObject>: @unchecked Sendable {

    // MARK: - Properties

    private(set) weak var object: Object?

    // MARK: - Init

    init(_ object: Object? = nil) {
        self.object = object
    }
}
