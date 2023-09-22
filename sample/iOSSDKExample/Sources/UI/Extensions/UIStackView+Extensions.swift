import UIKit

extension UIStackView {
    
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { view in
            addArrangedSubview(view)
        }
    }
}
