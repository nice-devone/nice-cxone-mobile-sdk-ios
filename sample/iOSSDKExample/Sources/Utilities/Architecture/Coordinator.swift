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
