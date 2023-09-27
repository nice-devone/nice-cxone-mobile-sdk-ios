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

import Foundation
import Swinject
import SwinjectAutoregistration

struct DataAssembly: Assembly {
    
    // MARK: - Properties
    
    private static weak var container: Container?
    
    // MARK: - Methods
    
    func assemble(container: Container) {
        Self.container = container
        
        container.register(URLSession.self) { _ in
            URLSession.shared
        }
        container.register(ProductsRepository.self) { resolver in
            guard let session = resolver.resolve(URLSession.self) else {
                fatalError("Unable to resolve URLSession")
            }
            guard let repository = ProductsRepositoryImpl(session: session) else {
                fatalError("Unable to resolve ProductsRepository")
            }
            
            return repository
        }
        .inObjectScope(.container)
        
        container.autoregister(CartRepository.self, initializer: CartRepositoryImpl.init)
            .inObjectScope(.container)
    }
    
    static func cleanResetableContainer() {
        Self.container?.resetObjectScope(.resetableContainer)
    }
}

// MARK: - Preview Assembly

struct PreviewDataAssembly: Assembly {
    
    // MARK: - Properties
    
    private static weak var container: Container?
    
    // MARK: - Methods
    
    func assemble(container: Container) {
        Self.container = container
        
        container.autoregister(ProductsRepository.self, initializer: MockProductsRepositoryImpl.init)
            .inObjectScope(.container)
        container.autoregister(CartRepository.self, initializer: MockCartRepositoryImpl.init)
            .inObjectScope(.container)
    }
    
    static func cleanResetableContainer() {
        Self.container?.resetObjectScope(.resetableContainer)
    }
}
