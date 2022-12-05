import Foundation


extension URLRequest {
    
    init(url: URL, method: HTTPMethod, contentType: String) {
        self.init(url: url)
        
        httpMethod = method.rawValue
        setValue(contentType, forHTTPHeaderField: "Content-Type")
    }
}
