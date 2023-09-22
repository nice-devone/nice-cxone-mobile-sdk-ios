import Swinject
import SwinjectAutoregistration

struct AppAssembly: Assembly {
    
    // MARK: - Properties
    
    let dependencies: [Assembly]

    // MARK: - Init
    
    init(coordinator: LoginCoordinator) {
        self.dependencies = [
            PresentationAssembly(coordinator: coordinator),
            DomainAssembly(),
            DataAssembly()
        ]
    }
    
    // MARK: - Methods
    
    func assemble(container: Container) {
        dependencies.forEach { $0.assemble(container: container) }
    }
}

// MARK: - Preview

struct PreviewAppAssembly: Assembly {
    
    // MARK: - Properties
    
    let dependencies: [Assembly]
    
    // MARK: - Init
    
    init(coordinator: LoginCoordinator) {
        self.dependencies = [
            PresentationAssembly(coordinator: coordinator),
            PreviewDomainAssembly(),
            PreviewDataAssembly()
        ]
    }
    
    // MARK: - Methods
    
    func assemble(container: Container) {
        dependencies.forEach { $0.assemble(container: container) }
    }
}
