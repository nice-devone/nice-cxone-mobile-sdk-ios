import Foundation


extension String {
    
    // MARK: - Properties
    
    var formattedJSON: String? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted])
            
            guard let prettyPrintedString = String(data: data, encoding: .utf8) else {
                return nil
            }
            
            return prettyPrintedString
        } catch {
            error.logError()
            return nil
        }
    }
    
    
    // MARK: - Methods
    
    func substring(from: String) -> String? {
        guard let range = self.range(of: from) else {
            return nil
        }
        
        return String(self[range.upperBound...])
    }
    
    func substring(to: String) -> String? {
        guard let range = self.range(of: to) else {
            return nil
        }
        
        return String(self[..<range.lowerBound])
    }
    
    func substring(from: String, to: String) -> String? {
        guard let range = self.range(of: from) else {
            return nil
        }
        
        let subString = String(self[range.upperBound...])
        
        guard let range = subString.range(of: to) else {
            return nil
        }
        
        return String(subString[..<range.lowerBound])
    }
}
