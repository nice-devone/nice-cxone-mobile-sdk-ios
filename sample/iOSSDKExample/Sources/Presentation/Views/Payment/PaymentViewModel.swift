import CXoneChatSDK
import SwiftUI
import Swinject

class PaymentViewModel: AnalyticsReporter, ObservableObject {
    
    // MARK: - Properties
    
    private let getCart: GetCartUseCase
    private let checkoutCart: CheckoutCartUseCase
    
    private let coordinator: StoreCoordinator
    
    @Published var isLoading = false
    @Published var shouldNavigateToDone = false
    
    // MARK: - Properties
    
    var validUntil: String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MM/YY")
        
        guard let date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) else {
            Log.error(CommonError.unableToParse("date"))
            return ""
        }
        
        return formatter.string(from: date)
    }
    
    var totalAmount: Double {
        getCart().reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
    
    // MARK: - Init
    
    init(coordinator: StoreCoordinator, getCart: GetCartUseCase, checkoutCart: CheckoutCartUseCase) {
        self.coordinator = coordinator
        self.getCart = getCart
        self.checkoutCart = checkoutCart
        super.init(analyticsTitle: "payment", analyticsUrl: "/payment")
    }
    
    // MARK: - Methods
    
    @MainActor
    func checkout() async {
        isLoading = true
        
        await Task.sleep(seconds: Double.random(in: 0...2))
        
        checkoutCart()
        
        Task {
            do {
                try await CXoneChat.shared.analytics.conversion(type: "purchase", value: totalAmount)
            } catch {
                error.logError()
            }
        }
        
        coordinator.showPaymentDoneView()
    }
}
