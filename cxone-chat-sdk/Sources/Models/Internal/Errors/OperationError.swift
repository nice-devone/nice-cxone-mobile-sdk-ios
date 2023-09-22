import Foundation

struct OperationError: Codable, LocalizedError {
    
    let errorCode: ErrorCode

    let transactionId: LowerCaseUUID

    let errorMessage: String

    var errorDescription: String? { errorCode.rawValue }
}
