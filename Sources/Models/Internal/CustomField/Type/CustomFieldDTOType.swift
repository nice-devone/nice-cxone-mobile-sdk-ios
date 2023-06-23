import Foundation


enum CustomFieldDTOType: Equatable {
    
    // MARK: - Cases
    
    case textField(CustomFieldTextFieldDTO)
    
    case selector(CustomFieldSelectorDTO)
    
    case hierarchical(CustomFieldHierarchicalDTO)
    
    
    // MARK: - Properties
    
    var ident: String {
        switch self {
        case .textField(let entity):
            return entity.ident
        case .selector(let entity):
            return entity.ident
        case .hierarchical(let entity):
            return entity.ident
        }
    }
    
    var updatedAt: Date {
        switch self {
        case .textField(let entity):
            return entity.updatedAt
        case .selector(let entity):
            return entity.updatedAt
        case .hierarchical(let entity):
            return entity.updatedAt
        }
    }
    
    var value: String? {
        switch self {
        case .textField(let entity):
            return entity.value
        case .selector(let entity):
            return entity.value
        case .hierarchical(let entity):
            return entity.value
        }
    }
    
    
    // MARK: - Methods
    
    mutating func updateValue(_ value: String) {
        switch self {
        case .textField(let entity):
            self = .textField(
                CustomFieldTextFieldDTO(ident: entity.ident, label: entity.label, value: value, updatedAt: entity.updatedAt, isEmail: entity.isEmail)
            )
        case .selector(let entity):
            self = .selector(
                CustomFieldSelectorDTO(ident: entity.ident, label: entity.label, value: value, updatedAt: entity.updatedAt, options: entity.options)
            )
        case .hierarchical(let entity):
            self = .hierarchical(
                CustomFieldHierarchicalDTO(ident: entity.ident, label: entity.label, value: value, updatedAt: entity.updatedAt, nodes: entity.nodes)
            )
        }
    }
    
    mutating func updateUpdatedAt(_ updatedAt: Date) {
        switch self {
        case .textField(let entity):
            self = .textField(
                CustomFieldTextFieldDTO(ident: entity.ident, label: entity.label, value: entity.value, updatedAt: updatedAt, isEmail: entity.isEmail)
            )
        case .selector(let entity):
            self = .selector(
                CustomFieldSelectorDTO(ident: entity.ident, label: entity.label, value: entity.value, updatedAt: updatedAt, options: entity.options)
            )
        case .hierarchical(let entity):
            self = .hierarchical(
                CustomFieldHierarchicalDTO(ident: entity.ident, label: entity.label, value: entity.value, updatedAt: updatedAt, nodes: entity.nodes)
            )
        }
    }
}


// MARK: - Decodable

extension CustomFieldDTOType: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let textfield = try? container.decode(CustomFieldTextFieldDTO.self) {
            self = .textField(textfield)
        } else if let selector = try? container.decode(CustomFieldSelectorDTO.self) {
            self = .selector(selector)
        } else if let hierarchical = try? container.decode(CustomFieldHierarchicalDTO.self) {
            self = .hierarchical(hierarchical)
        } else {
            throw DecodingError.valueNotFound(CustomFieldDTOType.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "type"))
        }
    }
}
