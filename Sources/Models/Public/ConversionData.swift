import Foundation


/// Data to be sent on a conversion visitor event.
public struct ConversionData {
    
    /// The type of conversion.
    let type: String
    
    /// The value for the conversion.
    let value: Double
    
    /// The timestamp for the conversion.
    let timeWithMilliseconds: String
}
