import Foundation

extension URLSession {
    
    func download(with request: URLRequest) async throws -> (URL?, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.downloadTask(with: request) { url, response, error in
                guard let url = url, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (url, response))
            }
            
            task.resume()
        }
    }
}
