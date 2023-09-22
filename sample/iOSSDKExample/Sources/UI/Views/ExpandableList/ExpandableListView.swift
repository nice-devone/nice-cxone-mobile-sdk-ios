import CXoneChatSDK
import UIKit

// MARK: - Protocol

protocol ExpandableListDelegate: AnyObject {
    func expandableListView(_ view: ExpandableListView, didChooseValueIdentifier value: String, with customFieldsIdent: String)
}

// MARK: - Implementation

class ExpandableListView: UIView, FormViewElement {
    
    // MARK: - Properties
    
    private var customFieldsIdent = ""
    private var customFields = [String: String]()
    
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    weak var delegate: ExpandableListDelegate?
    
    var isRequired = false
    
    private var label = ""
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        
        addSubviews(titleLabel, scrollView)
        scrollView.addSubview(stackView)
        
        titleLabel.font = .preferredFont(forTextStyle: .caption2)
        titleLabel.textColor = .lightGray
        
        stackView.axis = .vertical
        stackView.spacing = 10
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.top.bottom.height.equalTo(scrollView)
            make.leading.trailing.equalTo(titleLabel)
        }
    }
    
    // MARK: - Internal methods
    
    func setup(entity: FormTreeFieldEntity) {
        self.label = entity.label
        titleLabel.text = entity.label
        customFieldsIdent = entity.ident
        isRequired = entity.isRequired
        
        let selectedLabel = entity.value.map { value -> String? in
            entity.nodes.find(by: value)?.label
        } ?? nil
        
        entity.nodes.forEach { node in
            stackView.addArrangedSubview(getCell(node: node, with: selectedLabel))
        }
    }
    
    func isValid() -> Bool {
        guard isRequired else {
            return true
        }
        
         let isValid = stackView.arrangedSubviews.first { subview in
            guard let view = subview as? ExpandableCellView else {
                return false
            }
            
            return isAnyChildSelected(in: view)
         } != nil
        
        showError(!isValid)
        
        return isValid
    }
    
    func showError(_ isVisible: Bool) {
        titleLabel.textColor = isVisible ? .red : .lightGray
        
        titleLabel.text = isVisible
            ? L10n.Form.requiredField(label)
            : label
    }
}

// MARK: - ExpandableCellDelegate

extension ExpandableListView: ExpandableCellDelegate {
    
    func expandableCellView(_ view: ExpandableCellView, didSelectOption option: String) {
        if view.isParent {
            view.isExpanded.toggle()
        } else {
            stackView.arrangedSubviews.forEach { subview in
                (subview as? ExpandableCellView)?.deselect()
            }
            
            view.isSelected = true
            
            guard let customField = customFields.first(where: { $0.value == option }) else {
                Log.error(.failed("Could not get selected value."))
                return
            }
            
            showError(false)
            
            delegate?.expandableListView(self, didChooseValueIdentifier: customField.key, with: customFieldsIdent)
        }
    }
}

// MARK: - Private Methods

private extension ExpandableListView {
    
    func getCell(node: CustomFieldHierarchicalNode, with selectedLabel: String?) -> ExpandableCellView {
        customFields[node.value] = node.label
        
        let isSelected = selectedLabel.map { label -> Bool in
            node.label == label
        } ?? false
        let cell = ExpandableCellView(label: node.label, childViews: node.children.map { getCell(node: $0, with: selectedLabel) })
        cell.delegate = self
        cell.isSelected = isSelected
        
        if cell.isParent, isAnyChildSelected(in: cell) {
            cell.isExpanded = true
        }
        
        return cell
    }
    
    func isAnyChildSelected(in view: ExpandableCellView) -> Bool {
        if view.isParent {
            for child in view.childViews where isAnyChildSelected(in: child) {
                return true
            }
            
            return false
        } else {
            return view.isSelected
        }
    }
}

// MARK: - Helpers

private extension [CustomFieldHierarchicalNode] {
    
    func find(by value: String) -> CustomFieldHierarchicalNode? {
        for node in self {
            if node.value == value {
                return node
            }
            
            if let match = node.children.find(by: value) {
                return match
            }
        }
        
        return nil
    }
}
