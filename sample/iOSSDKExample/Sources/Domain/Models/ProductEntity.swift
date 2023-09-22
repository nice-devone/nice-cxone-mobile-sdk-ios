import SwiftUI

class ProductEntity: Identifiable, Decodable {
    
    // MARK: - Properties
    
    let id: Int
    
    let title: String
    
    let description: String
    
    let price: Double
    
    let rating: Double
    
    let brand: String
    
    let thumbnailUrl: URL
    
    let imagesUrls: [URL]
    
    // MARK: - Init
    
    init(id: Int, title: String, description: String, price: Double, rating: Double, brand: String, thumbnailUrl: URL, imagesUrls: [URL]) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.rating = rating
        self.brand = brand
        self.thumbnailUrl = thumbnailUrl
        self.imagesUrls = imagesUrls
    }
    
    // MARK: - Decodable
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case description
        case price
        case rating
        case brand
        case thumbnail
        case images
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.price = try container.decode(Double.self, forKey: .price)
        self.rating = try container.decode(Double.self, forKey: .rating)
        self.brand = try container.decode(String.self, forKey: .brand)
        self.thumbnailUrl = try container.decode(URL.self, forKey: .thumbnail)
        self.imagesUrls = try container.decode([URL].self, forKey: .images)
    }
}

// MARK: - Equatable
    
extension ProductEntity: Equatable {
    
    static func == (lhs: ProductEntity, rhs: ProductEntity) -> Bool {
        lhs.id == rhs.id
    }
}
