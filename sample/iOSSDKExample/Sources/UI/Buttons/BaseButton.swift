import UIKit

class BaseButton: UIButton {
    
    // MARK: - Properties
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width, height: 44)
    }
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        
        layer.cornerRadius = 8
    }
}
