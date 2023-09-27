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

extension String? {
    
    // MARK: - Properties
    
    var isNilOrEmpty: Bool {
        self?.isEmpty != false
    }
    
    // MARK: - Methods
    
    func mapNonEmpty(_ transform: (String) throws -> String) rethrows -> String? {
        try? self.map { value -> String in
            guard value != "" else {
                throw CommonError.unableToParse("value")
            }
            
            return value
        }
    }
}
