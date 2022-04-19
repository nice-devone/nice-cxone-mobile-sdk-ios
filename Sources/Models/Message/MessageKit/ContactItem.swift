//
//  Created by Customer Dynamics Development on 9/22/21.
//

import Foundation
import MessageKit



/// The struct for a message with contact information
public struct MockContactItem: ContactItem {
	
	public var displayName: String
	public var initials: String
	public var phoneNumbers: [String]
	public var emails: [String]
	
	init(name: String, initials: String, phoneNumbers: [String] = [], emails: [String] = []) {
		self.displayName = name
		self.initials = initials
		self.phoneNumbers = phoneNumbers
		self.emails = emails
	}
	
}
