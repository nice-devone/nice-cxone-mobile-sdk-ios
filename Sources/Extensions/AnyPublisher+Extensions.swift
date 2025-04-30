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

extension AnyPublisher<any ReceivedEvent, Never> {

    @discardableResult
    func sink<Type: ReceivedEvent>(
        dataType: Type.Type,
        origin event: EventDTO,
        socketService: SocketService,
        eventsService: EventsService,
        cancellables: inout [AnyCancellable]
    ) async throws -> `Type` {
        try await self.sink(
            publisher: self.with(type: dataType),
            origin: event,
            socketService: socketService,
            eventsService: eventsService,
            cancellables: &cancellables
        )
    }
        
    @discardableResult
    func sink<Type: ReceivedEvent>( // swiftlint:disable:this function_parameter_count
        type: EventType,
        as dataType: Type.Type,
        origin event: EventDTO,
        socketService: SocketService,
        eventsService: EventsService,
        cancellables: inout [AnyCancellable]
    ) async throws -> `Type` {
        try await self.sink(
            publisher: self.with(type: type, as: dataType),
            origin: event,
            socketService: socketService,
            eventsService: eventsService,
            cancellables: &cancellables
        )
    }
}

// MARK: - Helpers

private extension AnyPublisher<any ReceivedEvent, Never> {

    private func sink<Type: ReceivedEvent>(
        publisher: some Publisher<Type, Never>,
        origin event: EventDTO,
        socketService: SocketService,
        eventsService: EventsService,
        cancellables: inout [AnyCancellable]
    ) async throws -> `Type` {
        var result: `Type`?
        var handleTimeout = true
        
        async let request: () = socketService.send(data: try eventsService.serialize(event: event))
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(), any Error>) in
            publisher
                .setFailureType(to: CXoneChatError.self)
                // swiftlint:disable:next trailing_closure
                .timeout(.seconds(EventsService.responseTimeout), scheduler: DispatchQueue.main, customError: {
                    .eventTimeout
                })
                .sink { completion in
                    // If a post is received it will hit the receive value block followed by the completion block -> skip the completion failure block.
                    // If a post is not received and it times out, it skips the receive value block -> handle the completion failure block.
                    if case .failure(let error) = completion, handleTimeout {
                        LogManager.error("Did recieve error: \(error) for eventType: \(event.payload.eventType)")
                        
                        continuation.resume(throwing: error)
                    }
                } receiveValue: { response in
                    if response.eventId == event.eventId {
                        LogManager.info(
                            "Did recieve event with same eventId: \(response.eventId) for event: \(response.realEventType?.rawValue ?? "unknown")"
                        )
                        
                        handleTimeout = false
                        result = response
                        
                        continuation.resume()
                    }
                }
                .store(in: &cancellables)
            
            self
                .with(type: OperationError.self)
                .sink { error in
                    if error.eventId == event.eventId {
                        LogManager.error("Did recieve error: \(error) for eventType: \(event.payload.eventType)")
                        handleTimeout = false
                        
                        continuation.resume(throwing: error)
                    }
                }
                .store(in: &cancellables)
        }
        
        try await request
        
        if let result {
            return result
        } else {
            throw CXoneChatError.invalidData
        }
    }
}
