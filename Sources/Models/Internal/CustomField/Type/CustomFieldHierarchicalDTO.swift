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

struct CustomFieldHierarchicalDTO: Sendable {
    
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
    
    /// Builds a hierarchical tree of `CustomFieldHierarchicalNodeDTO` from a flat list of `NodeDTO`.
    ///
    /// This implementation performs a single pass over the input, lazily creating nodes as they are
    /// encountered and immediately attaching them to their parent when a `parentId` is present.
    /// Root nodes (those with no `parentId`) are collected and returned.
    ///
    /// - Parameter values: Flat list of nodes containing a `name`, `value`, and optional `parentId`.
    /// - Returns: An array of root-level `CustomFieldHierarchicalNodeDTO` representing the forest.
    ///
    /// - Complexity: O(n) expected time and O(n) space, where n is `values.count`.
    ///
    /// - Note: If a node references a `parentId` that has not yet been encountered, a placeholder parent
    ///   (with the parent's `key` and empty `value`) is created so that the relationship is preserved
    ///   when/if the actual parent appears later in the input. If multiple nodes share the same `name`,
    ///   the last one encountered will overwrite the previous entry in the lookup dictionary.
    static func decodeNodes(from values: [NodeDTO]) -> [CustomFieldHierarchicalNodeDTO] {
        // Phase 1: collect flat data — separate relationship tracking from struct construction
        // so that updating a child's children doesn't require updating all ancestor copies
        // (which would be needed with value-type structs built incrementally).
        var nodeValues = [String: String]()           // name → value
        var childrenOf = [String: [String]]()        // parentName → ordered child names
        var rootNames = [String]()
        var seenRootNames = Set<String>()            // O(1) deduplication for rootNames

        nodeValues.reserveCapacity(values.count)

        for node in values {
            nodeValues[node.name] = node.value

            if let parentId = node.parentId {
                childrenOf[parentId, default: []].append(node.name)
            } else if seenRootNames.insert(node.name).inserted {
                rootNames.append(node.name)
            }
        }

        // Phase 2: recursively build the tree from the final relationship snapshot.
        func build(_ name: String) -> CustomFieldHierarchicalNodeDTO? {
            guard let value = nodeValues[name] else {
                return nil
            }
            
            return CustomFieldHierarchicalNodeDTO(
                key: name,
                value: value,
                children: (childrenOf[name] ?? []).compactMap { build($0) }
            )
        }

        return rootNames.compactMap { build($0) }
    }
}

private extension [CustomFieldHierarchicalNodeDTO] {

    func add(child: Element, to id: String) -> [CustomFieldHierarchicalNodeDTO] {
        map { node in
            if node.key == id {
                return node.add(child: child)
            } else if node.find(by: id) != nil {
                return CustomFieldHierarchicalNodeDTO(
                    key: node.key,
                    value: node.value,
                    children: node.children.add(child: child, to: id)
                )
            } else {
                return node
            }
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
