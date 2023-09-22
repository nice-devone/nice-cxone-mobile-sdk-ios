import Foundation

struct ProductResponseDTO: Decodable {
    
    let products: [ProductEntity]
    
    let total: Int
    
    let skip: Int
    
    let limit: Int
}
