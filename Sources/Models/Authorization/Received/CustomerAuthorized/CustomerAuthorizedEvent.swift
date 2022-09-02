import Foundation

/// Event received when a customer is successfully authorized.
public struct CustomerAuthorizedEvent: Codable {
    public var eventId: UUID
    public var postback: CustomerAuthorizedEventPostback
    
}
