import UIKit

class PrimaryButton: BaseButton {
    
    // MARK: - Properties
    
    var identifier: String?
    
    var postback: String?
    
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? .systemBlue : .lightGray
        }
    }
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        
        configure()
    }
}

// MARK: - Private methods

private extension PrimaryButton {
    
    func configure() {
        backgroundColor  = .systemBlue
        setTitleColor(.white, for: .normal)
    }
}
