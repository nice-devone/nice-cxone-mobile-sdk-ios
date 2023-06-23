import Foundation


enum CustomFieldTypeMapper {
    
    static func map(from entity: CustomFieldDTOType) -> CustomFieldType {
        switch entity {
        case .textField(let entity):
            return .textField(
                CustomFieldTextField(ident: entity.ident, label: entity.label, value: entity.value, isEmail: entity.isEmail, updatedAt: entity.updatedAt)
            )
        case .selector(let entity):
            return .selector(
                CustomFieldSelector(ident: entity.ident, label: entity.label, value: entity.value, options: entity.options, updatedAt: entity.updatedAt)
            )
        case .hierarchical(let entity):
            return .hierarchical(
                CustomFieldHierarchical(
                    ident: entity.ident,
                    label: entity.label,
                    value: entity.value,
                    nodes: entity.nodes.map(CustomFieldHierarchicalNodeDTO.map),
                    updatedAt: entity.updatedAt
                )
            )
        }
    }
    
    static func map(from entity: CustomFieldType) -> CustomFieldDTOType {
        switch entity {
        case .textField(let entity):
            return .textField(
                CustomFieldTextFieldDTO(ident: entity.ident, label: entity.label, value: entity.value, updatedAt: entity.updatedAt, isEmail: entity.isEmail)
            )
        case .selector(let entity):
            return .selector(
                CustomFieldSelectorDTO(ident: entity.ident, label: entity.label, value: entity.value, updatedAt: entity.updatedAt, options: entity.options)
            )
        case .hierarchical(let entity):
            return .hierarchical(
                CustomFieldHierarchicalDTO(
                    ident: entity.ident,
                    label: entity.label,
                    value: entity.value,
                    updatedAt: entity.updatedAt,
                    nodes: entity.nodes.map(CustomFieldHierarchicalNodeDTO.map)
                )
            )
        }
    }
}


private extension CustomFieldHierarchicalNodeDTO {
    
    static func map(from entity: CustomFieldHierarchicalNodeDTO) -> CustomFieldHierarchicalNode {
        CustomFieldHierarchicalNode(value: entity.value, label: entity.label, children: entity.children.map(Self.map))
    }
    
    static func map(from entity: CustomFieldHierarchicalNode) -> CustomFieldHierarchicalNodeDTO {
        CustomFieldHierarchicalNodeDTO(value: entity.value, label: entity.label, children: entity.children.map(Self.map))
    }
}
