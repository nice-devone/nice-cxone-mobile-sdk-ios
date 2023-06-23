import Foundation


struct CustomFieldTextFieldDTO {
    
    // MARK: - Properties
    
    let ident: String
    
    let label: String
    
    let value: String?
    
    let updatedAt: Date
    
    let isEmail: Bool
    
    
    // MARK: - Init
    
    init(ident: String, label: String, value: String?, updatedAt: Date, isEmail: Bool) {
        self.ident = ident
        self.label = label
        self.value = value
        self.updatedAt = updatedAt
        self.isEmail = isEmail
    }
}


// MARK: - Equatable

extension CustomFieldTextFieldDTO: Equatable {
    
    static func == (lhs: CustomFieldTextFieldDTO, rhs: CustomFieldTextFieldDTO) -> Bool {
        lhs.ident == rhs.ident
            && lhs.label == rhs.label
            && lhs.value == rhs.value
            && Calendar.current.compare(lhs.updatedAt, to: rhs.updatedAt, toGranularity: .second) == .orderedSame
            && lhs.isEmail == rhs.isEmail
    }
}


// MARK: - Decodable

extension CustomFieldTextFieldDTO: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case ident
        case label
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.ident = try container.decode(String.self, forKey: .ident)
        self.label = try container.decode(String.self, forKey: .label)
        self.value = nil
        self.updatedAt = .distantPast
        
        switch try container.decode(String.self, forKey: .type) {
        case "text":
            self.isEmail = false
        case "email":
            self.isEmail = true
        default:
            throw DecodingError.valueNotFound(Bool.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "type"))
        }
    }
}
