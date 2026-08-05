//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Foundation

struct CustomFieldHierarchicalNodeDTO: Sendable {
    
    // MARK: - Properties
    
    let key: String
    
    let value: String
    
    let children: [CustomFieldHierarchicalNodeDTO]
    
    // MARK: - Init
    
    init(key: String, value: String, children: [CustomFieldHierarchicalNodeDTO] = []) {
        self.key = key
        self.value = value
        self.children = children
    }
    
    // MARK: - Methods
    
    func add(child: CustomFieldHierarchicalNodeDTO) -> CustomFieldHierarchicalNodeDTO {
        var result = self.children
        result.append(child)
        
        return CustomFieldHierarchicalNodeDTO(key: self.key, value: self.value, children: result)
    }
}

// MARK: - Equatable

extension CustomFieldHierarchicalNodeDTO: Equatable {
    
    public static func == (lhs: CustomFieldHierarchicalNodeDTO, rhs: CustomFieldHierarchicalNodeDTO) -> Bool {
        lhs.key == rhs.key
            && lhs.value == rhs.value
            && lhs.children == rhs.children
    }
}
