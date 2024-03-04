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

class CustomFieldHierarchicalNodeDTO {
    
    // MARK: - Properties
    
    var value: String
    
    var label: String
    
    var children: [CustomFieldHierarchicalNodeDTO]
    
    // MARK: - Init
    
    init(value: String, label: String, children: [CustomFieldHierarchicalNodeDTO] = []) {
        self.value = value
        self.label = label
        self.children = children
    }
    
    // MARK: - Methods
    
    func add(child: CustomFieldHierarchicalNodeDTO) {
        children.append(child)
    }
}

// MARK: - Equatable

extension CustomFieldHierarchicalNodeDTO: Equatable {
    
    public static func == (lhs: CustomFieldHierarchicalNodeDTO, rhs: CustomFieldHierarchicalNodeDTO) -> Bool {
        lhs.value == rhs.value
            && lhs.label == rhs.label
            && lhs.value == rhs.value
            && lhs.children == rhs.children
    }
}
