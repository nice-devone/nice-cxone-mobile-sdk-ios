@testable import CXoneChatSDK
import XCTest

class ErrorsTests: XCTestCase {
    
    // MARK: - OperationError
    
    func testOperationErrorDescription() {
        let error = OperationError(errorCode: .recoveringThreadFailed, transactionId: LowerCaseUUID(), errorMessage: "Recovering failed")
        
        XCTAssertEqual(error.errorDescription, ErrorCode.recoveringThreadFailed.rawValue)
    }
    
    // MARK: - ServerError
    
    func testServerErrorDescription() {
        let error = ServerError(message: "message", connectionId: UUID(), requestId: UUID())
        
        XCTAssertEqual(error.errorDescription, "message")
    }
	
    // MARK: - InternalServerError

    func testDecodingInternalServerError() throws {
        let message = """
            {
                "eventId": "52E519A4-60FD-4A40-9EF8-19E051A02AAB",
                "error": {
                    "errorMessage": "Internal server error",
                    "transactionId": "dde89887-60d8-448f-aee4-df6ea3174221",
                    "errorCode": "InconsistentData"
                },
                "inputData": {
                    "thread": {
                        "id": "chat_ea02df1d-2f67-44b4-bd44-eb7808df1fdc_701BD05B-2C65-4643-9F65-9C35D73697B9",
                        "idOnExternalPlatform": "701BD05B-2C65-4643-9F65-9C35D73697B9"
                    }
                }
            }
        """
        let error: GenericEventDTO = try Data(message.utf8).decode()
        
        XCTAssertEqual(error.error?.errorCode, ErrorCode.inconsistentData)
    }
}
