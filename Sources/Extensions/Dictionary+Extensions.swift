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

// MARK: - Dictionary<String, String>

extension Dictionary<String, String> {
    
    func mapDefinitions(_ customFieldDefinitions: [CustomFieldDTOType], currentDate: Date, error: CXoneChatError) -> [CustomFieldDTOType] {
        compactMap { customField -> CustomFieldDTOType? in
            guard var newField = customFieldDefinitions.first(where: { $0.ident == customField.key }) else {
                LogManager.warning(error)
                return nil
            }
            
            newField.updateValue(customField.value)
            newField.updateUpdatedAt(currentDate)
            
            return newField
        }
    }
}
