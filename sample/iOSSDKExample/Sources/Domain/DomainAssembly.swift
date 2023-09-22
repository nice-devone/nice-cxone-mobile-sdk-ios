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
