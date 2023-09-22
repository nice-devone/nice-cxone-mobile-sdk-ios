import CXoneChatSDK
import UIKit

class FormView: BaseView {
    
    // MARK: - Views
    
    let titleLabel = UILabel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let contentStackView = UIStackView()
    private let buttonStackView = UIStackView()
    
    let confirmButton = PrimaryButton()
    let cancelButton = SecondaryButton()
    
    // MARK: - Properties
    
    var customFields = [String: String]()
    
    private var viewObject: FormVO?
    private var listOptions = [FormListFieldEntity]()
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        
        addAllSubviews()
        setupSubviews()
        setupConstraints()
        setupColors()
    }
    
    // MARK: - Lifecycle
    
    override func setupColors() {
        backgroundColor = .systemBackground
        titleLabel.textColor = .lightGray
    }
    
    // MARK: - Internal methods
    
    func setupView(with viewObject: FormVO) {
        self.viewObject = viewObject
        
        viewObject.entities.forEach { type in
            switch type {
            case .textField(let entity):
                handleTextField(entity)
            case .list(let entity):
                handleList(entity)
            case .tree(let entity):
                handleTree(entity)
            }
        }
    }
    
    func areFieldsValid() -> Bool {
        // swiftlint:disable:next reduce_boolean
        contentStackView.arrangedSubviews.reduce(true) { valid, subview in
            (subview as? FormViewElement)?.isValid() != false && valid
        }
    }
}

// MARK: - Actions

private extension FormView {
        
    @objc
    func didChoosePickerOption() {
        endEditing(true)
    }
}

// MARK: - TextFieldDelegate

extension FormView: FormTextFieldDelegate {
    
    func formTextFieldShouldReturn(_ formTextField: FormTextField) -> Bool {
        formTextFieldDidEndEditing(formTextField)
        
        return formTextField.resignFirstResponder()
    }
    
    func formTextFieldDidEndEditing(_ formTextField: FormTextField) {
        formTextField.resignFirstResponder()
        formTextField.isValid()
        
        guard formTextField.type != .list else {
            return
        }
        guard let customField = customFields.first(where: { $0.key == formTextField.identification }) else {
            Log.error(CommonError.unableToParse("customField"))
            return
        }
        
        customFields.updateValue(formTextField.text ?? "", forKey: customField.key)
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension FormView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let options = listOptions.first(where: { $0.ident == pickerView.layer.name })?.options else {
            return 0
        }
        
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let options = listOptions.first(where: { $0.ident == pickerView.layer.name })?.options else {
            return nil
        }
        return Array(options.values)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let entity = listOptions.first(where: { $0.ident == pickerView.layer.name }) else {
            Log.error(CommonError.unableToParse("entity", from: listOptions))
            return
        }
        
        let optionValue = Array(entity.options.values)[row]
        customFields[entity.ident] = entity.options.first { $0.value == optionValue }?.key
        (contentStackView.arrangedSubviews
            .first { ($0 as? FormTextField)?.identification == entity.ident } as? FormTextField)?
            .text = optionValue
    }
}

// MARK: - ExpandableListDelegate

extension FormView: ExpandableListDelegate {

    func expandableListView(_ view: ExpandableListView, didChooseValueIdentifier value: String, with customFieldsIdent: String) {
        customFields[customFieldsIdent] = value
    }
}

// MARK: - Private methods

private extension FormView {
    
    func handleTextField(_ entity: FormTextFieldEntity) {
        guard customFields[entity.ident] == nil else {
            return
        }
        
        customFields[entity.ident] = entity.value ?? ""
        
        let textFieldView = getTextField(type: entity.isEmail ? .email : .text, isRequired: entity.isRequired, ident: entity.ident, value: entity.value)
        textFieldView.placeholder = entity.label
        
        contentStackView.addArrangedSubview(textFieldView)
    }
    
    func handleList(_ entity: FormListFieldEntity) {
        guard customFields[entity.ident] == nil else {
            return
        }
        
        customFields[entity.ident] = entity.value ?? entity.options.keys.first
        listOptions.append(entity)
        
        let textFieldView = getTextField(
            type: .list,
            isRequired: entity.isRequired,
            ident: entity.ident,
            value: entity.options.first { $0.value == entity.label }?.value ?? entity.options.values.first
        )
        textFieldView.placeholder = entity.label
        
        contentStackView.addArrangedSubview(textFieldView)
    }
    
    func handleTree(_ entity: FormTreeFieldEntity) {
        guard customFields[entity.ident] == nil else {
            return
        }
        
        customFields[entity.ident] = entity.value ?? ""
        
        let expandableView = ExpandableListView()
        expandableView.delegate = self
        expandableView.setup(entity: entity)
        
        contentStackView.addArrangedSubview(expandableView)
    }
    
    func getTextField(type: FormFieldType, isRequired: Bool, ident: String, value: String?) -> FormTextField {
        let textFieldView = FormTextField(type: type, isRequired: isRequired)
        textFieldView.text = value.isNilOrEmpty ? nil : value
        textFieldView.identification = ident
        textFieldView.delegate = self
        textFieldView.autocapitalizationType = .none
        textFieldView.autocorrectionType = .no
        
        if type == .list {
            let picker = UIPickerView()
            picker.layer.name = ident
            picker.delegate = self
            picker.dataSource = self
            textFieldView.pickerInputView = picker
            textFieldView.pickerInputAccessoryView = getToolbar(ident: ident)
        }
        
        return textFieldView
    }
    
    func getToolbar(ident: String) -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: frame.size.height / 6, width: frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: frame.size.width / 2, y: frame.size.height - 20.0)
        toolBar.tintColor = .label
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didChoosePickerOption))
        doneButton.customView?.layer.name = ident
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        
        return toolBar
    }
    
    func addAllSubviews() {
        addSubviews(titleLabel, scrollView, buttonStackView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(contentStackView)
        buttonStackView.addArrangedSubviews(cancelButton, confirmButton)
    }
    
    func setupSubviews() {
        contentView.isUserInteractionEnabled = true
        
        scrollView.isUserInteractionEnabled  = true
        
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .title3)
        
        contentStackView.isUserInteractionEnabled = true
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.distribution = .equalSpacing
        
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        
        cancelButton.setTitle(L10n.Common.cancel, for: .normal)
        confirmButton.setTitle(L10n.Common.confirm, for: .normal)
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalTo(scrollView)
            make.leading.trailing.equalTo(self).inset(24)
        }
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(20)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(20)
        }
    }
}
