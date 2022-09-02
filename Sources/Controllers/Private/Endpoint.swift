import Foundation
protocol Endpoint {
    var environment: EnvironmentDetails {get set}
    var queryItems: [URLQueryItem] {get set}
    var method: HTTPMethod {get set}
    var url: URL? {get}
    func urlRequest() throws -> URLRequest
}


extension Endpoint {
    var url: URL? {
        let urls = environment.chatURL
        var components = URLComponents(string: urls)
        components?.queryItems = queryItems
        return components?.url
    }
    
    func urlRequest() throws -> URLRequest {
        guard let url = self.url else {throw CXOneChatError.invalidRequest}
        var request = URLRequest(url: url)
        request.httpMethod = self.method.rawValue
        return request
    }
}

struct SocketEndpoint: Endpoint {
    var environment: EnvironmentDetails
    var queryItems: [URLQueryItem]
    var method: HTTPMethod
    
    var url: URL? {
        let urls = environment.socketURL
        var components = URLComponents(string: urls)
        components?.queryItems = queryItems
        return components?.url
    }
}



enum HTTPMethod: String{
    case post
    case get
    case put
    case delete
    case batch
}
