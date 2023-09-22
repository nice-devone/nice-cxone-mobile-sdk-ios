import Foundation

protocol CartRepository {
    
    var cart: [ProductOrderEntity] { get }
    
    func addProduct(_ product: ProductEntity)
    func removeProduct(_ product: ProductEntity)
    func checkout()
}
