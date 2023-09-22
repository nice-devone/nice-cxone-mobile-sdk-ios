import CXoneChatSDK
import SwiftUI

class PaymentDoneViewModel: AnalyticsReporter, ObservableObject {
    
    // MARK: - Properties
    
    private let coordinator: StoreCoordinator
    
    // MARK: - Init
    
    init(coordinator: StoreCoordinator) {
        self.coordinator = coordinator
        super.init(analyticsTitle: "confirmation", analyticsUrl: "/confirmation")
    }
    
    // MARK: - Methods
    
    func popToStore() {
        coordinator.popTo(UIHostingController<StoreView>.self)
    }
}
