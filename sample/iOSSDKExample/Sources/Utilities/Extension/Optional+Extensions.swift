import Foundation

extension String? {
    
    // MARK: - Properties
    
    var isNilOrEmpty: Bool {
        self?.isEmpty != false
    }
    
    // MARK: - Methods
    
    func mapNonEmpty(_ transform: (String) throws -> String) rethrows -> String? {
        try? self.map { value -> String in
            guard value != "" else {
                throw CommonError.unableToParse("value")
            }
            
            return value
        }
    }
}
