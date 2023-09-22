import CXoneChatSDK
import SwiftUI
import Swinject

class ProductDetailViewModel: AnalyticsReporter, ObservableObject {
    
    // MARK: - Use Cases
    
    private let getCart: GetCartUseCase
    private let addProductToCart: AddProductToCartUseCase
    
    // MARK: - Properties
    
    private let coordinator: StoreCoordinator
    
    @Published var product: ProductEntity
    @Published var productQuantityInCart = 0
    @Published var itemsInCart = 0
    
    // MARK: - Init
    
    init(coordinator: StoreCoordinator, product: ProductEntity, getCart: GetCartUseCase, addProductToCart: AddProductToCartUseCase) {
        self.coordinator = coordinator
        self.product = product
        self.getCart = getCart
        self.addProductToCart = addProductToCart
        super.init(analyticsTitle: "product?\(product.id)", analyticsUrl: "/product/\(product.id)")
    }
    
    // MARK: - Methods
    
    override func onAppear() {
        super.onAppear()
        
        loadCartState()
    }
    
    func navigateToCart() {
        coordinator.showCartView()
    }
    
    func addToCart() {
        addProductToCart(product)
        
        loadCartState()
    }
}

// MARK: - Private methods

private extension ProductDetailViewModel {
    
    func loadCartState() {
        let cart = getCart()
        
        productQuantityInCart = cart.first { $0.product == product }?.quantity ?? 0
        itemsInCart = cart.reduce(0) { $0 + $1.quantity }
    }
}
