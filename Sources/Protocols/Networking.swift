import Foundation


// MARK: - URLSessionProtocol

protocol URLSessionProtocol {
    associatedtype DTA: URLSessionWebSocketTaskProtocol
    func webSocketTask(with request: URLRequest) -> DTA
    var delegate: URLSessionDelegate? { get }
}


// MARK: - URLSession + URLSessionProtocol

extension URLSession: URLSessionProtocol {}


// MARK: - URLSessionWebSocketTaskProtocol

protocol URLSessionWebSocketTaskProtocol {
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping (Error?) -> Void)
    func receive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void)
    func sendPing(pongReceiveHandler: @escaping @Sendable (Error?) -> Void)
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    func resume()
    @available(iOS 15.0, *)
    var delegate: URLSessionTaskDelegate? { get set }
}


// MARK: - URLSessionWebSocketTask + URLSessionWebSocketTaskProtocol

extension URLSessionWebSocketTask: URLSessionWebSocketTaskProtocol { }
