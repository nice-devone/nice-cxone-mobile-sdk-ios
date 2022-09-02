import Foundation
import XCTest
@testable import CXOneChatSDK
class URLSessionWebSocketTaskMock: URLSessionWebSocketTaskProtocol {
    var delegate: URLSessionTaskDelegate?
    
    var closure: ((String) -> Void)?
        
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping (Error?) -> Void) {
        
        var messageString = "messageString"
        if case URLSessionWebSocketTask.Message.string(let string) =  message{
            if string != "{\"action\":\"heartbeat\"}" {
                let data = string.data(using: .utf8)
                let decode = try! JSONDecoder().decode(EventPayLoadCodable.self, from: data!)
                switch decode.payload.eventType {
                case .authorizeCustomer:
                    let data = loadStubFromBundle(withName: "authorize", extension: "json")
                    messageString = String(data: data, encoding: .utf8)!
                    closure?(messageString)
                case .customerAuthorized, .tokenRefreshed, .messageCreated, .moreMessagesLoaded, .messageReadChanged, .threadRecovered,   .threadListFetched, .threadMetadataLoaded, .threadArchived, .contactInboxAssigneeChanged, .messageSeenByCustomer,.reconnectCustomer:
                    break
                case .refreshToken:
                    break
                case .sendMessage:
                    let data = loadStubFromBundle(withName: "MessageCreated", extension: "json")
                    messageString = String(data: data, encoding: .utf8)!
                case .loadThreadMetadata:
                    let data = loadStubFromBundle(withName: "threadMetadaLoaded", extension: "json")
                    messageString = String(data: data, encoding: .utf8)!
                    closure?(messageString)
                default:
                    break
                }
                closure?(messageString)
            } else {
                closure?(string)
            }
        }
    }

    func receive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void) {
        closure = { string in
            completionHandler(.success(.string(string)))
        }
    }

    func sendPing(pongReceiveHandler: @escaping (Error?) -> Void) {
        pongReceiveHandler(nil)
    }

    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
    }
    func resume() {
    }
    
    func loadStubFromBundle(withName name: String, extension: String) ->  Data {
        let url = URL(forResource: name, type: `extension`)
        return try! Data(contentsOf: url)
    }
    
}

class URLSessionMock: URLProtocol ,URLSessionProtocol {
    var delegate: URLSessionDelegate?
    
    func webSocketTask(with request: URLRequest) -> URLSessionWebSocketTaskMock {
        let task = URLSessionWebSocketTaskMock()
        return task
    }
//    init(delegate: URLSessionDelegate = CXOneChatSDK)) {
//        self.delegate = delegate
//    }
    
    override class func canInit(with request: URLRequest) -> Bool {
      return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      return request
    }
    
    override func startLoading() {
    }
    override func stopLoading() {
    }
    
}
