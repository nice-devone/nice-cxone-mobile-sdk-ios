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

extension Data {
    
    // MARK: - Properties
    
    /// Converts to the String with UTF8 encoding.
    var utf8string: String? {
        String(data: self, encoding: .utf8)
    }
    
    // MARK: - Methods
    
    /// Decodes the data to be used.
    ///
    /// - Returns: The decoded data.
    func decode<T>() throws -> T where T: Decodable {
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(T.self, from: self)
        } catch {
            if let anotherError = try? decoder.decode(ServerError.self, from: self) {
                throw anotherError
            }
            
            throw error
        }
    }
}
