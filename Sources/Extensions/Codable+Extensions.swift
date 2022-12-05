import Foundation


// MARK: - KeyedDecodingContainer

extension KeyedDecodingContainer {
    
    func decodeISODate(forKey key: Key) throws -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withFullTime, .withTimeZone, .withColonSeparatorInTimeZone]
        
        let stringValue = try decode(String.self, forKey: key)
        
        guard let date = formatter.date(from: stringValue) else {
            throw DecodingError.valueNotFound(Date.self, .init(codingPath: codingPath, debugDescription: key.stringValue))
        }
        
        return date
    }
    
    func decodeISODateIfPresent(forKey key: Key) throws -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withFullTime, .withTimeZone, .withColonSeparatorInTimeZone]
        
        guard let stringValue = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        guard let date = formatter.date(from: stringValue) else {
            throw DecodingError.valueNotFound(Date.self, .init(codingPath: codingPath, debugDescription: key.stringValue))
        }
        
        return date
    }
}


// MARK: - KeyedEncodingContainer

extension KeyedEncodingContainer {
    
    mutating func encodeISODate(_ date: Date?, forKey key: Key) throws {
        guard let date = date else {
            return
        }
        
        let formatter = ISO8601DateFormatter()
        let string = formatter.string(from: date)
        
        try encode(string, forKey: key)
    }
    
    mutating func encodeISODateIfPresent(_ date: Date?, forKey key: Key) throws {
        guard let date = date else {
            return
        }
        
        let formatter = ISO8601DateFormatter()
        let string = formatter.string(from: date)
        
        try encodeIfPresent(string, forKey: key)
    }
}
