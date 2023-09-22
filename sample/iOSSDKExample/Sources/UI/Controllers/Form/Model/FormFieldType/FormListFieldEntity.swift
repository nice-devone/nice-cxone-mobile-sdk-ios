import Foundation

struct FormListFieldEntity {
    
    let label: String
    
    let ident: String
    
    var value: String?
    
    let isRequired: Bool
    
    let options: [String: String]
}
