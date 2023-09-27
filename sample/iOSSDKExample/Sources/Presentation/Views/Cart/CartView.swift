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

import SwiftUI

struct CartView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: CartViewModel
    
    // MARK: - Builder
    
    var body: some View {
        VStack {
            if viewModel.cart.isEmpty {
                Text(L10n.Cart.Empty.title)
            } else {
                ScrollView(showsIndicators: false) {
                    ForEach(viewModel.cart, id: \.product.id) { item in
                        CartItem(item.product, quantity: .constant(item.quantity)) { increase in
                            if increase {
                                viewModel.addProduct(item.product)
                            } else {
                                viewModel.removeProduct(item.product)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    
                    Spacer(minLength: 32)
                }
                
                CartSummaryView(totalAmount: .constant(viewModel.totalAmount)) {
                    viewModel.navigateToPayment()
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear(perform: viewModel.onAppear)
        .navigationBarTitle(L10n.Cart.title)
    }
}

// MARK: - Preview

// swiftlint:disable force_unwrapping
struct CartView_Previews: PreviewProvider {
    
    private static let coordinator = LoginCoordinator(navigationController: UINavigationController())
    private static var appModule = PreviewAppModule(coordinator: coordinator) {
        didSet {
            coordinator.assembler = appModule.assembler
        }
    }
    
    static var previews: some View {
        Group {
            NavigationView {
                appModule.resolver.resolve(CartView.self)!
            }
            .previewDisplayName("Light Mode")
            
            NavigationView {
                appModule.resolver.resolve(CartView.self)!
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
