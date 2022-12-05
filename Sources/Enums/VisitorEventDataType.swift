import Foundation


/// The different types of data on a visitor event.
public enum VisitorEventDataType: Encodable {
    
    /// Data for the page view event.
    case pageViewData(PageViewData)
    
    /// Data for the conversion event.
    case conversionData(ConversionData)
    
    /// Data for a proactive action event.
    case proactiveActionData(ProactiveActionDetails)
    
    /// Data for a custom visitor event. Any encoded string is accepted.
    case custom(String)

    
    // MARK: - Encoder
    
    /// Encodes values into a native format for external representation.
    ///  - Parameter encoder: The type that can encode values.
    ///  - Throws: ``EncodingError.invalidValue`` if the given value is invalid in the current context for this format.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .pageViewData(let data):
            try container.encode(data)
        case .conversionData(let data):
            try container.encode(ConversionDataMapper.map(data))
        case .proactiveActionData(let data):
            try container.encode(ProactiveActionDetailsMapper.map(data))
        case .custom(let string):
            try container.encode(string)
        }
    }
}
