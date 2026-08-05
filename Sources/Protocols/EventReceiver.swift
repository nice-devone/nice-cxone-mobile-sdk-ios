//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Foundation

protocol EventReceiver: AnyObject {

    var eventBroadcast: EventBroadcast { get }
    var listenerTasks: [Task<Void, Never>] { get set }
}

extension EventReceiver {

    func addListener<Type: ReceivedEvent>(
        for type: EventType,
        file: StaticString = #file,
        line: UInt = #line,
        with handler: @escaping @Sendable (Type) throws -> Void
    ) {
        LogManager.trace(
            "Add listener for \(type): \(String(describing: Type.self))",
            file: file,
            line: line
        )
        // Subscribe synchronously before the task starts so no events are missed.
        let stream = eventBroadcast.makeStream()
        let task = Task {
            for await event in stream {
                guard event.realEventType == type, let typed = event as? Type else {
                    continue
                }

                do {
                    try handler(typed)
                } catch {
                    LogManager.error(error)
                }
            }
        }

        listenerTasks.append(task)
    }

    func addListener<Type: ReceivedEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ handler: @escaping @Sendable (Type) throws -> Void
    ) {
        LogManager.trace(
            "Add listener for: \(String(describing: Type.self))",
            file: file,
            line: line
        )

        let stream = eventBroadcast.makeStream()
        let eventType = Type.associatedEventType
        let task = Task {
            for await event in stream {
                if let eventType, event.realEventType != eventType {
                    continue
                }

                guard let typed = event as? Type else {
                    continue
                }

                do {
                    try handler(typed)
                } catch {
                    LogManager.error(error)
                }
            }
        }

        listenerTasks.append(task)
    }

    func addListener<Type: ReceivedEvent>(
        file: StaticString = #file,
        line: UInt = #line,
        _ handler: @escaping @Sendable (Type) async throws -> Void
    ) {
        LogManager.trace(
            "Add listener for: \(String(describing: Type.self))",
            file: file,
            line: line
        )

        let stream = eventBroadcast.makeStream()
        let eventType = Type.associatedEventType
        let task = Task {
            for await event in stream {
                if let eventType, event.realEventType != eventType {
                    continue
                }

                guard let typed = event as? Type else {
                    continue
                }

                do {
                    try await handler(typed)
                } catch {
                    LogManager.error(error)
                }
            }
        }

        listenerTasks.append(task)
    }
}
