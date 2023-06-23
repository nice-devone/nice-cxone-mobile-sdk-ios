import Foundation


extension URLSession {
    
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func data(from url: URL, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                if let response = response as? HTTPURLResponse {
                    response.log(data: data, error: error, fun: fun, file: file, line: line)
                }
                
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (data, response))
            }
            
            task.resume()
        }
    }
    
    /// - Throws: ``URLError.badServerResponse`` if the URL Loading system received bad data from the server.
    /// - Throws: ``NSError`` object that indicates why the request failed
    func data(for request: URLRequest, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                if let response = response as? HTTPURLResponse {
                    response.log(data: data, error: error, fun: fun, file: file, line: line)
                }
                
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (data, response))
            }
            
            task.resume()
        }
    }
}
