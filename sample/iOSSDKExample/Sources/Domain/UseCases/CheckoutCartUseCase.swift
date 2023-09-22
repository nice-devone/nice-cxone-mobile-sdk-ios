import Foundation

class CheckoutCartUseCase {
    
    // MARK: Properties
    
    private let cartRepository: CartRepository
    
    // MARK: - Init
    
    init(repository: CartRepository) {
        self.cartRepository = repository
    }
    
    // MARK: - Methods
    
    func callAsFunction() {
        cartRepository.checkout()
    }
}
