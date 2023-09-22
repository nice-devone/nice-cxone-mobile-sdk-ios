import UIKit

class SecondaryButton: BaseButton {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        
        configure()
    }
}

// MARK: - Private methods

private extension SecondaryButton {
    
    func configure() {
        backgroundColor = .lightGray.withAlphaComponent(0.25)
        setTitleColor(.darkGray, for: .normal)
    }
}
