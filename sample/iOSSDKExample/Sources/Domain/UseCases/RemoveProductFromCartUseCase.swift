import Foundation

class RemoveProductFromCartUseCase {
    
    // MARK: Properties
    
    private let cartRepository: CartRepository
    
    // MARK: - Init
    
    init(repository: CartRepository) {
        self.cartRepository = repository
    }
    
    // MARK: - Methods
    
    func callAsFunction(_ product: ProductEntity) {
        cartRepository.removeProduct(product)
    }
}
