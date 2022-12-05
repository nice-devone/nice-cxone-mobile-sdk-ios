import XCTest


extension XCTestCase {
    
    func loadStubFromBundle(withName name: String, extension: String) throws -> Data {
        let url = URL(forResource: name, type: `extension`)
        
        return try Data(contentsOf: url)
    }
}
