//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

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
