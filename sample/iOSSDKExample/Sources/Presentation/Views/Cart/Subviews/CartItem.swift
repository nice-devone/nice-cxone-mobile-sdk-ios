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

import Kingfisher
import SwiftUI

struct CartItem: View {
    
    // MARK: - Properties
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var quantity: Int
    
    let product: ProductEntity
    let changeQuantity: (_ increase: Bool) -> Void
    
    // MARK: - Init
    
    init(_ product: ProductEntity, quantity: Binding<Int>, changeQuantity: @escaping (Bool) -> Void) {
        self.product = product
        self._quantity = quantity
        self.changeQuantity = changeQuantity
    }
    
    // MARK: - Builder
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            KFImage(product.thumbnailUrl)
                .placeholder {
                    Asset.Store.Product.imagePlaceholder
                        .frame(width: 80, height: 80)
                        .background(Color.gray)
                        .cornerRadius(6)
                }
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 50)
                .cornerRadius(6)
            
            productDescription
            
            Spacer()
            
            quantityControl
        }
        .padding(.leading, 16)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(colorScheme == .dark ? Color(.systemGray5) : .white)
                .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 2)
        )
    }
}

// MARK: - Subviews

private extension CartItem {
    
    var productDescription: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(product.title)
                .font(.title)
                .fontWeight(.bold)
            
            HStack(alignment: .top, spacing: 2) {
                Text("$")
                    .font(.caption)
                
                Text(String(format: "%0.2f", product.price))
                    .font(.headline)
                    .fontWeight(.heavy)
            }
        }
    }
    
    var quantityControl: some View {
        VStack(alignment: .center, spacing: 4) {
            
            Button("+") {
                changeQuantity(true)
                
                quantity += 1
            }
            .adjustForA11y()
            .font(.largeTitle)
            
            Text(quantity.description)
                .font(.headline)
            
            Button("-") {
                changeQuantity(false)
                
                if quantity > 1 {
                    quantity -= 1
                }
            }
            .adjustForA11y()
            .font(.largeTitle)
        }
    }
}

// MARK: - Preview

// swiftlint:disable force_unwrapping
struct CartItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                ForEach(0..<3, id: \.self) { _ in
                    CartItem(
                        ProductEntity(
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
                        quantity: .constant(1)
                    ) { _ in
                        
                    }
                }
            }
            .padding()
            .previewDisplayName("Light Mode")
            
            VStack {
                ForEach(0..<3, id: \.self) { _ in
                    CartItem(
                        ProductEntity(
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
                        quantity: .constant(1)
                    ) { _ in
                        
                    }
                }
            }
            .padding()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
