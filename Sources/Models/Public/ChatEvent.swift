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

/// All events that can be emitted by the CXoneChat SDK.
///
/// Subscribe via ``ChatProvider/events()`` and `switch` over the cases your app cares about.
/// Each case documents *when* it fires and what the consumer is typically expected to do.
public enum ChatEvent: Sendable {

    /// The SDK's connection lifecycle has advanced or the channel mode resolved.
    ///
    /// Fires after `prepare(...)` and `connect()` complete (the `state` transitions through
    /// `.preparing` → `.prepared` → `.connecting` → `.connected` → `.ready`), and again on
    /// any later transition (e.g. to `.offline`). The `mode` reflects the channel's
    /// configuration (`.singlethread`, `.multithread`, `.liveChat`) and is stable for the
    /// session.
    ///
    /// Consumers typically use this to gate UI: enable the "Open Chat" button at
    /// `.ready`, show an offline state at `.offline`.
    case chatUpdated(state: ChatState, mode: ChatMode)

    /// A single thread changed — new messages arrived, the assigned agent changed, the
    /// thread name was updated, position in queue moved, etc.
    ///
    /// Refresh the corresponding view (single-thread and live-chat channels). For
    /// multi-thread channels this also fires when an individual thread you are observing
    /// changes; if you only need the list, observe ``threadsUpdated(_:)`` instead.
    case threadUpdated(ChatThread)

    /// The full thread list changed — a thread was created, archived, or its
    /// last-message preview was updated. Multi-thread channels only.
    ///
    /// Refresh your thread-list UI.
    case threadsUpdated([ChatThread])

    /// The WebSocket connection dropped without an explicit `disconnect()` or `signOut()`
    /// call — e.g. the device lost the network, the server closed the connection, or a
    /// transport error fired.
    ///
    /// The SDK does not auto-reconnect. Consumers typically retry `connect()` (possibly
    /// after a backoff) and surface a "Reconnecting…" state to the user.
    case unexpectedDisconnect

    /// A custom plugin message was received from the agent side. The raw payload is
    /// delivered as `Data` so consumer-side handlers can decode app-specific schemas.
    case customEventMessage(Data)

    /// An agent started or stopped typing in a specific thread.
    ///
    /// Show or hide a typing indicator in the thread identified by `threadId`. The
    /// `agent` value carries the agent's display info; `isTyping == false` indicates the
    /// agent stopped (no separate "stopped" event).
    case agentTyping(isTyping: Bool, agent: Agent, threadId: String)

    /// The currently active thread's contact custom fields were accepted by the server.
    ///
    /// Fires after a successful ``ContactCustomFieldsProvider/set(_:for:)`` call.
    /// Consumers typically use this as confirmation to dismiss a "saving…" indicator.
    case contactCustomFieldsSet

    /// The customer's custom fields were accepted by the server.
    ///
    /// Fires after a successful ``CustomerCustomFieldsProvider/set(_:)`` call.
    /// Consumers typically use this as confirmation to dismiss a "saving…" indicator.
    case customerCustomFieldsSet

    /// The SDK encountered an error outside of an explicit `try`/`throws` call site —
    /// typically a server-side problem delivered asynchronously, a malformed event from
    /// the server, or a token-refresh issue that surfaced after `connect()` returned.
    ///
    /// Consumers should surface the error to the user (or log + retry) according to their
    /// product's error-handling policy. Errors here do **not** terminate the events
    /// stream; subscribers continue receiving subsequent events.
    case error(Error)

    /// A backend-triggered proactive action arrived — currently an inactivity popup that
    /// asks whether the user wants to keep the conversation open.
    ///
    /// Present the popup using the data in the associated value, then send the user's
    /// response back via ``ProactiveActionProvider/trigger(_:)``. The UI module handles
    /// this automatically; consumers building custom UI need to render the popup
    /// themselves — see `cs-inactivity-popup.md`.
    case proactiveActionReceived(ProactiveActionType)
}
