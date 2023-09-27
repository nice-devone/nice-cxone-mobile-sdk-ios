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

import Foundation

class ProductsRepositoryImpl: ProductsRepository {
    
    // MARK: - Properties
    
    private let session: URLSession
    private let baseUrl: URL
    
    private var products = [ProductEntity]()
    
    // MARK: - Init
    
    init?(session: URLSession) {
        guard let url = URL(string: "https://dummyjson.com/products") else {
            return nil
        }
        
        self.baseUrl = url
        self.session = session
    }
    
    // MARK: - Methods
    
    func get() async throws -> [ProductEntity] {
        guard products.isEmpty else {
            return products
        }
        
        let (data, _) = try await session.data(from: baseUrl.appendingPathComponent("category/smartphones"))
        products = try JSONDecoder().decode(ProductResponseDTO.self, from: data).products
        
        return products
    }
}

// MARK: - Preview Mock

// swiftlint:disable force_unwrapping
class MockProductsRepositoryImpl: ProductsRepository {
    
    // MARK: - Properties
    
    private var products = [
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
    
    // MARK: - Methods
    
    func get() async throws -> [ProductEntity] {
        products
    }
}
