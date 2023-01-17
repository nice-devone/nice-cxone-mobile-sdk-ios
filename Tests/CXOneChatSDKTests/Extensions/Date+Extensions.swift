@testable import CXoneChatSDK
import Foundation


extension Date {
    
    // MARK: - Methods
    
    static func ISO8601(from string: String) throws -> Date {
        let dateFormatter = ISO8601DateFormatter()
        
        guard let date = dateFormatter.date(from: string) else {
            throw CXoneChatError.missingParameter("date")
        }
        
        return date
    }
}
