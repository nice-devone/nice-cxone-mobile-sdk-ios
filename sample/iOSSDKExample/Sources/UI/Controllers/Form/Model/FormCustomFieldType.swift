import CXoneChatSDK

enum FormCustomFieldType {
    
    // MARK: - Cases
    
    case textField(FormTextFieldEntity)
    
    case list(FormListFieldEntity)
    
    case tree(FormTreeFieldEntity)
    
    // MARK: - Init
    
    init(from entity: PreChatSurveyCustomField, with customFields: [String: String]? = nil) {
        switch entity.type {
        case .textField(let textField):
            let value = customFields?[textField.ident]
            
            self = .textField(
                FormTextFieldEntity(label: textField.label, ident: textField.ident, value: value, isRequired: entity.isRequired, isEmail: textField.isEmail)
            )
        case .selector(let list):
            let value = customFields?[list.ident]
            
            self = .list(FormListFieldEntity(label: list.label, ident: list.ident, value: value, isRequired: entity.isRequired, options: list.options))
        case .hierarchical(let tree):
            let value = customFields?[tree.ident]
            
            self = .tree(FormTreeFieldEntity(label: tree.label, ident: tree.ident, value: value, isRequired: entity.isRequired, nodes: tree.nodes))
        }
    }
    
    init(from type: CustomFieldType) {
        switch type {
        case .textField(let entity):
            self = .textField(FormTextFieldEntity(label: entity.label, ident: entity.ident, value: entity.value, isRequired: false, isEmail: entity.isEmail))
        case .selector(let entity):
            self = .list(FormListFieldEntity(label: entity.label, ident: entity.ident, value: entity.value, isRequired: false, options: entity.options))
        case .hierarchical(let entity):
            self = .tree(FormTreeFieldEntity(label: entity.label, ident: entity.ident, value: entity.value, isRequired: false, nodes: entity.nodes))
        }
    }
}
