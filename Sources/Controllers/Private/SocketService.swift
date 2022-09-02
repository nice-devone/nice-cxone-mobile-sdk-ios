import Foundation
import KeychainSwift
@available(iOS 13.0, *)

/// Class for interacting with the WebSocket.
internal class SocketService: NSObject {
    
	var delegate: CXOneChatDelegate?
    
    /// Whether the socket is currently connected.
    var connected: Bool {
        return socket != nil
    }
    
    /// The auth token received from authorizing the customer. Only present in OAuth flow.
    var accessToken: AccessToken? {
        get {
            let keychain = KeychainSwift()
            let accessTokenData = keychain.getData("accessToken")
            if let accessTokenData = accessTokenData {
                return try? JSONDecoder().decode(AccessToken.self, from: accessTokenData)
            } else {
                return nil
            }
        }
        set {
            let keychain = KeychainSwift()
            let encodedToken = try? JSONEncoder().encode(newValue)
            guard let encodedToken = encodedToken else {return}
            keychain.set(encodedToken, forKey: "accessToken")
            semaphore.signal()
        }
    }
	
	private var operationQueue: OperationQueue = OperationQueue()
    
    /// The WebSocket for sending and receiving messages.
	private var socket: URLSessionWebSocketTaskProtocol?
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    /// Whether a pong was received for the heartbeat message.
    private var pongReceived = false

    /// The timer for when pulse messages should be sent.
    private var pulseTimer: Timer?
    
    /// Opens a new WebSocket connection using the specified URL.
    /// - Parameter socketURL: The URL for the location of the WebSocket.
    func connect(socketURL: URLRequest, config: URLSessionConfiguration = .default ) {
        let urlSession = URLSession(configuration: config, delegate: self, delegateQueue: operationQueue)
        
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
        pulseTimer?.invalidate()
	}
    
    /// Sends a message through the WebSocket.
    /// - Parameters:
    ///   - message: The message to be sent.
    ///   - shouldCheck: Whether to check for an expired access token.
    func send(message: String, shouldCheck: Bool = true) {
        if shouldCheck && self.accessToken?.isExpired ?? false {
            do {
                try self.delegate?.refreshToken()
                semaphore.wait()
            } catch {
                delegate?.didReceiveError(error)
            }
        }
        socket?.send(.string(message)) { error in
            if let error = error {
                self.delegate?.didReceiveError(error)
            }
        }
    }
    
    /// Sends a ping through the WebSocket to ensure that the server is connected.
    @objc public func ping() {
        self.socket?.sendPing { error in
            guard error == nil else {return}
        }
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
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
//            if self.pongReceived == false {
//                self.delegate?.didCloseConnection()
//            }
//        })
    }

	/// Starts listening for any message that is received from the WebSocket and handles it.
	private func addListener() {
		socket?.receive {[weak self] result in
            guard let self = self else {return}
			switch result {
			case .success(let response):
				switch response {
				case .data:
                    print("Did receive data?")
				case .string(let message):
                    if message == "\"pong\"" {
                        self.pongReceived = true
                    } else {
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
}

@available(iOS 13.0, *)
extension SocketService: URLSessionWebSocketDelegate {
	/// Called when the WebSocket disconnects.
	public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
		self.delegate?.didCloseConnection()
	}
    
#if DEBUG
    /// Allows for inspecting traffic in tools like Proxyman or CharlesApp.
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
#endif
}
