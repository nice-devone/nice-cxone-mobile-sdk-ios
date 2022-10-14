/// The different types of data on a visitor event.
public enum VisitorEventData: Encodable {
    
    /// Data for the page view event.
    case pageViewData(PageViewData)
    
    /// Data for the conversion event.
    case conversionData(ConversionData)
    
    /// Data for a proactive action event.
    case proactiveActionData(ProactiveActionDetails)
    
    /// Data for a custom visitor event. Any encoded string is accepted.
    case custom(String)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .pageViewData(let data):
            try container.encode(data)
        case .conversionData(let data):
            try container.encode(data)
        case .proactiveActionData(let data):
            try container.encode(data)
        case .custom(let string):
            try container.encode(string)
        }
    }
}
