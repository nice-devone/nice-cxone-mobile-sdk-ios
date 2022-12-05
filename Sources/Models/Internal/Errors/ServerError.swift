import Foundation


struct ServerError: LocalizedError, Codable {
    
    let message: String

    let connectionId: UUID

    let requestId: UUID

    var errorDescription: String? { message }
}
