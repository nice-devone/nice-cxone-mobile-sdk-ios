import Foundation

/// The different types of data on a visitor event.
public enum VisitorEventDataType {
    
    /// Data for a custom visitor event. Any encoded string is accepted.
    case custom(String)
}

// MARK: - Encodable

extension VisitorEventDataType: Encodable {
    
    /// Encodes values into a native format for external representation.
    ///  - Parameter encoder: The type that can encode values.
    ///  - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
            case .custom(let string):
                try container.encode(string)
        }
    }
}
