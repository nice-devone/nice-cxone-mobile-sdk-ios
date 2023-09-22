import Foundation

enum CommonError: LocalizedError {
    case failed(String)
    case error(Error)
    
    var localizedDescription: String {
        switch self {
        case .error(let error):
            return error.localizedDescription
        case .failed(let message):
            return message
        }
    }
}

// MARK: - Internal merohds

extension CommonError {
    
    static func unableToParse(_ parameter: String, from data: Any? = nil) -> CommonError {
        if let data = data {
            return .failed("Unable to parse '\(parameter)' from: \(data).")
        } else {
            return .failed("Unable to parse '\(parameter)'.")
        }
        
    }
    
    func logError() {
        Log.error(self)
    }
}
