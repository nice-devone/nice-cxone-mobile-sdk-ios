import Foundation

typealias URLProtocolAction = (URLRequest)  throws -> (HTTPURLResponse, Data?)

func string(_ string: String, code: Int = 200) -> URLProtocolAction {
    lazy var data = string.data(using: .utf8)

    return { request in
        (
            HTTPURLResponse(
                url: request.url!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!,
            data
        )
    }
}

func data(_ data: Data, code: Int = 200) -> URLProtocolAction {
    { request in
        (
            HTTPURLResponse(
                url: request.url!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!,
            data
        )
    }
}

func resource(_ name: String, type: String, code: Int = 200) -> URLProtocolAction {
    { request in
        let url = URL(forResource: name, type: type)

        return (
            HTTPURLResponse(
                url: request.url!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!,
            try Data(contentsOf: url)
        )
    }
}

func none(code: Int = 200) -> URLProtocolAction {
    { request in
        (
            HTTPURLResponse(
                url: request.url!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!,
            nil
        )
    }
}
