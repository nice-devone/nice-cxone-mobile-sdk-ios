import CXoneChatSDK
import SwiftUI
import Swinject
import Toast
import UIKit

class LoginCoordinator: Coordinator {
    
    // MARK: - Properties
    
    var storeCoordinator: StoreCoordinator {
        subCoordinators
        // swiftlint:disable:next force_cast
            .first { $0 is StoreCoordinator } as! StoreCoordinator
    }
    
    // MARK: - Init
    
    override init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        let storeCoordinator = StoreCoordinator(navigationController: navigationController)
        storeCoordinator.assembler = self.assembler
        subCoordinators.append(storeCoordinator)
        
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.setNormalNavigationBarAppearance()
        
        storeCoordinator.popToConfiguration = { [weak self] in
            self?.showConfigurationView()
        }
        storeCoordinator.showSettings = { [weak self] in
            self?.showSettingsView()
        }
    }
    
    // MARK: - Methods
    
    func start(with deeplinkOption: DeeplinkOption?) {
        navigationController.viewControllers.removeAll()
        
        if let configuration = LocalStorageManager.configuration {
            showLoginView(configuration: configuration, deeplinkOption: deeplinkOption)
        } else {
            showConfigurationView()
        }
    }
}

// MARK: - Navigation

extension LoginCoordinator {
    
    func showSettingsView() {
        // swiftlint:disable:next force_unwrapping
        let controller = UIHostingController(rootView: resolver.resolve(SettingsView.self)!)

        navigationController.show(controller, sender: self)
    }
    
    func showConfigurationView() {
        // swiftlint:disable:next force_unwrapping
        let controller = UIHostingController(rootView: resolver.resolve(ConfigurationView.self)!)
        
        navigationController.setViewControllers([controller], animated: true)
    }
    
    func showLoginView(configuration: Configuration, deeplinkOption: DeeplinkOption?) {
        // swiftlint:disable:next force_unwrapping
        let controller = UIHostingController(rootView: resolver.resolve(LoginView.self, arguments: configuration, deeplinkOption)!)
        
        navigationController.show(controller, sender: self)
    }
    
    func showDashboard(deeplinkOption: DeeplinkOption?) {
        storeCoordinator.start(with: deeplinkOption)
    }
}
