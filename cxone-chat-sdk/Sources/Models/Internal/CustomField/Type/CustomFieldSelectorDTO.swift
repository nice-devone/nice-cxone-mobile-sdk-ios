import Foundation

struct CustomFieldSelectorDTO {
    
    // MARK: - Properties
    
    let ident: String
    
    let label: String
    
    let value: String?
    
    let updatedAt: Date
    
    let options: [String: String]
    
    // MARK: - Init
    
    init(ident: String, label: String, value: String?, updatedAt: Date, options: [String: String]) {
        self.ident = ident
        self.label = label
        self.value = value
        self.updatedAt = updatedAt
        self.options = options
    }
}

// MARK: - Equatable

extension CustomFieldSelectorDTO: Equatable {
    
    static func == (lhs: CustomFieldSelectorDTO, rhs: CustomFieldSelectorDTO) -> Bool {
        lhs.ident == rhs.ident
            && lhs.label == rhs.label
            && lhs.value == rhs.value
            && Calendar.current.compare(lhs.updatedAt, to: rhs.updatedAt, toGranularity: .second) == .orderedSame
            && lhs.options == rhs.options
    }
}

// MARK: - Decodable

extension CustomFieldSelectorDTO: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case ident
        case label
        case type
        case options = "values"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard try container.decode(String.self, forKey: .type) == "list" else {
            throw DecodingError.valueNotFound(String.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "type"))
        }
        
        self.ident = try container.decode(String.self, forKey: .ident)
        self.label = try container.decode(String.self, forKey: .label)
        self.value = nil
        self.updatedAt = .distantPast
        
        var options = [String: String]()
        try container
            .decode([[String: String]].self, forKey: .options)
            .forEach { entry in
                guard let name = entry["name"] else {
                    throw DecodingError.valueNotFound(String.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "value"))
                }
                guard let value = entry["value"] else {
                    throw DecodingError.valueNotFound(String.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "value"))
                }
                
                options[name] = value
            }
        
        self.options = options
    }
}
