import Foundation

/// Data to be sent on a conversion visitor event.
struct ConversionData: Codable {
    
    /// The type of conversion.
    public let conversionType: String
    
    /// The value for the conversion.
    public let conversionValue: Double
    
    /// The timestamp for the conversion.
    public let conversionTimeWithMilliseconds: String
}
