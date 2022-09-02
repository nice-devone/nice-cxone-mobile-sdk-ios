import XCTest
@testable import CXOneChatSDK
class EndpointTest: XCTestCase {

    var sut: Endpoint?
    override func setUpWithError() throws {
        
        let brandItem = URLQueryItem(name: "brand", value: "1326")
        let channelItem = URLQueryItem(name: "channelId", value: "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4")
        //customerId=\(user.id)&v=4.74&EIO=3&transport=polling&t=NlrXzTa"
        let customerIdItem = URLQueryItem(name: "customerId", value: UUID().uuidString)
        let vQItem = URLQueryItem(name: "v", value: "4.74")
        let eioQItem = URLQueryItem(name: "EIO", value: "3")
        let transportQItem = URLQueryItem(name: "transport", value: "polling")
        let tQItem = URLQueryItem(name: "t", value: "NlrXzTa")

        sut = SocketEndpoint(environment: Environment.NA1, queryItems: [brandItem,channelItem,customerIdItem,vQItem,eioQItem,transportQItem,tQItem], method: .get)
    }

    override func tearDownWithError() throws {
       sut = nil
    }
    
    func testURLisValid() {
        XCTAssertNotNil(sut?.url)
        XCTAssertNoThrow(try sut?.urlRequest())
    }

    func testSchemeIsWss() {
        XCTAssertTrue(sut?.url?.scheme == "wss")
    }
    
    func testHostIsNA1() {
        XCTAssertTrue(sut?.url?.host == "chat-gateway-de-na1.niceincontact.com")
    }
    
    func testPathIsEmpty() {
        XCTAssertTrue(sut?.url?.path.isEmpty ?? true)
    }
    
    func testQuesyItemsNotNil() {
        XCTAssertTrue(sut?.url?.query?.isEmpty == false)
    }
    
    func testNumberOfQItemsMatch() {
        let number = sut?.url?.query?.components(separatedBy: "&").count
        let queryNumeber = sut?.queryItems.count
        XCTAssertTrue(sut?.queryItems.count == 7)
        XCTAssertTrue(number == 7)
        XCTAssertTrue(number == queryNumeber)
    }
    
    func testMethodIsGet() {
        let request = try? sut?.urlRequest()
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.httpMethod!.lowercased() == HTTPMethod.get.rawValue, "get not equal to \(request?.httpMethod?.lowercased() ?? "get")")
    }
    
    func testEndpointWithChatValue() {
        sut = MockEndpoint(environment: Environment.EU1, queryItems: [], method: .post)
        XCTAssertNotNil(sut?.url)
        XCTAssertNoThrow(try sut?.urlRequest())
        XCTAssertTrue(sut?.url?.scheme == "https")
        XCTAssertTrue(sut?.url?.host == "channels-de-eu1.niceincontact.com", "host is \(sut!.url!.host!)")
        XCTAssertTrue(sut?.url?.path.isEmpty == false)
        XCTAssertTrue(sut?.url?.path == "/chat", "\(sut!.url!.path) not equal to chat")
        XCTAssertTrue(sut?.url?.query?.isEmpty == true)
    }
    
}

struct MockEndpoint: Endpoint {
    var environment: EnvironmentDetails
    
    var queryItems: [URLQueryItem]
    
    var method: HTTPMethod
}
