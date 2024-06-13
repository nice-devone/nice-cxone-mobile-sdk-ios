//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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
    
    /// Return a new URL by safely appending a path fragment.
    /// - parameters:
    ///     - lhs: base url to append to
    ///     - rhs: path component/fragment to append
    /// - returns a new url with `rhs` appended or nil if an error occurs.
    static func / (lhs: URL, rhs: String) -> URL? {
        guard var comps = URLComponents(url: lhs, resolvingAgainstBaseURL: true) else {
            return nil
        }

        comps.path = (comps.path as NSString).appendingPathComponent(rhs)

        return comps.url
    }

    /// Return a new URL by safely appending a collection of query parameters.
    /// - parameters:
    ///     - lhs: base URL
    ///     - rhs: query parameters to append
    /// - returns a new url with `rhs` appended as query parameters or nil if an error arises.
    static func & (lhs: URL, rhs: any Sequence<(String, String?)>) -> URL? {
        guard var comps = URLComponents(url: lhs, resolvingAgainstBaseURL: true) else {
            return nil
        }

        comps.queryItems = (comps.queryItems ?? []) + rhs.map { URLQueryItem(name: $0.0, value: $0.1) }

        return comps.url
    }

    /// Return a new URL by safely appending a single query parameter.
    /// - parameters:
    ///     - lhs: base URL
    ///     - rhs: query parameter to append
    /// - returns a new url with `rhs` appended as a query parameter or nil if an error arises.
    static func & (lhs: URL, rhs: (String, String?)) -> URL? {
        lhs & [rhs]
    }

    ///
    /// Access a resource which *may* be securely scoped.  Since there is no apparent
    /// way to determine whether a given URL is securely scoped or not, first try to
    /// access the resource without a secure scope.  If that fails back attempt to
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

extension URL? {
    /// Return a new URL by safely appending a string path fragment.
    /// - parameters:
    ///     - lhs: base url to append to
    ///     - rhs: path component/fragment to append
    /// - returns a new url with `rhs` appended or nil if lhs is nil or an error occurs.
    static func / (url: URL?, path: String) -> URL? {
        url.flatMap { $0 / path }
    }

    /// Return a new URL by safely appending an integer path fragment.
    /// - parameters:
    ///     - lhs: base url to append to
    ///     - rhs: path component/fragment to append
    /// - returns a new url with `rhs` appended or nil if lhs is nil or an error occurs.
    static func / (url: URL?, element: Int) -> URL? {
        url / "\(element)"
    }

    /// Return a new URL by safely appending a UUID fragment.
    /// - parameters:
    ///     - lhs: base url to append to
    ///     - rhs: path component/fragment to append
    /// - returns a new url with `rhs` appended or nil if lhs is nil or an error occurs.
    static func / (url: URL?, element: UUID) -> URL? {
        url / element.uuidString
    }

    /// Return a new URL by safely appending a single query parameter.
    /// - parameters:
    ///     - lhs: base URL
    ///     - rhs: query parameter to append
    /// - returns a new url with `rhs` appended as a query parameter or nil if the base url is nil or an error arises.
    static func & (url: URL?, queryItem: (String, String?)) -> URL? {
        url.flatMap { $0 & queryItem }
    }

    /// Return a new URL by safely appending a sequence of query parameters.
    /// - parameters:
    ///     - lhs: base URL
    ///     - rhs: query parameters to append
    /// - returns a new url with `rhs` appended as query parameters or nil if an error arises.
    static func & (url: URL?, queryItems: any Sequence<(String, String?)>) -> URL? {
        url.flatMap { $0 & queryItems }
    }
}
