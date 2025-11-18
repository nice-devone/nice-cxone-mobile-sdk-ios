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

extension URLSessionProtocol {

    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    @discardableResult
    func fetch(from url: URL, file: StaticString = #file, line: UInt = #line) async throws -> (Data, URLResponse) {
        let request = URLRequest(url: url, method: .get)

        return try await fetch(for: request, file: file, line: line)
    }
    
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    @discardableResult
    func fetch(
        for request: URLRequest,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> (Data, URLResponse) {
        request.log(file: file, line: line)
        
        do {
            let (data, response) = try await data(for: request)
            
            if let response = response as? HTTPURLResponse {
                response.log(data: data, file: file, line: line)
            }
                        
            if let apiError = try? JSONDecoder().decode(APIError.self, from: data), apiError.errorCode == .sdkVersionNotSupported {
                throw CXoneChatError.sdkVersionNotSupported
            }
            
            return (data, response)
        } catch {
            error.logError()
            
            throw error
        }
    }
}
