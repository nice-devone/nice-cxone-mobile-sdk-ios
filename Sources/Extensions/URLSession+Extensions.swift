//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

extension URLSession {
    
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    @discardableResult
    func data(from url: URL, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) async throws -> (Data, URLResponse) {
        LogManager.info("[REQUEST] " + url.absoluteString, fun: fun, file: file, line: line)
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                if let response = response as? HTTPURLResponse {
                    response.log(data: data, error: error, fun: fun, file: file, line: line)
                }
                
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (data, response))
            }
            
            task.resume()
        }
    }
    
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    @discardableResult
    func data(for request: URLRequest, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) async throws -> (Data, URLResponse) {
        request.log(fun: fun, file: file, line: line)
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                if let response = response as? HTTPURLResponse {
                    response.log(data: data, error: error, fun: fun, file: file, line: line)
                }
                
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (data, response))
            }
            
            task.resume()
        }
    }
}
