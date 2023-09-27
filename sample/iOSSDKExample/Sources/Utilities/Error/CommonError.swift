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

enum CommonError: LocalizedError {
    case failed(String)
    case error(Error)
    
    var localizedDescription: String {
        switch self {
        case .error(let error):
            return error.localizedDescription
        case .failed(let message):
            return message
        }
    }
}

// MARK: - Internal merohds

extension CommonError {
    
    static func unableToParse(_ parameter: String, from data: Any? = nil) -> CommonError {
        if let data = data {
            return .failed("Unable to parse '\(parameter)' from: \(data).")
        } else {
            return .failed("Unable to parse '\(parameter)'.")
        }
        
    }
    
    func logError() {
        Log.error(self)
    }
}
