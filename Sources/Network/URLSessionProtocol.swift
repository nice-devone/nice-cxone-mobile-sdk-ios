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
import Mockable

// MARK: - URLSessionProtocol

@Mockable
protocol URLSessionProtocol {
    /// Async load data from a remote URL specified by a URLRequest.
    ///
    /// - Parameter request: The URLRequest for which to load data.
    /// - Parameter delegate: Task-specific delegate.
    /// - Returns: Data and response.
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)

    /// Async load data from a remote URL specified by a URL.
    ///
    /// - Parameter url: The URL for which to load data.
    /// - Parameter delegate: Task-specific delegate.
    /// - Returns: Data and response.
    func data(from url: URL, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)

    /// Create a web socket task to an associated WSS: url.
    /// - Parameter with: URL to connect
    /// - Returns: connected ``URLSessionWebSocketTaskProtocol``
    func webSocketTask(with url: URL) -> URLSessionWebSocketTaskProtocol

    /// Create a ``WebSocketProtocol`` connected to the given url.
    /// - Parameter with: URL to connect
    /// - Returns: connected ``WebSocketProtocol``
    func webSocketProtocol(with url: URL) -> any WebSocketProtocol
}

extension URLSessionProtocol {
    /// Convenience method to load data using a URLRequest with no delegate.
    ///
    /// - Parameter request: The URLRequest for which to load data.
    /// - Parameter delegate: Task-specific delegate.
    /// - Returns: Data and response.
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }

    /// Convenience method to load data using a URLRequest with no delegate.
    ///
    /// - Parameter url: The URL for which to load data.
    /// - Parameter delegate: Task-specific delegate.
    /// - Returns: Data and response.
    public func data(from url: URL) async throws -> (Data, URLResponse) {
        try await data(from: url, delegate: nil)
    }

    /// Default implementation that wraps ``webSocketTask(with:)`` to create
    /// a connected ``WebSocketProtocol``
    /// Create a ``WebSocketProtocol`` connected to the given url.
    /// - Parameter with: URL to connect
    /// - Returns: connected ``WebSocketProtocol``
    func webSocketProtocol(with url: URL) -> any WebSocketProtocol {
        WebSocket(task: webSocketTask(with: url))
    }
}

// MARK: - URLSession + URLSessionProtocol

extension URLSession: URLSessionProtocol {
    /// Default implementation wraps base ``webSocketTask(with:)`` and casts
    /// the return value as our internal protocol.
    /// - Parameter with: URL to connect
    /// - Returns: connected ``URLSessionWebSocketTaskProtocol``
    func webSocketTask(with url: URL) -> any URLSessionWebSocketTaskProtocol {
        webSocketTask(with: url) as URLSessionWebSocketTask
    }
}
