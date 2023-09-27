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

class StoreViewModel: AnalyticsReporter, ObservableObject {
    
    // MARK: - Properties
    
    private var deeplinkOption: DeeplinkOption?
    
    private let getProducts: GetProductsUseCase
    private let getCart: GetCartUseCase
    
    private let coordinator: StoreCoordinator
    
    @Published var products = [ProductEntity]()
    @Published var itemsInCart = 0
    @Published var isLoading = true
    @Published var error: Error?
    
    // MARK: - Init
    
    init(
        coordinator: StoreCoordinator,
        deeplinkOption: DeeplinkOption?,
        getProducts: GetProductsUseCase,
        getCart: GetCartUseCase
    ) {
        self.coordinator = coordinator
        self.deeplinkOption = deeplinkOption
        self.getProducts = getProducts
        self.getCart = getCart
        super.init(analyticsTitle: "products?smartphones", analyticsUrl: "/products/smartphones")
    }
    
    // MARK: - Methods
    
    override func onAppear() {
        super.onAppear()
        
        loadCart()
        loadProducts()
        
        if deeplinkOption != nil {
            openChat()
            
            self.deeplinkOption = nil
        }
    }
    
    func signOut() {
        Log.trace("Signing out")
        
        RemoteNotificationsManager.shared.unregister()
        
        CXoneChat.signOut()
        LocalStorageManager.reset()
        FileManager.default.eraseDocumentsFolder()
        
        coordinator.popToConfiguration?()
    }
    
    func openChat() {
        coordinator.openChat(deeplinkOption: deeplinkOption)
    }
    
    func navigateToCart() {
        coordinator.showCartView()
    }
    
    func navigateToSettings() {
        coordinator.showSettings?()
    }
    
    func navigateToProduct(_ product: ProductEntity) {
        coordinator.showProductDetailView(product: product)
    }
}

// MARK: - Private methods

private extension StoreViewModel {
    
    func loadCart() {
        itemsInCart = getCart().reduce(0) { $0 + $1.quantity }
    }
    
    func loadProducts() {
        isLoading = true
        
        Task { @MainActor in
            do {
                products = try await getProducts()
            } catch {
                error.logError()
                
                self.error = CommonError.failed(L10n.Common.genericError)
            }
            
            isLoading = false
        }
    }
}
