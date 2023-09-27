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

struct StoreCard: View {
    
    // MARK: - Properties
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var thumbnailUrl: URL
    @State var title: String
    @State var price: Double
    
    // MARK: - Builder
    
    var body: some View {
        VStack {
            KFImage(thumbnailUrl)
                .resizable()
                .scaledToFit()
                .cornerRadius(10, corners: [.topLeft, .topRight])
            
            VStack {
                Text(title)
                    .foregroundColor(Color(.systemGray))
                    .font(.caption)
                    .fontWeight(.bold)
                
                HStack(alignment: .top, spacing: 0) {
                    Text("$")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    Text(String(format: "%0.2f", price))
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            .padding([.horizontal, .bottom], 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: colorScheme == .dark ? .clear : Color(.systemGray4), radius: 2, x: 2, y: 2)
        )
    }
}

// MARK: - Preview

// swiftlint:disable force_unwrapping
struct StoreCard_Previews: PreviewProvider {
    
    @State private static var products = [
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
        ProductEntity(
            id: 2,
            title: "iPhone X",
            description: "SIM-Free, Model A19211 6.5-inch Super Retina HD display with OLED technology A12 Bionic chip with ...",
            price: 899,
            rating: 4.44,
            brand: "Apple",
            thumbnailUrl: URL(string: "https://i.dummyjson.com/data/products/2/thumbnail.jpg")!,
            imagesUrls: [
                URL(string: "https://i.dummyjson.com/data/products/2/1.jpg")!
            ]
        )
    ]
    static var previews: some View {
        Group {
            HStack(alignment: .top) {
                ForEach(products, id: \.id) { product in
                    StoreCard(
                        thumbnailUrl: product.thumbnailUrl,
                        title: product.title,
                        price: product.price
                    )
                }
            }
            .padding()
            .previewDisplayName("Light Mode")
            
            HStack(alignment: .top) {
                ForEach(products, id: \.id) { product in
                    StoreCard(
                        thumbnailUrl: product.thumbnailUrl,
                        title: product.title,
                        price: product.price
                    )
                }
            }
            .padding()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
