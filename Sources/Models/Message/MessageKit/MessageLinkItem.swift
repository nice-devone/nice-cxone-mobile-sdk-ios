//
//  Created by Customer Dynamics Development on 9/22/21.
//

import Foundation
import MessageKit
import UIKit

/// The struct message with a URL
public struct MessageLinkItem: LinkItem {
	public let text: String?
	public let attributedText: NSAttributedString?
	public let url: URL
	public let title: String?
	public let teaser: String
	public let thumbnailImage: UIImage
}
