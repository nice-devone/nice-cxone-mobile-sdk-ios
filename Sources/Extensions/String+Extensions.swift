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

extension String {
    
    // MARK: - Properties
    
    var formattedJSON: String? {
        guard !self.isEmpty, let data = self.data(using: .utf8) else {
            return nil
        }
        
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted])
            
            return String(decoding: data, as: UTF8.self)
        } catch {
            error.logError()
            return nil
        }
    }
    
    // MARK: - Methods
    
    func substring(from: String) -> String? {
        guard let range = self.range(of: from) else {
            return nil
        }
        
        return String(self[range.upperBound...])
    }
    
    func substring(to: String) -> String? {
        guard let range = self.range(of: to) else {
            return nil
        }
        
        return String(self[..<range.lowerBound])
    }
    
    func substring(from: String, to: String) -> String? {
        guard let range = self.range(of: from) else {
            return nil
        }
        
        let subString = String(self[range.upperBound...])
        
        guard let range = subString.range(of: to) else {
            return nil
        }
        
        return String(subString[..<range.lowerBound])
    }
    
    func mapNonEmpty(_ transform: (String) throws -> String) rethrows -> String? {
        guard self != "" else {
            return nil
        }
        
        return try? transform(self)
    }
    
    func nilIfEmpty() -> String? {
        isEmpty ? nil : self
    }
}
