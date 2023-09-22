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
