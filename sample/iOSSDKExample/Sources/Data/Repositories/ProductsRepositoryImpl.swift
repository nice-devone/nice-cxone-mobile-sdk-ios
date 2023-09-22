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
