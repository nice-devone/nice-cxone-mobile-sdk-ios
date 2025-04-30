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

import Combine
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

// MARK: - Array + ChatThread

extension Array where Element == ChatThread {

    /// Returns `ChatThread` based on given thread ID.
    /// - Parameter threadId: The unique id of the thread.
    /// - Returns: `ChatThread`, if it exists.
    func getThread(with threadId: UUID) -> ChatThread? {
        self.first { $0.id == threadId }
    }
    
    /// Returns Index of thread based on given thread ID.
    /// - Parameter threadId: The unique id of the thread.
    /// - Returns: Index of found thread.
    func index(of threadId: UUID) -> Int? {
        self.firstIndex { $0.id == threadId }
    }
}

// MARK: - Array + CustomFieldDTO

extension Array where Element == CustomFieldDTO {

    mutating func merge(with array: Array) {
        var result = self
        
        for newEntry in array {
            if let oldEntry = self.first(where: { $0.ident == newEntry.ident }) {
                result.remove(oldEntry)
                result.append(newEntry.updatedAt > oldEntry.updatedAt ? newEntry : oldEntry)
            } else {
                result.append(newEntry)
            }
        }
        
        self = result
    }
}

// MARK: - Array + AnyCancellable

extension Array where Element: AnyCancellable {

    mutating func cancel() {
        forEach {
            $0.cancel()
        }
        
        removeAll()
    }
}
