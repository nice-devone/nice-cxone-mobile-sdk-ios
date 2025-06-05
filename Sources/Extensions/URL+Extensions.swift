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

internal extension URL {

    // MARK: - Static Methods

    /// Access a resource which *may* be securely scoped.  
    ///
    /// Since there is no apparent way to determine whether a given URL is securely scoped or not,
    /// first try to access the resource without a secure scope.  If that fails back attempt to
    /// start a secure scope and attempt to retry the access.
    ///
    /// - parameters:
    ///     - access: routine to attempt resource access.  The return value of
    ///     this function will be further returned by `accessSecurelyScopedResource(access:)`.
    func accessSecurelyScopedResource<T>(access: (URL) throws -> T) rethrows -> T {
        do {
            return try access(self)
        } catch {
            guard startAccessingSecurityScopedResource() else {
                throw error
            }

            defer {
                stopAccessingSecurityScopedResource()
            }

            return try access(self)
        }
    }
}
