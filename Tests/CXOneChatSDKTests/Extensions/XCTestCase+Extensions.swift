//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import XCTest

extension XCTestCase {
    enum Errors: Error, CustomStringConvertible {
        case invalidStringData

        var description: String {
            return "Invalid String Data"
        }

    }

    func XCTAssertIs<Root, Type>(
        _ value: Root,
        _ type: Type.Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssert(
            value is Type,
            "Expected \(value) is \(type)",
            file: file,
            line: line
        )
    }

    func loadBundleData(from file: String, type: String) throws -> Data {
        return try Data(contentsOf: URL(forResource: file, type: type))
    }

    func loadBundleString(from file: String, type: String) throws -> String {
        let data = try loadBundleData(from: file, type: type)
        guard let string = String(data: data, encoding: .utf8) else {
            throw Errors.invalidStringData
        }

        return string
    }
}
