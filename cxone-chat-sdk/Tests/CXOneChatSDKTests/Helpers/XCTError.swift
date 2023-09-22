import Foundation

struct XCTError: LocalizedError {
    
    // MARK: - Properties
    
    private var description: String
    
    var errorDescription: String? {
        description
    }
    
    var localizedDescription: String {
        description
    }
    
    // MARK: - Init
    
    init(_ description: String) {
        self.description = description
    }
}
