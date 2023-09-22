import Foundation

protocol ProductsRepository {
    
    func get() async throws -> [ProductEntity]
}
