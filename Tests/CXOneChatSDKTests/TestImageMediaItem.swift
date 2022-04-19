//
//  TestImageMediaItem.swift
//  
//
//  Created by kjoe on 1/6/22.
//

import XCTest
@testable import CXOneChatSDK 
@available(iOS 13.0, *)
class TestImageMediaItem: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitWithImageNotNil() {
        let image = UIImage(named: "test", in: .module, with: nil)
        let unwrapedImage = try! XCTUnwrap(image)
        let imagenMediaItem =  ImageMediaItem(image: unwrapedImage)
        XCTAssertNotNil(imagenMediaItem)
        
    }
    
    func testInitWithURlNotNil() {
        let bundle = Bundle(for: TestImageMediaItem.self)
        let url = bundle.resourceURL
        let urlUnwraped = try! XCTUnwrap(url)
        let media = ImageMediaItem(imageURL: urlUnwraped)
        XCTAssertNotNil(media)
    }

}
