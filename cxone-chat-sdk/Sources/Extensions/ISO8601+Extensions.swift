//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

import Foundation

// MARK: - ISO8601DateFormatter

extension ISO8601DateFormatter {
	convenience init(_ formatOptions: Options) {
		self.init()
        
		self.formatOptions = formatOptions
	}
}

// MARK: - Formatter

extension Formatter {
    static let iso8601withFractionalSeconds = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}

// MARK: - Date

extension Date {
	var iso8601withFractionalSeconds: String {
        Formatter.iso8601withFractionalSeconds.string(from: self)
    }
}

// MARK: - String

extension String {
	var iso8601withFractionalSeconds: Date? {
        Formatter.iso8601withFractionalSeconds.date(from: self)
    }
}
