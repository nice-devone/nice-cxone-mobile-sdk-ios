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

/// Records which threads have already had their Satisfaction Survey delivered to the integrating application.
///
/// A Satisfaction Survey is sent when a conversation ends, which is usually just after the customer has closed
/// the application, so it is frequently missed. The survey is recovered and delivered the next time the thread is
/// recovered — but only once. Unlike an inactivity popup, answering a survey produces no chat message: it is
/// submitted on the survey web page and the backend reports nothing back, so the survey stays the newest message
/// on the thread indefinitely and would otherwise be re-delivered on every recovery.
///
/// Delivery is recorded at the moment the SDK emits the event. The integrating application does not confirm
/// presentation, which means an application that receives the event and fails to present the survey loses it —
/// an accepted limitation, since the SDK cannot observe what the application put on screen.
///
/// State is device-local and keyed by thread. It is persisted through ``UserDefaultsService`` so it survives an
/// application relaunch — thread recovery runs on every cold start, so an in-memory flag would re-deliver the
/// survey every time the application is restarted. Sign-out purges `UserDefaults` in its entirety, which clears
/// this state along with it.
struct SatisfactionSurveyDeliveryStore {

    // MARK: - Properties

    /// Upper bound on retained thread identifiers, oldest evicted first.
    ///
    /// Sized well above the number of threads a single Live Chat recovery can surface so that a reconnect cannot
    /// re-deliver a survey whose identifier has already been evicted.
    static let capacity = 50

    private let userDefaultsService: UserDefaultsService

    // MARK: - Init

    init(userDefaultsService: UserDefaultsService) {
        self.userDefaultsService = userDefaultsService
    }

    // MARK: - Methods

    /// Whether the survey on the given thread has already been delivered on this device.
    func hasDelivered(threadId: String) -> Bool {
        storedThreadIds.contains(threadId)
    }

    /// Records the survey on the given thread as delivered, so it is never emitted again on this device.
    ///
    /// Live Chat recovers a single thread per recovery event, so this read-modify-write is not contended.
    /// Extending recovery to Messaging, where several threads can load concurrently, would require guarding it.
    func markDelivered(threadId: String) {
        var threadIds = storedThreadIds

        guard !threadIds.contains(threadId) else {
            return
        }

        threadIds.append(threadId)

        if threadIds.count > Self.capacity {
            threadIds.removeFirst(threadIds.count - Self.capacity)
        }

        userDefaultsService.set(threadIds, for: .deliveredSatisfactionSurveyThreadIds)
    }
}

// MARK: - Private Methods

private extension SatisfactionSurveyDeliveryStore {

    var storedThreadIds: [String] {
        userDefaultsService.get([String].self, for: .deliveredSatisfactionSurveyThreadIds) ?? []
    }
}
