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
