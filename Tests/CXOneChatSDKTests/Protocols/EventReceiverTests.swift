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
@testable import CXoneChatSDK
import Mockable
import XCTest

final class EventReceiverTests: XCTestCase {
    class Receiver: EventReceiver {
        let events: AnyPublisher<any CXoneChatSDK.ReceivedEvent, Never>
        var cancellables: [AnyCancellable]

        init(
            events: any Publisher<any CXoneChatSDK.ReceivedEvent, Never> = PassthroughSubject(),
            cancellables: [AnyCancellable] = []
        ) {
            self.events = events.eraseToAnyPublisher()
            self.cancellables = cancellables
        }
    }

    func testAddEventTypeListener() async throws {
        let events = PassthroughSubject<ReceivedEvent, Never>()
        let receiver = Receiver(events: events)
        let eventReceived = expectation(description: "Event Received")

        receiver.addListener(for: .threadArchived) { (event: GenericEventDTO) in
            eventReceived.fulfill()
        }

        XCTAssertEqual(receiver.cancellables.count, 1)

        events.send(
            GenericEventDTO(
                eventId: UUID(),
                eventType: .threadArchived,
                postback: nil
            )
        )

        await fulfillment(of: [eventReceived], timeout: 0.2)
    }

    func testAddTypeListener() async throws {
        let events = PassthroughSubject<ReceivedEvent, Never>()
        let receiver = Receiver(events: events)
        let eventReceived = expectation(description: "Event Received")

        receiver.addListener { (event: SetPositionInQueueEventDTO) in
            eventReceived.fulfill()
        }

        XCTAssertEqual(receiver.cancellables.count, 1)

        guard let event = try loadBundleData(from: "SetPositionInQueue", type: "json").toReceivedEvent() else {
            XCTFail("Can't load event from SetPositionInQueue")
            return
        }

        events.send(event)

        await fulfillment(of: [eventReceived], timeout: 0.2)
    }
}
