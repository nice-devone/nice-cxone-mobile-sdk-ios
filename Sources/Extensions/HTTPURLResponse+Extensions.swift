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

extension HTTPURLResponse {
    
    func log(data: Data?, file: StaticString = #file, line: UInt = #line) {
        guard let urlString = url?.absoluteString else {
            return
        }
        
        var output = "[RESPONSE] \(statusCode) \(urlString)\n"
        
        if !allHeaderFields.isEmpty {
            output += "Headers: {\n"
            for (key, value) in allHeaderFields {
                output += "  \(key): \(value)\n"
            }
            output += "}\n"
        }
        
        if let data, let formattedJSON = data.utf8string?.formattedJSON {
            output += "Body: \(formattedJSON)\n"
        }
        
        LogManager.info(output, file: file, line: line)
    }
}
