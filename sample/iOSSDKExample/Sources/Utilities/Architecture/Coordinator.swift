import Swinject
import UIKit

open class Coordinator {
    
    // MARK: - Properties
    
    var navigationController: UINavigationController
    
    var subCoordinators = [Coordinator]()
    
    // swiftlint:disable:next force_unwrapping
    var resolver: Swinject.Resolver { assembler!.resolver }
    var assembler: Assembler? {
        didSet {
            subCoordinators.forEach { $0.assembler = assembler }
        }
    }
    
    // MARK: - Init
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    
    func popTo(_ controller: AnyClass, animated: Bool = true) {
        navigationController.popToViewController(ofClass: controller)
    }
}

// MARK: - Helpers

private extension UINavigationController {
    
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
}
