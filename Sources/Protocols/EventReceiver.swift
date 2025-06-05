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

import Combine
import Foundation

protocol EventReceiver: AnyObject {
    
    var events: AnyPublisher<ReceivedEvent, Never> { get }
    var cancellables: [AnyCancellable] { get set }
}

extension EventReceiver {
    
    func addListener<Type: ReceivedEvent>(
        for type: EventType,
        file: StaticString = #file,
        line: UInt = #line,
        with handler: @escaping (Type) throws -> Void
    ) {
        LogManager.trace(
            "Add listener for \(type): \(String(describing: Type.self))",
            file: file,
            line: line
        )
        events
            .with(type: type, as: Type.self)
            .sink { event in
                do {
                    try handler(event)
                } catch {
                    LogManager.error(error)
                }
            }
            .store(in: &cancellables)
    }

    func addListener<Type: ReceivedEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ handler: @escaping (Type) throws -> Void
    ) {
        LogManager.trace(
            "Add listener for: \(String(describing: Type.self))",
            file: file,
            line: line
        )
        events
            .with(type: Type.self)
            .sink { event in
                do {
                    try handler(event)
                } catch {
                    LogManager.error(error)
                }
            }
            .store(in: &cancellables)
    }
}
