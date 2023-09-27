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

struct PresentationAssembly: Assembly {
    
    // MARK: - Properties
    
    private let coordinator: LoginCoordinator
    
    private var storeCoordinator: StoreCoordinator {
        coordinator.storeCoordinator
    }
    
    // MARK: - Init
    
    init(coordinator: LoginCoordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Methods
    
    func assemble(container: Container) {
        assembleLoginRelatedViews(container: container)
        assembleStoreRelatedViews(container: container)
    }
    
    func assembleLoginRelatedViews(container: Container) {
        container.register(LoginView.self) { resolver, configuration, deeplinkOption in
            LoginView(
                viewModel: LoginViewModel(
                    coordinator: coordinator,
                    configuration: configuration,
                    deeplinkOption: deeplinkOption,
                    // swiftlint:disable force_unwrapping
                    loginWithAmazon: resolver.resolve(LoginWithAmazonUseCase.self)!,
                    getChannelConfiguration: resolver.resolve(GetChannelConfigurationUseCase.self)!
                    // swiftlint:enable force_unwrapping
                )
            )
        }
        container.register(ConfigurationView.self) { _ in
            ConfigurationView(viewModel: ConfigurationViewModel(coordinator: coordinator))
        }
        container.register(SettingsView.self) { _ in
            SettingsView(viewModel: SettingsViewModel())
        }
    }
    
    func assembleStoreRelatedViews(container: Container) {
        container.register(PaymentDoneView.self) { _ in
            PaymentDoneView(viewModel: PaymentDoneViewModel(coordinator: storeCoordinator))
        }
        container.register(PaymentView.self) { resolver in
            PaymentView(
                viewModel: PaymentViewModel(
                    coordinator: storeCoordinator,
                    // swiftlint:disable force_unwrapping
                    getCart: resolver.resolve(GetCartUseCase.self)!,
                    checkoutCart: resolver.resolve(CheckoutCartUseCase.self)!
                    // swiftlint:enable force_unwrapping
                )
            )
        }
        container.register(ProductDetailView.self) { resolver, product in
            ProductDetailView(
                viewModel: ProductDetailViewModel(
                    coordinator: coordinator.storeCoordinator,
                    product: product,
                    // swiftlint:disable force_unwrapping
                    getCart: resolver.resolve(GetCartUseCase.self)!,
                    addProductToCart: resolver.resolve(AddProductToCartUseCase.self)!
                    // swiftlint:enable force_unwrapping
                )
            )
        }
        container.register(CartView.self) { resolver in
            CartView(
                viewModel: CartViewModel(
                    coordinator: storeCoordinator,
                    // swiftlint:disable force_unwrapping
                    getCart: resolver.resolve(GetCartUseCase.self)!,
                    addProductToCart: resolver.resolve(AddProductToCartUseCase.self)!,
                    removeProductFromCart: resolver.resolve(RemoveProductFromCartUseCase.self)!
                    // swiftlint:enable force_unwrapping
                )
            )
        }
        container.register(StoreView.self) { resolver, deeplinkOption in
            StoreView(
                viewModel: StoreViewModel(
                    coordinator: storeCoordinator,
                    deeplinkOption: deeplinkOption,
                    // swiftlint:disable force_unwrapping
                    getProducts: resolver.resolve(GetProductsUseCase.self)!,
                    getCart: resolver.resolve(GetCartUseCase.self)!
                    // swiftlint:enable force_unwrapping
                )
            )
        }
    }
}
