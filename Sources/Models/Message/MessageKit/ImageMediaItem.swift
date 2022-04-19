//
//  Created by Customer Dynamics Development on 9/22/21.
//

import Foundation
import UIKit
import MessageKit

/// The struct of a message with an image attachment
@available(iOS 13.0, *)
public struct ImageMediaItem: MediaItem {

	public var url: URL?
	public var image: UIImage?
	public var placeholderImage: UIImage
	public var size: CGSize

	init(image: UIImage) {
		self.image = image
		self.size = CGSize(width: 240, height: 240)
		self.placeholderImage = UIImage()
	}

	init(imageURL: URL) {
		self.url = imageURL
		self.size = CGSize(width: 240, height: 240)
		self.placeholderImage = UIImage(named: "placeholder", in: .module, with: nil)!
	}
}
