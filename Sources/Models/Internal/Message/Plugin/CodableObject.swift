import Foundation


indirect enum CodableObject {
    
    case int(Int)
    
    case double(Double)
    
    case string(String)
    
    case bool(Bool)
    
    case dictionary([String: CodableObject])
    
    case array([CodableObject])
}


// MARK: - Codable

extension CodableObject: Codable {
    
    init(from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        
        if let value = try? singleValueContainer.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? singleValueContainer.decode(String.self) {
            self = .string(value)
        } else if let value = try? singleValueContainer.decode(Int.self) {
            self = .int(value)
        } else if let value = try? singleValueContainer.decode(Double.self) {
            self = .double(value)
        } else if let value = try? singleValueContainer.decode([String: CodableObject].self) {
            self = .dictionary(value)
        } else if let value = try? singleValueContainer.decode([CodableObject].self) {
            self = .array(value)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "CodableObject"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        
        switch self {
        case .int(let value):
            try singleValueContainer.encode(value)
        case .double(let value):
            try singleValueContainer.encode(value)
        case .string(let value):
            try singleValueContainer.encode(value)
        case .bool(let value):
            try singleValueContainer.encode(value)
        case .dictionary(let value):
            try singleValueContainer.encode(value)
        case .array(let value):
            try singleValueContainer.encode(value)
        }
    }
}


// MARK: - Convenience

extension CodableObject {
    
    var string: String? {
        guard case .string(let value) = self else {
            return nil
        }
        
        return value
    }
    
    var double: Double? {
        guard case .double(let value) = self else {
            return nil
        }
        
        return value
    }
    
    var bool: Bool? {
        guard case .bool(let value) = self else {
            return nil
        }
        
        return value
    }
    
    var dictionary: [String: CodableObject]? {
        guard case .dictionary(let value) = self else {
            return nil
        }
        
        return value
    }
    
    var array: [CodableObject]? {
        guard case .array(let value) = self else {
            return nil
        }
        
        return value
    }
}
