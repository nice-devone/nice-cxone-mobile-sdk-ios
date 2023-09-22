import Foundation
import KeychainSwift

class KeychainSwiftMock: KeychainSwift {
    
    // MARK: - Properties
    
    private var data = [String: Data]()
    
    // MARK: - Methods
    
    override func set(_ value: Data, forKey key: String, withAccess access: KeychainSwiftAccessOptions? = nil) -> Bool {
        guard data.updateValue(value, forKey: key) != nil else {
            return false
        }
        
        return true
    }
    
    override func getData(_ key: String, asReference: Bool = false) -> Data? {
        data[key]
    }
}
