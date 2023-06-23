import Foundation


protocol Endpoint {
    
    var environment: EnvironmentDetails { get set }
    
    var queryItems: [URLQueryItem] { get set }
    
    var method: HTTPMethod { get set }
    
    var url: URL? { get }
    
    func urlRequest() throws -> URLRequest
}


// MARK: - Helpers

extension Endpoint {
    
    var url: URL? {
        var components = URLComponents(string: environment.chatURL)
        components?.queryItems = queryItems
        
        return components?.url
    }
    
    /// - Throws: ``CXoneChatError/invalidRequest`` if connection `url` is not set properly.
    func urlRequest() throws -> URLRequest {
        guard let url = self.url else {
            throw CXoneChatError.invalidRequest
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = self.method.rawValue
        
        return request
    }
}
