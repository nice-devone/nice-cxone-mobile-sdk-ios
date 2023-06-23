import Foundation


/// Data to be sent on a conversion visitor event.
public struct ConversionData {
    
    /// The type of conversion.
    public let type: String
    
    /// The value for the conversion.
    public let value: Double
    
    /// The timestamp for the conversion.
    public let timeWithMilliseconds: String
}
