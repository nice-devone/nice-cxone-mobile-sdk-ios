import Foundation

/// Data payload for the load more messages event.
struct LoadMoreMessagesEventData: Encodable {
    let scrollToken: String
    let thread: Thread
    let oldestMessageDatetime: String // TODO: Change type to Date
}
