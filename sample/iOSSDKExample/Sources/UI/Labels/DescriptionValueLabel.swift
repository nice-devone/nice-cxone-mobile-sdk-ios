import SnapKit
import UIKit

class DescriptionValueLabel: UIView {
    
    // MARK: - Views
    
    private let descriptionLabel = UILabel()
    private let valueLabel = UILabel()
    
    // MARK: - Properties
    
    var valueDescription: String? {
        get { descriptionLabel.text }
        set { descriptionLabel.text = newValue }
    }
    var value: String? {
        get { valueLabel.text }
        set { valueLabel.text = newValue }
    }
    var descriptionColor: UIColor? {
        get { descriptionLabel.textColor }
        set { descriptionLabel.textColor = newValue }
    }
    var valueColor: UIColor? {
        get { valueLabel.textColor }
        set { valueLabel.textColor = newValue }
    }
    
    // MARK: - Init

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)

        setupSubviews()
    }
}

// MARK: - Private methods

private extension DescriptionValueLabel {
    
    func setupSubviews() {
        addSubviews(descriptionLabel, valueLabel)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        
        valueLabel.font = .preferredFont(forTextStyle: .body, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        valueLabel.numberOfLines = 0
        valueLabel.textAlignment = .right
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.equalTo(snp.centerX)
        }
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel)
            make.leading.equalTo(descriptionLabel.snp.trailing)
            make.trailing.bottom.equalToSuperview()
        }
    }
}
