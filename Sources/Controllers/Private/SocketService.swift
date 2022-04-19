//
//  Created by Customer Dynamics Development on 8/31/21.
//

import Foundation

@available(iOS 13.0, *)
/// Class for interacting with the WebSocket.
public class SocketService: NSObject {
    
	// MARK: - Closures to WebSocket calls
	var delegate: CXOneChatDelegate?
	
	// MARK: - Properties
	var operationQueue: OperationQueue = OperationQueue()
    
    /// The WebSocket for sending and receiving messages.
	var socket: URLSessionWebSocketTaskProtocol?
    
    /// The auth token received from authorizing the customer. Only present in OAuth flow.
    var accessToken: AccessToken? {
        get {
            if let accessTokenData = UserDefaults.standard.data(forKey: "accessToken") {
                return try? JSONDecoder().decode(AccessToken.self, from: accessTokenData)
            } else {
                return nil
            }
        }
        set(accessToken) {
            let encodedToken = try? JSONEncoder().encode(accessToken)
            UserDefaults.standard.set(encodedToken, forKey: "accessToken")
            semaphore.signal()
        }
    }
    
    private let semaphore = DispatchSemaphore(value: 0)
    private let serialQueue = DispatchQueue(label: "Serial queue")
    private let personFormatter = PersonNameComponentsFormatter()
    
    /// Whether a pong was received for the heartbeat message.
    private var pongReceived = false
    private var pingTimer: Timer?
    private var pulseTimer: Timer?
	
	// MARK: - Initializer

    
    /// Opens a new WebSocket connection using the specified URL.
    ///
    /// - Parameter socketURL: The URL for the location of the WebSocket.
    public func connect(socketURL: URLRequest) {
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: operationQueue)
		self.socket = urlSession.webSocketTask(with: socketURL)
        self.socket!.sendPing(pongReceiveHandler: { error in
            guard error == nil else {
                self.disconnect()
                return
            }
		})
        pulseTimer = Timer.scheduledTimer(timeInterval: TimeInterval(3),
                             target: self,
                             selector: #selector(self.checkPulse),
                             userInfo: nil,
                             repeats: true)
        
		self.socket?.resume()
        self.addListener()
	}
    
    /// Closes the current WebSocket session.
    public func disconnect() {
		self.socket?.cancel(with: .goingAway, reason: nil)
        pingTimer?.invalidate()
        pulseTimer?.invalidate()
	}
	
    /// Sends a heartbeat message through the WebSocket and verifies the response.
    @objc private func checkPulse() {
        let dict = ["action":"heartbeat"]
        let data = try! JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
        let string = String(data: data, encoding: .utf8)
        pongReceived = false
        socket?.send(.string(string!), completionHandler: { [weak self] error in
            self?.verifyPulse()
        })
    }
   
    /// Verifies that a pong was received. If it wasn't received, the WebSocket connection is closed.
    private func verifyPulse() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            if self.pongReceived == false {
                self.delegate?.didCloseConnection()
            }
        })
    }
    
    
    //MARK: - Ping Pong
	
    /// Sends a ping through the WebSocket to ensure that the server is connected.
	@objc public func ping() {
		self.socket?.sendPing { error in
            guard error == nil else {return}
            self.delegate?.didSendPing()
		}
	}
	//MARK: - Listener
    
	/// Starts listening for any message that is received from the WebSocket and handles it.
	public func addListener() {
		socket?.receive {[weak self] result in
            guard let self = self else {return}
			switch result {
			case .success(let response):
				switch response {
				case .data(let data):
					self.delegate?.didReceiveData(data)
				case .string(let message):
                    if message == "pong" {
                        self.pongReceived = true
                    }else {
                        self.delegate?.handleMessage(message: message)
                    }                    
				default:
					return
				}
				self.addListener()
			case .failure(let error):
				self.delegate?.didReceiveError(error)
			}
		}
	}
	
	
  
    //MARK: - Send to socket
	/// Sends a message through the WebSocket.
    ///
	/// - Parameters:
    ///   - message: The message to be sent.
    public func send(message: String, shouldCheck: Bool = true) {
        if shouldCheck && self.accessToken?.isExpired ?? false {
            self.delegate?.refreshToken()
            semaphore.wait()
        }
        socket?.send(.string(message)) { error in
            if let error = error {
                self.delegate?.didReceiveError(error)
            }
        }
	}
}

@available(iOS 13.0, *)
extension SocketService: URLSessionWebSocketDelegate {

	/// Called when `WebSocket` establishes a connection.
	public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
		self.delegate?.didOpenConnection()
	}

	/// Called when `WebSocket` disconnects.
	public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
		self.delegate?.didCloseConnection()
	}
    /// allow to maninthemiddle in debug to inspect trafic in tools like proxyman or charlesApp 
//    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        #if DEBUG
//        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
//        #endif
//        #if RELEASE
//        completionHandler(.performDefaultHandling, nil)
//        #endif

//    }
}
