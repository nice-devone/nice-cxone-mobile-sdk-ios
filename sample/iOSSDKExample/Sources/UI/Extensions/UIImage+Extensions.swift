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

import SwiftUI
import UIKit

extension UIImage {
    
    // MARK: - Methods
    
    static func load(_ named: String, from directory: FileManager.SearchPathDirectory) throws -> UIImage {
        guard var path = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            throw CommonError.unableToParse("documentsUrl")
        }
        
        path = path.appendingPathComponent(named)
        
        guard let image = UIImage(contentsOfFile: path.relativePath) else {
            throw CommonError.failed("Unable to get image named: \(named) from directory: \(path.relativePath).")
        }
        
        return image
    }
}
