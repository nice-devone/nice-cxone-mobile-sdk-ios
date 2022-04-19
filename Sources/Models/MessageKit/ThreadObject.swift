//
//  Created by Customer Dynamics Development on 9/8/21.
//

import Foundation

/// The `ThreadObject` contains the list of messages.
@available(iOS 13.0, *)
public struct ThreadObject {
	public var id: String
	public var idOnExternalPlatform: UUID
	public var messages: [Message] = []
	public var threadAgent: Customer
    public var active: Bool = false
}
@available(iOS 13.0, *)
extension ThreadObject: Identifiable {}
