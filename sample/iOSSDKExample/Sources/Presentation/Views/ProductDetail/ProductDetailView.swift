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

struct ProductDetailView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ProductDetailViewModel
    
    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: 0) {
            ImageCarouselView(imageUrls: viewModel.product.imagesUrls)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(viewModel.product.brand)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Asset.Store.Product.rating
                            .font(.footnote)
                        
                        Text(viewModel.product.rating.description)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                
                Text(viewModel.product.title)
                    .font(.title)
                    .fontWeight(.heavy)
                
                scrollableDescriptionView

                Spacer(minLength: 20)
                
                HStack(spacing: 50) {
                    HStack(alignment: .top, spacing: 2) {
                        Text("$")
                            .font(.headline)
                        
                        Text(viewModel.product.price.description)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    
                    addToCartButton
                }
                .padding(.top, 20)
            }
            .padding([.top, .leading, .trailing], 16)
            .padding(.bottom, UIDevice.hasBottomSafeAreaInsets ? 32 : 16)
            .background(Color(.systemGray6))
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .padding(.top, -24)
            .shadow(color: .black.opacity(0.1), radius: 4, y: -4)
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear(perform: viewModel.onAppear)
        .navigationBarItems(trailing: cartNavigationButton)
    }
}

// MARK: - Subviews

private extension ProductDetailView {
    
    @ViewBuilder
    var scrollableDescriptionView: some View {
        Text(L10n.ProductDetail.description)
            .fontWeight(.bold)
            .foregroundColor(.gray)
            .padding(.top, 14)
        
        ZStack(alignment: .bottom) {
            let textHeight = viewModel.product.description.height(withConstrainedWidth: UIScreen.main.bounds.width, font: .body)
            
            ScrollView(
                textHeight > 100 ? .vertical : [],
                showsIndicators: false
            ) {
                Text(viewModel.product.description)
            }
            .frame(maxHeight: textHeight)
            
            LinearGradient(colors: [.clear, Color(.systemGray6)], startPoint: .top, endPoint: .bottom)
                .frame(height: 24)
                .opacity(textHeight > 100 ? 1 : 0)
        }
    }
    
    var cartNavigationButton: some View {
        Button {
            viewModel.navigateToCart()
        } label: {
            ZStack {
                Asset.Store.cart
                
                if viewModel.itemsInCart > 0 {
                    Text(viewModel.itemsInCart.description)
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 2)
                        )
                        .offset(x: 12, y: 12)
                }
            }
        }
    }
    
    var addToCartButton: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                withAnimation {
                    viewModel.addToCart()
                }
            } label: {
                HStack(spacing: 6) {
                    Asset.Store.cart
                    
                    Text(L10n.ProductDetail.AddToCart.title)
                        .fontWeight(.bold)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            
            if viewModel.productQuantityInCart > 0 {
                Text(viewModel.productQuantityInCart.description)
                    .fontWeight(.bold)
                    .padding(12)
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.accentColor)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color(.systemGray6), lineWidth: 4)
                    )
                    .offset(x: 12, y: -20)
                    .animation(.spring())
            }
        }
    }
}

// MARK: - Preview

// swiftlint:disable force_unwrapping
struct ProductDetailView_Previews: PreviewProvider {
    
    private static let coordinator = LoginCoordinator(navigationController: UINavigationController())
    private static var appModule = PreviewAppModule(coordinator: coordinator) {
        didSet {
            coordinator.assembler = appModule.assembler
        }
    }
    
    static var previews: some View {
        Group {
            NavigationView {
                ProductDetailView(
                    viewModel: ProductDetailViewModel(
                        coordinator: coordinator.storeCoordinator,
                        product: ProductEntity(
                            id: 1,
                            title: "iPhone 9",
                            description: "An apple mobile which is nothing like apple",
                            price: 549,
                            rating: 4.56,
                            brand: "Apple",
                            thumbnailUrl: URL(string: "https://i.dummyjson.com/data/products/1/thumbnail.jpg")!,
                            imagesUrls: [
                                URL(string: "https://i.dummyjson.com/data/products/1/1.jpg")!
                            ]
                        ),
                        getCart: appModule.resolver.resolve(GetCartUseCase.self)!,
                        addProductToCart: appModule.resolver.resolve(AddProductToCartUseCase.self)!
                    )
                )
            }
            .previewDisplayName("Light Mode")
            
            NavigationView {
                ProductDetailView(
                    viewModel: ProductDetailViewModel(
                        coordinator: coordinator.storeCoordinator,
                        product: ProductEntity(
                            id: 1,
                            title: "iPhone 9",
                            description: "An apple mobile which is nothing like apple",
                            price: 549,
                            rating: 4.56,
                            brand: "Apple",
                            thumbnailUrl: URL(string: "https://i.dummyjson.com/data/products/1/thumbnail.jpg")!,
                            imagesUrls: [
                                URL(string: "https://i.dummyjson.com/data/products/1/1.jpg")!
                            ]
                        ),
                        getCart: appModule.resolver.resolve(GetCartUseCase.self)!,
                        addProductToCart: appModule.resolver.resolve(AddProductToCartUseCase.self)!
                    )
                )
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
