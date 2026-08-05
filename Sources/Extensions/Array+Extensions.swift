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

// MARK: - Array

extension Array {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Array + Equatable

extension Array where Element: Equatable {

    mutating func remove(_ element: Element) {
        guard let index = firstIndex(where: { $0 == element }) else {
            return
        }

        remove(at: index)
    }
}

// MARK: - Array + ChatThreadService

extension Array where Element == ChatThreadService {

    /// Returns the `ChatThread` snapshot for the given thread ID, if any provider holds it.
    /// - Parameter threadId: The unique id of the thread.
    /// - Returns: The `ChatThread` snapshot, if found.
    func getThread(with threadId: String) -> ChatThread? {
        self.first { $0.chatThread.id == threadId }?.chatThread
    }
}

// MARK: - Array + CustomFieldDTO

extension Array where Element == CustomFieldDTO {

    /// Merges `array` into the receiver, keeping the most recently updated entry when both sides
    /// contain a field with the same `ident`.
    ///
    /// The receiver is first indexed into a dictionary keyed by `ident` (duplicates within the
    /// receiver are resolved by keeping the last occurrence). Each entry in `array` is then
    /// compared against the existing entry for the same `ident`: the one with the later
    /// `updatedAt` timestamp wins. Fields present only in `array` are added unconditionally.
    ///
    /// - Parameter array: The incoming fields to merge into the receiver.
    mutating func merge(with array: Array) {
        var byIdent = reduce(into: [String: CustomFieldDTO]()) { result, field in
            result[field.ident] = field
        }

        for newEntry in array {
            if let oldEntry = byIdent[newEntry.ident] {
                byIdent[newEntry.ident] = newEntry.updatedAt > oldEntry.updatedAt ? newEntry : oldEntry
            } else {
                byIdent[newEntry.ident] = newEntry
            }
        }

        // Preserve receiver order: walk `self` first (each element replaced by the dict winner),
        // then append new-only entries from `array` in arrival order.
        let existingIdents = Set(map { $0.ident })
        self = compactMap { byIdent[$0.ident] } + array.filter { !existingIdents.contains($0.ident) }
    }
}
