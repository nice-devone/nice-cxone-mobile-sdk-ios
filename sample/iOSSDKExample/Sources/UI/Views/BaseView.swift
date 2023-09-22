import UIKit

open class BaseView: UIView {
    
    // MARK: - Lifecycle
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setupColors()
    }
    
    // MARK: - Open methods
    
    open func setupColors() {
        fatalError("Specify colors for changing light and dark modes.")
    }
}
