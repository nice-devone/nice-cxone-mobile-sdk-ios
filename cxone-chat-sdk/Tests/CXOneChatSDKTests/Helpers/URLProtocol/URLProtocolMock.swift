import Foundation

class URLProtocolMock: URLProtocol {
    
    // MARK: - Properties

    static var handlers = [ProtocolMockHandler]()

    // MARK: - Methods

    override class func canInit(with request: URLRequest) -> Bool {
        handlers.contains { $0.canHandle(request: request) }
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    static func with<T>(handlers: ProtocolMockHandler..., perform: () async throws -> T) async throws -> T {
        Self.handlers = handlers
        defer { Self.handlers = [] }

        return try await perform()
    }

    override func startLoading() {
        do {
            guard let (response, data) = try Self.handlers.first(where: { $0.canHandle(request: request) })?.handle(request: request) else {
                client?.urlProtocol(
                    self,
                    didFailWithError: NSError(
                        domain: "URLProtoMock",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "unexpected request: \(request)",
                            "request": request
                        ]
                    )
                )
                return
            }

            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }

            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(
                self,
                didFailWithError: NSError(
                    domain: "URLProtoMock",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "internal error: \(error)",
                        "request": request,
                        "cause": error
                    ]
                )
            )
        }
    }
    
    override func stopLoading() { }
}
