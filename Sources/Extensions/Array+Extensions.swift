import Foundation


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
