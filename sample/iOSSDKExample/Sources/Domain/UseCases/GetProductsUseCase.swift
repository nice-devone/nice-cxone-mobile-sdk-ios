import Foundation

class GetProductsUseCase {
    
    // MARK: - Properties
    
    private let productsRepository: ProductsRepository
    
    // MARK: - Init
    
    init(repository: ProductsRepository) {
        self.productsRepository = repository
    }
    
    // MARK: - Methods
    
    func callAsFunction() async throws -> [ProductEntity] {
        try await productsRepository.get()
    }
}
