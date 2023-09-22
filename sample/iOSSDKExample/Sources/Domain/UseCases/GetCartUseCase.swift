import Foundation

class GetCartUseCase {
    
    // MARK: Properties
    
    private let cartRepository: CartRepository
    
    // MARK: - Init
    
    init(repository: CartRepository) {
        self.cartRepository = repository
    }
    
    // MARK: - Methods
    
    func callAsFunction() -> [ProductOrderEntity] {
        cartRepository.cart
    }
}
