import Foundation


extension Data {
    
    // MARK: - Properties
    
    /// Converts to the String with UTF8 encoding.
    var utf8string: String {
        String(data: self, encoding: .utf8) ?? ""
    }
    
    
    // MARK: - Methods
    
    /// Decodes the data to be used.
    ///
    /// - Returns: The decoded data.
    func decode<T>() throws -> T where T: Codable {
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(T.self, from: self)
        } catch {
            if let anotherError = try? decoder.decode(ServerError.self, from: self) {
                throw anotherError
            }
            
            throw error
        }
    }
}
