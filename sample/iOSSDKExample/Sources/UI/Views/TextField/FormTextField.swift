import UIKit

// MARK: - FormTextFieldDelegate

protocol FormTextFieldDelegate: AnyObject {
    func formTextFieldShouldReturn(_ formTextField: FormTextField) -> Bool
    func formTextFieldDidEndEditing(_ formTextField: FormTextField)
    func formTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
}

extension FormTextFieldDelegate {
    
    func formTextFieldShouldReturn(_ formTextField: FormTextField) -> Bool {
        formTextField.resignFirstResponder()
        
        return true
    }
    
    func formTextFieldDidEndEditing(_ formTextField: FormTextField) {
        formTextField.resignFirstResponder()
    }
    
    func formTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        true
    }
}

// MARK: - FormTextField

class FormTextField: UIView, FormViewElement {
    
    // MARK: - View
    
    private let stackView = UIStackView()
    private let contentView = UIView()
    
    private let placeholderLabel = UILabel()
    private let textField = UITextField()
    private let separator = UIView(frame: .zero)
    private let bottomLabel = UILabel()
    
    // MARK: - Properties
    
    weak var delegate: FormTextFieldDelegate?
    
    let type: FormFieldType
    let isRequired: Bool
    
    var identification: String?
    
    var text: String? {
        get { textField.text }
        set {
            textField.text = newValue
            
            if newValue.isNilOrEmpty {
                movePlaceholderToTextField()
            } else {
                movePlaceholderToCaption()
            }
        }
    }
    var errorMessage: String?
    var placeholder: String? {
        get { placeholderLabel.text }
        set { placeholderLabel.text = newValue }
    }
    var clearButtonMode: UITextField.ViewMode {
        get { textField.clearButtonMode }
        set { textField.clearButtonMode = newValue }
    }
    var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }
    var autocapitalizationType: UITextAutocapitalizationType {
        get { textField.autocapitalizationType }
        set { textField.autocapitalizationType = newValue }
    }
    var autocorrectionType: UITextAutocorrectionType {
        get { textField.autocorrectionType }
        set { textField.autocorrectionType = newValue }
    }
    var pickerInputView: UIView? {
        get { textField.inputView }
        set { textField.inputView = newValue }
    }
    var pickerInputAccessoryView: UIView? {
        get { textField.inputAccessoryView }
        set { textField.inputAccessoryView = newValue }
    }
    var textColor: UIColor? {
        get { textField.textColor }
        set { textField.textColor = newValue }
    }
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(type: FormFieldType, isRequired: Bool) {
        self.type = type
        self.isRequired = isRequired
        super.init(frame: .zero)
        
        addSubviews()
        setupSubviews()
        setupConstraints()
    }

    // MARK: - Internal methods
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
    
    @discardableResult
    func isValid() -> Bool {
        var isValid = true
        
        if case .email = type {
            if isRequired || !text.isNilOrEmpty {
                isValid = isEmailValid(text)
            }
        } else if isRequired || type == .email && text.isNilOrEmpty {
            isValid = !text.isNilOrEmpty
        }
        
        showError(!isValid)
        
        return isValid
    }
    
    func showError(_ isVisible: Bool) {
        bottomLabel.isHidden = !isVisible
        bottomLabel.textColor = isVisible ? .red : .darkGray
        if let errorMessage {
            bottomLabel.text = errorMessage
        } else {
            bottomLabel.text = text.isNilOrEmpty ? L10n.Common.requiredField : L10n.Common.invalidEmail
        }
        
        separator.backgroundColor = isVisible ? .red : .darkGray
        
        if isVisible {
            stackView.addArrangedSubview(bottomLabel)
        } else {
            bottomLabel.removeFromSuperview()
        }
    }
}

// MARK: - UITextFieldDelegate

extension FormTextField: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.formTextFieldShouldReturn(self) ?? textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        
        delegate?.formTextFieldDidEndEditing(self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard type != .list else {
            return false
        }
        
        if textField.text.isNilOrEmpty && !string.isEmpty {
            movePlaceholderToCaption()
        } else if string.isEmpty && textField.text?.count == 1 || range.length > 1 && string.isEmpty {
            movePlaceholderToTextField()
        }
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        
        return delegate?.formTextField(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}

// MARK: - Private methods

private extension FormTextField {
    
    func movePlaceholderToCaption() {
        placeholderLabel.font = .preferredFont(forTextStyle: .caption2)
        
        placeholderLabel.snp.remakeConstraints { remake in
            remake.top.leading.equalToSuperview()
        }
    }
    
    func movePlaceholderToTextField() {
        placeholderLabel.font = textField.font
        
        placeholderLabel.snp.remakeConstraints { remake in
            remake.edges.equalTo(textField)
        }
    }
    
    func isEmailValid(_ email: String?) -> Bool {
        guard let email else {
            return false
        }
        
        let emailRegEx = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
        
        return email.range(of: emailRegEx, options: [.regularExpression]) != nil
    }
    
    func addSubviews() {
        addSubview(stackView)
        
        contentView.addSubviews(placeholderLabel, textField, separator)
        stackView.addArrangedSubview(contentView)
    }
    
    func setupSubviews() {
        placeholderLabel.font = type == .list ? .preferredFont(forTextStyle: .caption2) : textField.font
        placeholderLabel.textColor = .lightGray
        
        textField.returnKeyType = .done
        textField.delegate = self
        if type == .list {
            textField.tintColor = .clear
        }
        
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        
        separator.backgroundColor = .darkGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        bottomLabel.text = "Required field"
        bottomLabel.font = .preferredFont(forTextStyle: .footnote)
        bottomLabel.textColor = .red
    }
    
    func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        textField.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        placeholderLabel.snp.makeConstraints { make in
            if type == .list {
                make.top.leading.equalToSuperview()
            } else {
                make.edges.equalTo(textField)
            }
        }
        separator.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom)
            make.leading.trailing.equalTo(textField)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}
