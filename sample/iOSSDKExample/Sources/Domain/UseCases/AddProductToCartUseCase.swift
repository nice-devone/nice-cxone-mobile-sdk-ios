import Foundation

class AddProductToCartUseCase {
    
    // MARK: Properties
    
    private let cartRepository: CartRepository
    
    // MARK: - Init
    
    init(repository: CartRepository) {
        self.cartRepository = repository
    }
    
    // MARK: - Methods
    
    func callAsFunction(_ product: ProductEntity) {
        cartRepository.addProduct(product)
    }
}
