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
import SwinjectAutoregistration

struct DomainAssembly: Assembly {
    
    func assemble(container: Container) {
        // container.autoregister(UseCase.self, initializer: UseCase.init)
        container.autoregister(GetProductsUseCase.self, initializer: GetProductsUseCase.init)
        container.autoregister(AddProductToCartUseCase.self, initializer: AddProductToCartUseCase.init)
        container.autoregister(RemoveProductFromCartUseCase.self, initializer: RemoveProductFromCartUseCase.init)
        container.autoregister(GetCartUseCase.self, initializer: GetCartUseCase.init)
        container.autoregister(CheckoutCartUseCase.self, initializer: CheckoutCartUseCase.init)
        container.autoregister(LoginWithAmazonUseCase.self, initializer: LoginWithAmazonUseCase.init)
        container.autoregister(GetChannelConfigurationUseCase.self, initializer: GetChannelConfigurationUseCase.init)
    }
}

// MARK: - Preview Assembly

struct PreviewDomainAssembly: Assembly {
    
    func assemble(container: Container) {
        // container.autoregister(UseCase.self, initializer: MockUseCase.init)
        container.autoregister(GetProductsUseCase.self, initializer: GetProductsUseCase.init)
        container.autoregister(AddProductToCartUseCase.self, initializer: AddProductToCartUseCase.init)
        container.autoregister(RemoveProductFromCartUseCase.self, initializer: RemoveProductFromCartUseCase.init)
        container.autoregister(GetCartUseCase.self, initializer: GetCartUseCase.init)
        container.autoregister(CheckoutCartUseCase.self, initializer: CheckoutCartUseCase.init)
        container.autoregister(LoginWithAmazonUseCase.self, initializer: PreviewLoginWithAmazonUseCase.init)
        container.autoregister(GetChannelConfigurationUseCase.self, initializer: GetChannelConfigurationUseCase.init)
    }
}
