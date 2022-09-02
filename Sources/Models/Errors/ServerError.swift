import Foundation

struct ServerError {
    let message: String
    let connectionId: String
    let requestId: String
}

extension ServerError: Codable {}

extension ServerError: Error {}

extension ServerError: LocalizedError {
    var errorDescription: String? {
        return message
    }
}

