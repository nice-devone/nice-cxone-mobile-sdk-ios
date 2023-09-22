import Swinject

class AppModule {

    // MARK: - Properties
    
    private let coordinator: LoginCoordinator
    
    private let mainAssembly: Assembly
    private let container = Swinject.Container()
    
    private(set) var assembler: Assembler

    let resolver: Swinject.Resolver
    
    // MARK: - Init
    
    init(coordinator: LoginCoordinator) {
        self.coordinator = coordinator
        self.mainAssembly = AppAssembly(coordinator: coordinator)
        self.assembler = Assembler(container: container)
        
        assembler.apply(assembly: self.mainAssembly)
        resolver = container.synchronize()
    }
}

// MARK: - Preview

class PreviewAppModule {

    // MARK: - Properties
    
    private let coordinator: LoginCoordinator
    
    private let mainAssembly: Assembly
    private let container = Swinject.Container()
    
    private(set) var assembler: Assembler

    let resolver: Swinject.Resolver
    
    // MARK: - Init
    
    init(coordinator: LoginCoordinator) {
        self.coordinator = coordinator
        self.mainAssembly = PreviewAppAssembly(coordinator: coordinator)
        self.assembler = Assembler(container: container)
        
        assembler.apply(assembly: self.mainAssembly)
        resolver = container.synchronize()
    }
}
