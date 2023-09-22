import Foundation

// MARK: - Array

extension Array {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
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

extension [ChatThread] {
    
    /// Returns `ChatThread` based on given thread ID.
    /// - Parameter threadId: The unique id of the thread.
    /// - Returns: `ChatThread`, if it exists.
    func getThread(with threadId: UUID) -> ChatThread? {
        self.first { $0.id == threadId }
    }
    
    /// Returns `UUID` based on given thread ID.
    /// - Parameter threadId: The unique id of the thread.
    /// - Returns: `UUID` of found thread, if it exists.
    func getId(of threadId: UUID) -> UUID? {
        guard let id = self.first(where: { $0.id == threadId })?.id else {
            return nil
        }
        
        return id
    }
    
    /// Returns Index of thread based on given thread ID.
    /// - Parameter threadId: The unique id of the thread.
    /// - Returns: Index of found thread.
    func index(of threadId: UUID) -> Int? {
        self.firstIndex { $0.id == threadId }
    }
}

// MARK: - Array + CustomFieldDTOType

extension [CustomFieldDTOType] {
    
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
    
    func toDictionary() -> [String: String] {
        Dictionary(uniqueKeysWithValues: self.map { ($0.ident, $0.value ?? "") })
    }
}

// MARK: - Array + CustomFieldDTO

extension [CustomFieldDTO] {
    
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
