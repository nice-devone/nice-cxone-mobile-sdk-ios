import Foundation


// MARK: - Collection+CustomFieldDTO

extension Collection where Element == CustomFieldDTO {
    
    func toDictionary() -> [String: String] {
        var result = [String: String]()
        
        self.forEach { customField in
            result[customField.ident] = customField.value
        }
        
        return result
    }
}
