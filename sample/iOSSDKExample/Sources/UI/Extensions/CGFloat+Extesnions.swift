import Foundation

extension CGFloat {

    func intColorComponent() -> Int {
        Int((CGFloat.minimum(CGFloat.maximum(self, 0.0), 1.0) * 255).rounded())
    }
}
