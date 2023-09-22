import Foundation

protocol FormViewElement {
    
    var isRequired: Bool { get }
    
    func isValid() -> Bool
}
