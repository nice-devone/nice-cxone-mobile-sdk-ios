import UIKit

// MARK: - Protocol

protocol ExpandableCellDelegate: AnyObject {
    func expandableCellView(_ view: ExpandableCellView, didSelectOption option: String)
}

// MARK: - Implementation

class ExpandableCellView: UIView {
    
    // MARK: - Views
    
    private let stackView = UIStackView()
    private let contentView = UIView()
    private let label = UILabel()
    private let separator = UIView()
    private let iconView = UIImageView()
    
    let childViews: [ExpandableCellView]
    
    // MARK: - Properties
    
    weak var delegate: ExpandableCellDelegate?
    
    var text: String
    
    var isParent: Bool
    
    var isSelected = false {
        didSet {
            guard oldValue != isSelected else {
                return
            }
            
            UIView.animate(withDuration: 1) {
                self.iconView.isHidden = !self.isSelected
            }
        }
    }
    var isExpanded = false {
        didSet {
            guard oldValue != isExpanded else {
                return
            }
            
            showChildren()
        }
    }
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(label: String, childViews: [ExpandableCellView]) {
        self.text = label
        self.childViews = childViews
        self.isParent = !childViews.isEmpty
        super.init(frame: .zero)
        
        addSubviews()
        setupSubviews()
        setupConstraints()
    }
    
    // MARK: - Internal methods
    
    func deselect() {
        if isParent {
            stackView.arrangedSubviews.forEach { subview in
                (subview as? ExpandableCellView)?.deselect()
            }
        } else {
            isSelected = false
        }
    }
}

// MARK: - Actions

private extension ExpandableCellView {
    
    @objc
    func viewTapped() {
        delegate?.expandableCellView(self, didSelectOption: text)
    }
}

// MARK: - Private methods

private extension ExpandableCellView {
    
    func showChildren() {
        UIView.animate(withDuration: 0.2) {
            self.iconView.transform = CGAffineTransform(rotationAngle: self.isExpanded ? .pi / 2 : 0)
        }
        
        childViews.forEach { child in
            if isExpanded {
                stackView.addArrangedSubview(child)
            } else {
                stackView.removeArrangedSubview(child)
                child.removeFromSuperview()
            }
        }
    }
    
    func addSubviews() {
        addSubviews(contentView, stackView)
        contentView.addSubviews(label, iconView, separator)
    }
    
    func setupSubviews() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        
        stackView.axis = .vertical
        
        separator.backgroundColor = .lightGray
        
        if isParent {
            label.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        }
        
        label.text = text
        
        iconView.image = isParent ? Asset.Common.disclosure : Asset.Common.check
        iconView.isHidden = !isParent
    }
    
    func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalToSuperview()
            make.trailing.lessThanOrEqualTo(iconView.snp.trailing).offset(10)
        }
        iconView.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.trailing.equalToSuperview().inset(10)
        }
        separator.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}
