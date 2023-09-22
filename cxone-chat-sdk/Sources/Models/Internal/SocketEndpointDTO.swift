import Foundation

struct SocketEndpointDTO: Endpoint {
    
    var environment: EnvironmentDetails

    var queryItems: [URLQueryItem]

    var method: HTTPMethod

    var url: URL? {
        var components = URLComponents(string: environment.socketURL)
        components?.queryItems = queryItems

        return components?.url
    }
}
