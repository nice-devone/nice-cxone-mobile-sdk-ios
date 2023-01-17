import Foundation


// MARK: - Array

extension Array {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
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
    
    /// Returns `UUID` based on given thread ID.
    /// - Parameter threadId: The unique id of the thread.
    /// - Returns: `UUID` of founded thread, if it exists.
    func getId(of threadId: UUID) -> String? {
        guard let id = self.first(where: { $0.id == threadId })?._id, !id.isEmpty else {
            return nil
        }
        
        return id
    }
    
    /// Returns Index of thread based on given thread ID.
    /// - Parameter threadId: The unique id of the thread.
    /// - Returns: Index of founded thread.
    func index(of threadId: UUID) -> Int? {
        self.firstIndex { $0.id == threadId }
    }
}


// MARK: - Array + CustomFieldDTO

extension Array where Element == CustomFieldDTO {
    
    mutating func update(with customFields: [CustomFieldDTO]) {
        self = customFields.map { newEntry in
            if let oldEntry = self.first(where: { $0.ident == newEntry.ident }) {
                return newEntry.updatedAt > oldEntry.updatedAt ? newEntry : oldEntry
            } else {
                return newEntry
            }
        }
    }
}
