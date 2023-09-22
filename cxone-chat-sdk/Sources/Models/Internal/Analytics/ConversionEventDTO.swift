import Foundation

struct ConversionEventDTO {
    // MARK: - Properties
    let type: String
    let value: Double
    let timeStamp: Date
}

// MARK: - Encodable

extension ConversionEventDTO: Encodable {
    enum CodingKeys: String, CodingKey {
        case type = "conversionType"
        case value = "conversionValue"
        case timeStamp = "conversionTimeWithMilliseconds"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(value, forKey: .value)
        try container.encodeISODate(timeStamp, forKey: .timeStamp)
    }
}
