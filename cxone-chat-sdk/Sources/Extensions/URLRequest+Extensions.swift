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

extension URLRequest {
    
    // MARK: - Init
    
    init(url: URL, method: HTTPMethod, contentType: String) {
        self.init(url: url)
        
        httpMethod = method.rawValue
        setValue(contentType, forHTTPHeaderField: "Content-Type")
    }
    
    // MARK: - Methods
    
    func log(fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        guard let urlString = url?.absoluteString else {
            return
        }
        var output = "[REQUEST]"
        
        output += httpMethod.map { method in
            " \(method) \(urlString)\n"
        } ?? " \(urlString)\n"
        
        if let allHTTPHeaderFields, !allHTTPHeaderFields.isEmpty {
            output += "Headers: {\n"
            
            for (key, value) in allHTTPHeaderFields {
                output += "  \(key): \(value)\n"
            }
            
            output += "}\n"
        }
        
        if let httpBody, let formattedJSON = String(data: httpBody, encoding: .utf8)?.formattedJSON {
            output += "Body: \(formattedJSON)\n"
        }
        
        LogManager.info(output, fun: fun, file: file, line: line)
    }
}
