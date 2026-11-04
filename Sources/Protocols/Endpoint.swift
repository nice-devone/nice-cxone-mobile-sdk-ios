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

import Foundation

protocol Endpoint {
    
    var environment: EnvironmentDetails { get }
    
    var queryItems: [URLQueryItem] { get }
    
    var method: HTTPMethod { get }
    
    var url: URL? { get }
    
    // periphery:ignore - only EndpointTests calls urlRequest(); production builds the socket URL from SocketEndpointDTO.url
    func urlRequest() throws -> URLRequest
}

// MARK: - Helpers

extension Endpoint {
    
    var url: URL? {
        makeUrl(withBase: environment.chatURL)
    }
    
    /// The URL built from `baseURL` and this endpoint's `queryItems`.
    func makeUrl(withBase baseURL: String) -> URL? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = queryItems
        
        return components?.url
    }
    
    // periphery:ignore - only EndpointTests calls urlRequest(); production builds the socket URL from SocketEndpointDTO.url
    /// - Throws: ``CXoneChatError/invalidRequest`` if connection `url` is not set properly.
    func urlRequest() throws -> URLRequest {
        guard let url = self.url else {
            throw CXoneChatError.invalidRequest
        }
        
        return URLRequest(url: url, method: method)
    }
}
