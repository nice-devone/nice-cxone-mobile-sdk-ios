import Foundation


extension Dictionary {
    
    func merge(with dict: [Key: Value]) -> [Key: Value] {
        var mutableCopy = self
        
        for element in dict {
            mutableCopy[element.key] = element.value
        }
        
        return mutableCopy
    }
}
