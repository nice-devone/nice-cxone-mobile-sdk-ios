import XCTest
@testable import CXoneChatSDK


class LowerCaseUUIDTest: XCTestCase {

    func testLowerCaseIsEaquelToUpperCaseStringUUId() throws {
        let uuid = UUID()
        let data = try JSONEncoder().encode(LowerCaseUUID(uuid: uuid))
        
        XCTAssertEqual(uuid.uuidString.lowercased(), data.utf8string.replacingOccurrences(of: "\"", with: ""))
    }
}
