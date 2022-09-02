import Foundation

public struct ThreadRecoveredEvent: Codable {
	public var eventId: UUID
	public var postback: ThreadRecoveredEventPostback
	
}
