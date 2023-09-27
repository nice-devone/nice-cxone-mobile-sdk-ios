//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

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
