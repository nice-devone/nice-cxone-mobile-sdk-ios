import Foundation


public protocol URLSessionProtocol {
    associatedtype dta: URLSessionWebSocketTaskProtocol
    func webSocketTask(with request: URLRequest) -> dta
    var delegate: URLSessionDelegate? { get }
}

extension URLSession: URLSessionProtocol {}

@available(iOS 13.0, *)
public protocol URLSessionWebSocketTaskProtocol {

    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping (Error?) -> Void)
    func receive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void)
    func sendPing(pongReceiveHandler: @escaping (Error?) -> Void)
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    func resume()
    @available(iOS 15.0, *)
    var delegate: URLSessionTaskDelegate? { get set }
}

extension URLSessionWebSocketTask: URLSessionWebSocketTaskProtocol {
}
