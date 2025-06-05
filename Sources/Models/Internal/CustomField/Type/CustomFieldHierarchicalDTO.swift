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

struct CustomFieldHierarchicalDTO {
    
    // MARK: - Properties
    
    let ident: String
    
    let label: String
    
    let value: String?
    
    let updatedAt: Date
    
    let nodes: [CustomFieldHierarchicalNodeDTO]
}

// MARK: - Equatable

extension CustomFieldHierarchicalDTO: Equatable {
    
    static func == (lhs: CustomFieldHierarchicalDTO, rhs: CustomFieldHierarchicalDTO) -> Bool {
        lhs.ident == rhs.ident
            && lhs.label == rhs.label
            && lhs.value == rhs.value
            && lhs.nodes == rhs.nodes
            && Calendar.current.compare(lhs.updatedAt, to: rhs.updatedAt, toGranularity: .second) == .orderedSame
    }
}

// MARK: - Decodable

extension CustomFieldHierarchicalDTO: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case ident
        case label
        case type
        case nodes = "values"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard try container.decode(String.self, forKey: .type) == "tree" else {
            throw DecodingError.valueNotFound(String.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "type"))
        }
        
        self.ident = try container.decode(String.self, forKey: .ident)
        self.label = try container.decode(String.self, forKey: .label)
        self.value = nil
        self.updatedAt = .distantPast
        self.nodes = Self.decodeNodes(from: try container.decode([NodeDTO].self, forKey: .nodes))
    }
}

// MARK: - Helpers

private extension CustomFieldHierarchicalDTO {
    
    static func decodeNodes(from values: [NodeDTO]) -> [CustomFieldHierarchicalNodeDTO] {
        var remaining = values
        var result = [CustomFieldHierarchicalNodeDTO]()
        
        while !remaining.isEmpty {
            let node = remaining.remove(at: 0)
            
            if let parentId = node.parentId {
                guard result.first(where: { $0.find(by: parentId) != nil }) != nil else {
                    remaining.append(node)
                    
                    continue
                }
                
                result.add(child: CustomFieldHierarchicalNodeDTO(key: node.name, value: node.value), to: parentId)
            } else {
                result.append(CustomFieldHierarchicalNodeDTO(key: node.name, value: node.value))
            }
        }
        
        return result
    }
}

private extension Array<CustomFieldHierarchicalNodeDTO> {

    func add(child: Element, to id: String) {
        self.forEach { node in
            node.find(by: id)?.add(child: child)
        }
    }
}

private extension CustomFieldHierarchicalNodeDTO {
    
    func find(by key: String) -> CustomFieldHierarchicalNodeDTO? {
        if self.key == key {
            return self
        }

        for child in children {
            if let match = child.find(by: key) {
                return match
            }
        }

        return nil
    }
}

// MARK: - NodeDTO

private struct NodeDTO: Decodable {
    
    // MARK: - Properties
    
    let name: String
    
    let value: String
    
    let parentId: String?
    
    // MARK: - Decodable
    
    enum CodingKeys: String, CodingKey {
        case name
        case value
        case parentId
    }
}
