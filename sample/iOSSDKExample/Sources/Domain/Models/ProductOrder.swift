import Foundation

struct ProductOrderEntity {
    
    let product: ProductEntity
    
    let quantity: Int
    
    var incremented: ProductOrderEntity {
        ProductOrderEntity(product: product, quantity: quantity + 1)
    }
    
    var decremented: ProductOrderEntity {
        ProductOrderEntity(product: product, quantity: quantity - 1)
    }
}
