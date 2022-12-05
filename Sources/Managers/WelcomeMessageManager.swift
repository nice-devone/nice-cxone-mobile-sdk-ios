import Foundation


enum WelcomeMessageManager {
    
    // MARK: - Properties
    
    private static let fallbackDelimiter = "|"
    private static let openingParam = "{{"
    private static let closingParam = "}}"
    private static let contactFieldsSegment = "contact.customFields."
    private static let customFieldsSegment = "customer.customFields."
    
    
    // MARK: - Methods
    
    static func parse(_ message: String, with customFields: [String: String], customer: CustomerIdentityDTO) -> String {
        guard message.contains(Self.openingParam), message.contains(Self.closingParam) else {
            return message
        }
        
        let parameters = customFields.merge(with: customer.credentialParameters)
        var result = message
            .replacingOccurrences(of: contactFieldsSegment, with: "")
            .replacingOccurrences(of: customFieldsSegment, with: "")
        
        result
            .filterVariables()
            .forEach { element in
                if element.contains(fallbackDelimiter) {
                    if let field = parameters.first(where: { $0.key == element.substring(from: openingParam, to: fallbackDelimiter) }),
                       !field.value.isEmpty {
                        result = result.replacingOccurrences(of: element, with: field.value)
                    } else if let fallbackValue = element.substring(from: fallbackDelimiter, to: closingParam) {
                        result = result.replacingOccurrences(of: element, with: fallbackValue)
                    }
                } else {
                    if let field = parameters.first(where: { $0.key == element.substring(from: openingParam, to: closingParam) }),
                       !field.value.isEmpty {
                        result = result.replacingOccurrences(of: element, with: field.value)
                    }
                }
            }
        
        return result
    }
}


// MARK: - Helpers

private extension String {
    
    func filterVariables() -> [String] {
        var text = self
        var result = [String]()
        
        while text.substring(from: "{{", to: "}}") != nil {
            guard let substring = text.substring(from: "{{", to: "}}") else {
                continue
            }
            
            let newValue = "{{\(substring)}}"
            text = text.replacingOccurrences(of: newValue, with: "")
            result.append(newValue)
        }
        
        return result
    }
}

private extension CustomerIdentityDTO {
    
    var credentialParameters: [String: String] {
        let firstName = self.firstName ?? ""
        let lastName = self.lastName ?? ""
        
        return [
            "customer.firstName": firstName,
            "customer.lastName": lastName,
            "customer.fullName": "\(firstName) \(lastName)"
        ]
    }
}
