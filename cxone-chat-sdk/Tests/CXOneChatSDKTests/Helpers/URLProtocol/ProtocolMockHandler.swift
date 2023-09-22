import Foundation

struct ProtocolMockHandler {
    // MARK: - Properties

    let canHandle: URLProtocolMatcher
    let handle: URLProtocolAction

    // MARK: - Methods

    func canHandle(request: URLRequest) -> Bool {
        canHandle(request)
    }

    func handle(request: URLRequest) throws -> (HTTPURLResponse, Data?) {
        try handle(request)
    }
}

func accept(
    _ matcher: @escaping URLProtocolMatcher,
    body handler: @escaping URLProtocolAction
) -> ProtocolMockHandler {
    ProtocolMockHandler(canHandle: matcher, handle: handler)
}
