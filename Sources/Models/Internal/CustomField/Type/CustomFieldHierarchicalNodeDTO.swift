import Foundation


class CustomFieldHierarchicalNodeDTO {
    
    // MARK: - Properties
    
    var value: String
    
    var label: String
    
    var children: [CustomFieldHierarchicalNodeDTO]
    
    
    // MARK: - Init
    
    init(value: String, label: String, children: [CustomFieldHierarchicalNodeDTO] = []) {
        self.value = value
        self.label = label
        self.children = children
    }
    
    
    // MARK: - Methods
    
    func add(child: CustomFieldHierarchicalNodeDTO) {
        children.append(child)
    }
}


// MARK: - Equatable

extension CustomFieldHierarchicalNodeDTO: Equatable {
    
    public static func == (lhs: CustomFieldHierarchicalNodeDTO, rhs: CustomFieldHierarchicalNodeDTO) -> Bool {
        lhs.value == rhs.value
            && lhs.label == rhs.label
            && lhs.value == rhs.value
            && lhs.children == rhs.children
    }
}
