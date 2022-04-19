//
//  Created by Customer Dynamics Development on 8/31/21.
//

import Foundation
import MessageKit

/// The `User` struct will be used for both the sender and receiver of chats.
public struct Customer {
	public var senderId: String
	public var displayName: String
	
	public init(senderId: String, displayName: String) {
		self.senderId = senderId
		self.displayName = displayName
	}
}
extension Customer: SenderType, Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool{
        return lhs.senderId.lowercased() == rhs.senderId.lowercased()
    }
}
extension Customer {
    var id: String {
        return senderId 
    }
}

extension Customer: Codable {}

extension Customer {
    private var person: PersonNameComponents{
        PersonNameComponentsFormatter().personNameComponents(from: self.displayName) ?? PersonNameComponents()
    }
}

public extension Customer {
    var firstName: String {
        self.person.givenName ?? ""
    }
    
    var familyName: String {
        person.familyName ?? ""
    }
}
