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

extension URLRequest {

    // MARK: - Properties

    private static let headerContentType = "Content-Type"
    private static let headerPlatform = "x-sdk-platform"
    private static let headerVersion = "x-sdk-version"

    // MARK: - Init
    
    init(url: URL, method: HTTPMethod, contentType: String? = nil) {
        self.init(url: url)
        
        httpMethod = method.rawValue
        setValue("ios", forHTTPHeaderField: Self.headerPlatform)
        setValue(CXoneChatSDKModule.version, forHTTPHeaderField: Self.headerVersion)
        
        if let contentType {
            setValue(contentType, forHTTPHeaderField: Self.headerContentType)
        }
    }
    
    // MARK: - Methods
    
    func log(file: StaticString = #file, line: UInt = #line) {
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
        
        if let formattedJSON = httpBody?.formattedJSON {
            output += "Body: \(formattedJSON)\n"
        }
        
        LogManager.info(output, file: file, line: line)
    }
}

// MARK: - Helpers

private extension Data {
    
    var formattedJSON: String? {
        if var dictionary = try? JSONDecoder().decode([String: String].self, from: self), dictionary["content"] != nil {
            // Content is used for uploading attachments and logging base64EncodedString causes Xcode lagging
            dictionary.updateValue("base64EncodedString", forKey: "content")
            
            let json = dictionary.reduce(into: "") { partialResult, element in
                partialResult += "\n    \"\(element.key)\": \"\(element.value)\""
            }
            
            return "{\(json)\n}"
        } else {
            return self.utf8string?.formattedJSON
        }
    }
}
