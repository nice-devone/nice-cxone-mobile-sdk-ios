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

extension Dictionary {
    
    func merge(with dict: [Key: Value]) -> [Key: Value] {
        var mutableCopy = self
        
        for element in dict {
            mutableCopy[element.key] = element.value
        }
        
        return mutableCopy
    }
}

// MARK: - Dictionary<String, String>

extension Dictionary<String, String> {
    
    func mapDefinitions(_ customFieldDefinitions: [CustomFieldDTOType], currentDate: Date, error: CXoneChatError) -> [CustomFieldDTOType] {
        compactMap { customField -> CustomFieldDTOType? in
            guard var newField = customFieldDefinitions.first(where: { $0.ident == customField.key }) else {
                LogManager.warning(error)
                return nil
            }
            
            newField.updateValue(customField.value)
            newField.updateUpdatedAt(currentDate)
            
            return newField
        }
    }
}
