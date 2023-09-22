import CXoneChatSDK
import Foundation

extension Array where Element == ChatThread {
    
    func thread(by id: UUID) -> ChatThread? {
        self.first { $0.id == id }
    }
    
    func index(of id: UUID) -> Int? {
        self.firstIndex { $0.id == id }
    }
}

extension Array {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
