import Foundation

struct OperationError: Codable, LocalizedError {
    let errorCode: ErrorCode
    let transactionId: String
    let errorMessage: String
    
    var errorDescription: String? {
        return errorCode.rawValue
    }
}
