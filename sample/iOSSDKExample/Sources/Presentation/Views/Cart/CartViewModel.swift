import CXoneChatSDK
import SwiftUI

class CartViewModel: AnalyticsReporter, ObservableObject {
    
    // MARK: - UseCases
    
    private let getCart: GetCartUseCase
    private let addProductToCart: AddProductToCartUseCase
    private let removeProductFromCart: RemoveProductFromCartUseCase
    
    // MARK: - Properties
    
    private let coordinator: StoreCoordinator
    
    @Published var cart = [ProductOrderEntity]()
    
    var totalAmount: Double {
        cart.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
    
    // MARK: - Init
    
    init(
        coordinator: StoreCoordinator,
        getCart: GetCartUseCase,
        addProductToCart: AddProductToCartUseCase,
        removeProductFromCart: RemoveProductFromCartUseCase
    ) {
        self.coordinator = coordinator
        self.getCart = getCart
        self.addProductToCart = addProductToCart
        self.removeProductFromCart = removeProductFromCart
        super.init(analyticsTitle: "cart", analyticsUrl: "/cart")
    }
    
    // MARK: - Methods
    
    override func onAppear() {
        super.onAppear()
        
        cart = getCart()
    }
    
    func navigateToPayment() {
        coordinator.showPaymentView()
    }
    
    func addProduct(_ product: ProductEntity) {
        addProductToCart(product)
        
        cart = getCart()
    }
    
    func removeProduct(_ product: ProductEntity) {
        removeProductFromCart(product)
        
        cart = getCart()
    }
}
