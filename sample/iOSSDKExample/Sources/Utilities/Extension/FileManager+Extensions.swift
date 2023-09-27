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

import UIKit

extension FileManager {
    
    func eraseDocumentsFolder() {
        guard let documentsPath = urls(for: .documentDirectory, in: .userDomainMask).first?.relativePath else {
            return
        }
        
        do {
            for fileName in try contentsOfDirectory(atPath: documentsPath) {
                try removeItem(atPath: URL(fileURLWithPath: documentsPath).appendingPathComponent(fileName).path)
            }
        } catch {
            error.logError()
        }
    }
    
    func storeFileData(_ data: Data, named: String, in directory: SearchPathDirectory) throws {
        guard let directoryUrl = urls(for: directory, in: .userDomainMask).first else {
            return
        }
        
        let destinationUrl = directoryUrl.appendingPathComponent(named)
        
        try data.write(to: destinationUrl, options: [.atomic])
    }
    
    func storeRemoteFileLocally(remoteUrl: URL, named: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let documentsUrl = urls(for: .documentDirectory, in: .userDomainMask).first else {
            CommonError.unableToParse("documentsUrl").logError()
            return
        }
        
        let destinationUrl = documentsUrl.appendingPathComponent(named)
        
        if FileManager().fileExists(atPath: destinationUrl.path) {
            completion(.success(destinationUrl))
        } else {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: remoteUrl)
            request.httpMethod = "GET"
            
            let task = session.downloadTask(with: request) { localUrl, response, error in
                if FileManager().fileExists(atPath: destinationUrl.path) {
                    completion(.success(destinationUrl))
                } else if let response = response as? HTTPURLResponse, response.statusCode == 200, let localUrl {
                    do {
                        try FileManager.default.moveItem(at: localUrl, to: destinationUrl)
                        
                        completion(.success(destinationUrl))
                    } catch {
                        completion(.failure(error))
                    }
                } else if let error {
                    completion(.failure(error))
                } else {
                    let error = NSError(domain: "Error downloading file", code: 1002, userInfo: nil)
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
        
    }
}
