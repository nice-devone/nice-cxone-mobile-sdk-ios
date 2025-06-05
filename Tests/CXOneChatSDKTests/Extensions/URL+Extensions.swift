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

import Foundation

extension URL {
    
    // MARK: - Properties
    
    private static let _resources: URL = {
        func packageRoot(of file: String) -> URL? {
            func isPackageRoot(_ url: URL) -> Bool {
                let filename = url.appendingPathComponent("Package.swift", isDirectory: false)
                
                return FileManager.default.fileExists(atPath: filename.path)
            }

            var url = URL(fileURLWithPath: file, isDirectory: false)
            
            repeat {
                url = url.deletingLastPathComponent()
                if url.pathComponents.count <= 1 {
                    return nil
                }
            } while !isPackageRoot(url)
            
            return url
        }

        guard let root = packageRoot(of: #file) else {
            fatalError("\(#file) must be contained in a Swift Package Manager project.")
        }
        
        let fileComponents = URL(fileURLWithPath: #file, isDirectory: false).pathComponents
        let rootComponents = root.pathComponents
        let trailingComponents = Array(fileComponents.dropFirst(rootComponents.count))
        let resourceComponents = rootComponents + trailingComponents[0...1] + ["Examples"]
        
        return URL(fileURLWithPath: resourceComponents.joined(separator: "/"), isDirectory: true)
    }()
    
    // MARK: - Init
    
    init(forResource name: String, type: String) {
        self = Self._resources.appendingPathComponent("\(name).\(type)", isDirectory: false)
    }
}
