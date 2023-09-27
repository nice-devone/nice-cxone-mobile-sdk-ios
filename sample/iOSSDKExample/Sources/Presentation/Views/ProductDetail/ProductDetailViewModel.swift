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
