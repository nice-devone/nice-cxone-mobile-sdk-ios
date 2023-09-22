import Foundation

typealias URLProtocolMatcher = (URLRequest) -> Bool

func url(equals url: String, method: String = "GET") -> URLProtocolMatcher {
    { request in
        request.httpMethod == method && request.url?.absoluteString == url
    }
}

func url(matches url: String, method: String = "GET") -> URLProtocolMatcher {
    { request in
        request.httpMethod == method && request.url?.absoluteString.range(of: url, options: .regularExpression) != nil
    }
}
