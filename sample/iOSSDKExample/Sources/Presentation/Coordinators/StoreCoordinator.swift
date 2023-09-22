// swiftlint:disable force_unwrapping

import SwiftUI
import Swinject
import UIKit

class StoreCoordinator: Coordinator {
    
    // MARK: - Properties
    
    var chatCoordinator: ChatCoordinator {
        subCoordinators
        // swiftlint:disable:next force_cast
            .first { $0 is ChatCoordinator } as! ChatCoordinator
    }
    
    var popToConfiguration: (() -> Void)?
    var showSettings: (() -> Void)?
    
    // MARK: - Init
    
    override init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        let chatCoordinator = ChatCoordinator(navigationController: navigationController)
        chatCoordinator.assembler = self.assembler
        subCoordinators.append(chatCoordinator)
        
        navigationController.setNormalNavigationBarAppearance()
        
        chatCoordinator.popToConfiguration = { [weak self] in
            self?.showConfigurationView()
        }
    }
    
    // MARK: - Methods
    
    func start(with deeplinkOption: DeeplinkOption?) {
        navigationController.setViewControllers([UIHostingController(rootView: resolver.resolve(StoreView.self, argument: deeplinkOption)!)], animated: true)
    }
}

// MARK: - Navigation

extension StoreCoordinator {
    
    func showProductDetailView(product: ProductEntity) {
        let controller = UIHostingController(rootView: resolver.resolve(ProductDetailView.self, argument: product)!)
        
        navigationController.show(controller, sender: self)
    }
    
    func showCartView() {
        let controller = UIHostingController(rootView: resolver.resolve(CartView.self)!)
        
        navigationController.show(controller, sender: self)
    }
    
    func showPaymentView() {
        let controller = UIHostingController(rootView: resolver.resolve(PaymentView.self)!)
        
        navigationController.show(controller, sender: self)
    }
    
    func showPaymentDoneView() {
        let controller = UIHostingController(rootView: resolver.resolve(PaymentDoneView.self)!)
        
        navigationController.show(controller, sender: self)
    }
    
    func showConfigurationView() {
        // swiftlint:disable:next force_unwrapping
        let controller = UIHostingController(rootView: resolver.resolve(ConfigurationView.self)!)
        
        navigationController.setViewControllers([controller], animated: true)
    }
    
    func openChat(deeplinkOption: DeeplinkOption?) {
        chatCoordinator.start(with: deeplinkOption)
    }
}
