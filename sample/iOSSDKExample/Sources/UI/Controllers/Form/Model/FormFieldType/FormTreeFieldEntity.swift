import CXoneChatSDK

struct FormTreeFieldEntity {
    
    let label: String
    
    let ident: String
    
    var value: String?
    
    let isRequired: Bool
    
    let nodes: [CustomFieldHierarchicalNode]
}
