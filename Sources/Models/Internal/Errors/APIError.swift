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

struct APIError {
    
    let errorCode: APIErrorCode
    let errorMessage: String
}

// MARK: - Decodable

extension APIError: Decodable {
    
    enum CodingKeys: CodingKey {
        case error
    }
    
    enum ErrorCodingKeys: CodingKey {
        case errorCode
        case errorMessage
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let errorContainer = try container.nestedContainer(keyedBy: ErrorCodingKeys.self, forKey: .error)
        
        self.errorMessage = try errorContainer.decode(String.self, forKey: .errorMessage)
        
        guard let errorCode = APIErrorCode(rawValue: try errorContainer.decode(String.self, forKey: .errorCode)) else {
            throw DecodingError.dataCorruptedError(forKey: .errorCode, in: errorContainer, debugDescription: "Invalid error code")
        }
        
        self.errorCode = errorCode
    }
}
