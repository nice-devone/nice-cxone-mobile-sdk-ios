import Foundation


/// Data to be sent on a conversion visitor event.
struct ConversionDataDTO: Codable {
    
    /// The type of conversion.
    let conversionType: String
    
    /// The value for the conversion.
    let conversionValue: Double
    
    /// The timestamp for the conversion.
    let conversionTimeWithMilliseconds: String
}
