
import XCTest
@testable import CXOneChatSDK
class LowerCaseUUIDTest: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }
    
    func testLowerCaseIsEaquelToUpperCaseStringUUId() {
        let uuid = UUID()
        let uuidLowerCased = LowerCaseUUID(uuid: uuid)

        let data = try! JSONEncoder().encode(uuidLowerCased)
        let uuidStringFromData = String(data: data, encoding: .utf8)
        let originalString = uuid.uuidString
        XCTAssertEqual(originalString.lowercased(), uuidStringFromData!.replacingOccurrences(of: "\"", with: ""))
    }
}
