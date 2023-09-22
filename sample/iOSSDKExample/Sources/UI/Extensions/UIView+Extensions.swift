import UIKit

extension UIView {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String {
        String(describing: self)
    }
    
    // MARK: - Methods
    
    func addSubviews(_ views: UIView...) {
        views.forEach { view in
            guard !self.isDescendant(of: view) else {
                return
            }
            
            self.addSubview(view)
        }
    }
    
    func resignResponder() {
        resignFirstResponder()
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
