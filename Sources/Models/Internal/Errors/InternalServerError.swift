import Foundation


// MARK: - InternalServerError

struct InternalServerError: LocalizedError, Codable {
    
    let eventId: UUID

    let error: OperationError

    let inputData: InternalServerErrorInputDataDTO
}


// MARK: - InternalServerErrorInputData

struct InternalServerErrorInputDataDTO: Codable {
    
    let thread: ThreadDTO?
}
